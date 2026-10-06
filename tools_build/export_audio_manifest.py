#!/usr/bin/env python3
"""Export the Unity audio pipeline into HaxePort/assets/audio_manifest.json.

Inputs (read-only, from the Unity project):
  * Assets/AddressableAssetsData/AssetGroups/*.asset
        Addressable groups. Each entry gives  GUID -> (address, labels, group).
        This is the authority for "which address does this clip have" and for the
        Addressables labels ("Init"/"Main" + "Sound"/"Music") that
        MVZ2.Managers.ResourceManager loads by.
  * Assets/**/*.meta
        GUID -> asset path map, plus the AudioImporter import settings
        (loadType / compressionFormat / quality / preloadAudioData / ...).
  * the audio files themselves (wav/ogg/mp3)
        Only the headers are read, to fill AudioClip.length / frequency / channels,
        which MVZ2.Audios.MusicManager needs for normalized music time.
  * Assets/Mixers/Main.mixer
        The single AudioMixer of the game. Groups + exposed parameters are exported
        so the Haxe AudioMixer shim can reproduce the real bus gains
        (SoundVolume / MusicVolume / FadeVolume / MainWeight / SubWeight).
  * Assets/Prefabs/Init/MainManager.prefab
        The only four AudioSources of the whole project
        (soundTemplate / loopSoundTemplate / mainTrackSource / subTrackSource).
        Their volume/loop/pitch/mixer-group values are exported because the .meta
        files never carry them.

Usage:
    python HaxePort/tools_build/export_audio_manifest.py            # write manifest (+ convert mp3)
    python HaxePort/tools_build/export_audio_manifest.py --no-convert   # write manifest only
    python HaxePort/tools_build/export_audio_manifest.py --check    # validate only

mp3 → ogg：
  本机 lime 分支（lime-anit）的原生音频只支持 OGG/WAV，mp3 无法解码（见
  HaxePort/verify/addressables/AddressablesSmokeTest.hx 的说明）。而 Unity 导入这些文件时用的是
  Vorbis 编码（.meta 的 compressionFormat: 1），所以运行期数据本来就应该是 Vorbis。
  因此这里用 ffmpeg 把 mp3 转成同名的 .ogg 放到镜像目录里（源 mp3 保留），
  清单的 assetPath 指向 .ogg 并记下 convertedFrom；已存在且不比源文件旧时跳过转换（幂等）。
"""

import argparse
import json
import os
import re
import shutil
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PORT_DIR = os.path.dirname(HERE)
REPO_DIR = os.path.dirname(PORT_DIR)
ASSETS_DIR = os.path.join(REPO_DIR, "Assets")
GROUP_DIR = os.path.join(ASSETS_DIR, "AddressableAssetsData", "AssetGroups")
MIXER_PATH = os.path.join(ASSETS_DIR, "Mixers", "Main.mixer")
MAINMANAGER_PREFAB = os.path.join(ASSETS_DIR, "Prefabs", "Init", "MainManager.prefab")
OUT_PATH = os.path.join(PORT_DIR, "assets", "audio_manifest.json")

# Unity AudioClipLoadType
LOAD_TYPE_NAMES = {0: "DecompressOnLoad", 1: "CompressedInMemory", 2: "Streaming"}
# Unity AudioCompressionFormat
COMPRESSION_FORMAT_NAMES = {
    0: "PCM",
    1: "Vorbis",
    2: "Helix",
    3: "MP3",
    4: "AAC",
    5: "VAG",
    6: "HEVAG",
    7: "XMA",
    8: "AT9",
    9: "Opus",
}
AUDIO_EXTS = (".wav", ".ogg", ".mp3", ".aif", ".aiff", ".flac", ".m4a", ".aac", ".wma")

GUID_RE = re.compile(r"^guid: ([0-9a-fA-F]{32})\s*$", re.M)


# --------------------------------------------------------------------------- #
# Addressables groups
# --------------------------------------------------------------------------- #
def parse_addressable_groups():
    """Return [{group, address, guid, labels}] for every group file."""
    entries = []
    for name in sorted(os.listdir(GROUP_DIR)):
        if not name.endswith(".asset"):
            continue
        path = os.path.join(GROUP_DIR, name)
        text = read_text(path)
        group = re.search(r"^  m_GroupName: (.*)$", text, re.M)
        group_name = group.group(1).strip() if group else os.path.splitext(name)[0]
        # m_SerializeEntries block: each entry starts with "  - m_GUID:"
        for chunk in re.split(r"^  - ", text, flags=re.M)[1:]:
            gm = re.match(r"m_GUID: (.*)", chunk)
            am = re.search(r"^    m_Address: (.*)$", chunk, re.M)
            if not gm or not am:
                continue
            guid = gm.group(1).strip()
            address = am.group(1).strip()
            lm = re.search(r"^    m_SerializedLabels: *(.*)$(?:\n((?:    - .*\n)+))?", chunk, re.M)
            labels = []
            if lm:
                inline = lm.group(1).strip()
                if inline and inline != "[]":
                    labels = [x.strip() for x in inline.strip("[]").split(",") if x.strip()]
                elif lm.group(2):
                    labels = [x.strip().lstrip("- ").strip() for x in lm.group(2).splitlines() if x.strip()]
            entries.append(
                {"group": group_name, "address": address, "guid": guid, "labels": labels}
            )
    return entries


def build_guid_index():
    """guid -> {'sourcePath','assetPath','metaPath','importer'} for every .meta under Assets."""
    index = {}
    for root, _dirs, files in os.walk(ASSETS_DIR):
        for f in files:
            if not f.endswith(".meta"):
                continue
            meta_path = os.path.join(root, f)
            asset_path = meta_path[: -len(".meta")]
            if not os.path.exists(asset_path):
                continue
            try:
                text = read_text(meta_path)
            except Exception:
                continue
            m = GUID_RE.search(text)
            if not m:
                continue
            importer = re.search(r"^(\w*Importer):", text, re.M)
            rel = os.path.relpath(asset_path, REPO_DIR).replace("\\", "/")
            index[m.group(1).lower()] = {
                "sourcePath": rel,
                "assetPath": os.path.relpath(asset_path, ASSETS_DIR).replace("\\", "/"),
                "metaPath": os.path.relpath(meta_path, REPO_DIR).replace("\\", "/"),
                "importer": importer.group(1) if importer else None,
            }
    return index


# --------------------------------------------------------------------------- #
# AudioImporter settings
# --------------------------------------------------------------------------- #
def parse_audio_importer(meta_text):
    """Extract the AudioImporter settings from a .meta file."""
    out = {}
    ds = re.search(r"^  defaultSettings:\n((?:    .*\n)+)", meta_text, re.M)
    block = ds.group(1) if ds else ""
    scalars = dict(re.findall(r"^    (\w+): (.+)$", block, re.M))
    for key in (
        "loadType",
        "sampleRateSetting",
        "sampleRateOverride",
        "compressionFormat",
        "quality",
        "conversionMode",
        "preloadAudioData",
    ):
        if key in scalars:
            out[key] = to_number(scalars[key])
    top = dict(re.findall(r"^  (\w+): (.+)$", meta_text, re.M))
    for key, dest in (
        ("forceToMono", "forceToMono"),
        ("normalize", "normalize"),
        ("loadInBackground", "loadInBackground"),
        ("ambisonic", "ambisonic"),
        ("3D", "threeD"),
        ("userData", "userData"),
    ):
        if key in top:
            out[dest] = to_bool(top[key]) if dest != "userData" else top[key].strip()
    out["platformSettingOverrides"] = re.search(r"^  platformSettingOverrides: (.+)$", meta_text, re.M) is not None and \
        re.search(r"^  platformSettingOverrides: (.+)$", meta_text, re.M).group(1).strip() != "{}"
    out["loadTypeName"] = LOAD_TYPE_NAMES.get(out.get("loadType"), None)
    out["compressionFormatName"] = COMPRESSION_FORMAT_NAMES.get(out.get("compressionFormat"), None)
    return out


def to_number(text):
    text = text.strip()
    try:
        if "." in text:
            return float(text)
        return int(text)
    except ValueError:
        return text


def to_bool(text):
    return text.strip() not in ("0", "false", "False")


# --------------------------------------------------------------------------- #
# Audio file header probing (duration / sample rate / channels)
# --------------------------------------------------------------------------- #
def detect_container(path):
    """Sniff the real audio container from the magic bytes.

    Several files in the project are named `.wav` but actually contain Ogg Vorbis
    data (47 of them), which is what Unity shipped. lime's AudioBuffer.__getCodec
    sniffs the same signatures, so the port can play them as-is.
    """
    with open(path, "rb") as f:
        head = f.read(65536)
    if head[:4] == b"OggS":
        return "ogg"
    if head[:4] == b"RIFF" and head[8:12] == b"WAVE":
        return "wav"
    if head[:3] == b"ID3" or mpeg_frame_at(head, 0) is not None:
        return "mp3"
    # mvz2:minigame has ~730 bytes of padding before its first MPEG frame.
    for off in range(1, len(head) - 4):
        if head[off] == 0xFF and mpeg_frame_at(head, off) is not None:
            return "mp3"
    return None


def mpeg_frame_at(data, off):
    """Return the parsed MPEG audio frame header at `off`, or None."""
    if off + 4 > len(data) or data[off] != 0xFF or (data[off + 1] & 0xE0) != 0xE0:
        return None
    b1, b2, b3 = data[off + 1], data[off + 2], data[off + 3]
    version_bits = (b1 >> 3) & 0x03
    layer_bits = (b1 >> 1) & 0x03
    bitrate_idx = (b2 >> 4) & 0x0F
    rate_idx = (b2 >> 2) & 0x03
    if version_bits == 1 or layer_bits == 0 or bitrate_idx in (0, 15) or rate_idx == 3:
        return None
    return (version_bits, layer_bits, bitrate_idx, rate_idx, (b3 >> 6) & 0x03)


def probe_audio(path):
    ext = os.path.splitext(path)[1].lower()
    size = os.path.getsize(path)
    container = detect_container(path)
    try:
        if container == "wav":
            info = probe_wav(path)
        elif container == "ogg":
            info = probe_ogg(path)
        elif container == "mp3":
            info = probe_mp3(path)
        else:
            info = {}
    except Exception as exc:  # keep the manifest useful even if one file is odd
        info = {"lengthSource": "error: %s" % exc}
    info["ext"] = ext.lstrip(".")
    info["container"] = container or "unknown"
    info["extMismatch"] = bool(container) and ("." + container) != ext
    info["bytes"] = size
    return info


def probe_wav(path):
    with open(path, "rb") as f:
        head = f.read(12)
        if head[:4] != b"RIFF" or head[8:12] != b"WAVE":
            return {"lengthSource": "not-riff"}
        fmt = None
        data_size = None
        while True:
            chunk = f.read(8)
            if len(chunk) < 8:
                break
            cid, csize = chunk[:4], struct.unpack("<I", chunk[4:])[0]
            if cid == b"fmt ":
                body = f.read(csize)
                audio_format, channels, sample_rate, byte_rate, _align, bits = struct.unpack("<HHIIHH", body[:16])
                if audio_format == 0xFFFE and len(body) >= 40:
                    audio_format = struct.unpack("<H", body[24:26])[0]
                fmt = {
                    "audioFormat": audio_format,
                    "channels": channels,
                    "frequency": sample_rate,
                    "byteRate": byte_rate,
                    "bitsPerSample": bits,
                }
            elif cid == b"data":
                data_size = csize
                f.seek(csize, os.SEEK_CUR)
            else:
                f.seek(csize + (csize & 1), os.SEEK_CUR)
            if fmt and data_size is not None:
                break
    if not fmt:
        return {"lengthSource": "no-fmt"}
    frames = None
    if fmt["audioFormat"] == 1 and fmt["channels"] and fmt["bitsPerSample"]:
        frames = data_size // (fmt["channels"] * fmt["bitsPerSample"] // 8)
    elif fmt["audioFormat"] == 3 and fmt["channels"]:
        frames = data_size // (fmt["channels"] * 4)
    length = frames / fmt["frequency"] if frames and fmt["frequency"] else 0.0
    return {
        "length": round(length, 6),
        "samples": frames,
        "lengthSource": "wav-header",
        "frequency": fmt["frequency"],
        "channels": fmt["channels"],
        "bitsPerSample": fmt["bitsPerSample"],
        "codec": {1: "pcm", 3: "ieee-float", 0x11: "adpcm", 0x55: "mp3"}.get(fmt["audioFormat"], "unknown-%d" % fmt["audioFormat"]),
        "dataBytes": data_size,
    }


def probe_ogg(path):
    # Vorbis identification header lives in the first page.
    frequency = 0
    channels = 0
    with open(path, "rb") as f:
        head = f.read(4096)
    idx = head.find(b"\x01vorbis")
    if idx >= 0 and idx + 16 <= len(head):
        channels = head[idx + 11]
        frequency = struct.unpack("<I", head[idx + 12 : idx + 16])[0]
    # Last page granule position == total sample count.
    granule = 0
    with open(path, "rb") as f:
        f.seek(0)
        data = f.read()
    pos = data.rfind(b"OggS")
    while pos >= 0:
        if pos + 27 <= len(data):
            seg = data[pos + 26]
            if pos + 27 + seg <= len(data):
                granule = struct.unpack("<Q", data[pos + 6 : pos + 14])[0]
                break
        pos = data.rfind(b"OggS", 0, pos)
    length = granule / frequency if frequency and granule else 0.0
    return {
        "length": round(length, 6),
        "samples": granule,
        "lengthSource": "ogg-granule",
        "frequency": frequency,
        "channels": channels,
        "bitsPerSample": None,
        "codec": "vorbis",
    }


MP3_BITRATES = {
    (1, 1): [0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448],  # MPEG1 L1
    (1, 2): [0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384],      # MPEG1 L2
    (1, 3): [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320],       # MPEG1 L3
    (2, 1): [0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256],      # MPEG2 L1
    (2, 2): [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160],
    (2, 3): [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160],
}
MP3_RATES = {3: [44100, 48000, 32000], 2: [22050, 24000, 16000], 0: [11025, 12000, 8000]}


def probe_mp3(path):
    with open(path, "rb") as f:
        data = f.read()
    start = 0
    if data[:3] == b"ID3" and len(data) > 10:
        size = (data[6] & 0x7F) << 21 | (data[7] & 0x7F) << 14 | (data[8] & 0x7F) << 7 | (data[9] & 0x7F)
        start = 10 + size
    pos = start
    header = None
    while pos + 4 <= len(data):
        parsed = mpeg_frame_at(data, pos)
        if parsed is not None:
            version_bits, layer_bits, bitrate_idx, rate_idx, channel_mode = parsed
            header = (pos, version_bits, layer_bits, bitrate_idx, rate_idx, channel_mode)
            break
        pos += 1
    if header is None:
        return {"lengthSource": "no-frame"}
    pos, version_bits, layer_bits, bitrate_idx, rate_idx, channel_mode = header
    version = {3: 1, 2: 2, 0: 25}[version_bits]
    layer = {1: 3, 2: 2, 3: 1}[layer_bits]
    group = 1 if version == 1 else 2
    bitrate = MP3_BITRATES[(group, layer)][bitrate_idx] * 1000
    frequency = MP3_RATES[version_bits][rate_idx]
    channels = 1 if channel_mode == 3 else 2
    samples_per_frame = 1152 if version == 1 else 576
    side_info = 17 if version == 1 and channels == 2 else 9
    xing_off = pos + 4 + side_info
    frames = None
    length_source = "mp3-cbr-estimate"
    if data[xing_off : xing_off + 4] in (b"Xing", b"Info"):
        flags = struct.unpack(">I", data[xing_off + 4 : xing_off + 8])[0]
        if flags & 0x01:
            frames = struct.unpack(">I", data[xing_off + 8 : xing_off + 12])[0] + 1
            length_source = "mp3-xing"
    if frames is not None:
        length = frames * samples_per_frame / frequency
    else:
        length = (len(data) - pos) * 8 / bitrate
    return {
        "length": round(length, 6),
        "samples": None if frames is None else frames * samples_per_frame,
        "lengthSource": length_source,
        "frequency": frequency,
        "channels": channels,
        "bitsPerSample": None,
        "codec": "mpeg-layer-%d" % layer,
        "headerOffset": pos,
    }


# --------------------------------------------------------------------------- #
# mp3 → ogg (lime 的原生音频只支持 OGG/WAV；Unity 侧本来也是 Vorbis 编码)
# --------------------------------------------------------------------------- #
def convert_mp3_to_ogg(source_abs, target_abs, quality="5"):
    """用 ffmpeg 把 mp3 转成 Vorbis/ogg。已存在且不比源文件旧时跳过。返回 True 表示可用。"""
    if os.path.exists(target_abs) and os.path.getmtime(target_abs) >= os.path.getmtime(source_abs):
        return True
    ffmpeg = shutil.which("ffmpeg")
    if ffmpeg is None:
        print("  ! 找不到 ffmpeg，跳过 %s 的 mp3→ogg 转换" % os.path.basename(source_abs), file=sys.stderr)
        return False
    os.makedirs(os.path.dirname(target_abs), exist_ok=True)
    cmd = [ffmpeg, "-y", "-loglevel", "error", "-i", source_abs, "-c:a", "libvorbis", "-q:a", quality, target_abs]
    try:
        result = subprocess.run(cmd, capture_output=True)
    except Exception as exc:
        print("  ! ffmpeg 执行失败（%s）：%s" % (os.path.basename(source_abs), exc), file=sys.stderr)
        return False
    if result.returncode != 0 or not os.path.exists(target_abs):
        print("  ! mp3→ogg 转换失败（%s）：%s" % (os.path.basename(source_abs),
                                                result.stderr.decode("utf-8", "replace").strip()[:300]), file=sys.stderr)
        return False
    return True


# --------------------------------------------------------------------------- #
# Mixer
# --------------------------------------------------------------------------- #
def parse_mixer(path):
    text = read_text(path)
    blocks = re.split(r"^--- !u!(\d+) &(\-?\d+)\n", text, flags=re.M)
    objects = {}
    for i in range(1, len(blocks), 3):
        objects[blocks[i + 1]] = (blocks[i], blocks[i + 2])

    groups = {}
    for fid, (cls, body) in objects.items():
        if cls != "243":  # AudioMixerGroupController
            continue
        name = re.search(r"\n  m_Name: (.*)", body).group(1).strip()
        child_match = re.search(r"\n  m_Children:\n((?:  - \{fileID: -?\d+\}\n)+)", body)
        children = re.findall(r"fileID: (-?\d+)", child_match.group(1)) if child_match else []
        groups[fid] = {"name": name, "fileId": fid, "children": children, "parent": None}
    for fid, g in groups.items():
        for child in g["children"]:
            if child in groups:
                groups[child]["parent"] = fid

    exposed = {}
    for fid, (cls, body) in objects.items():
        if cls != "241":  # AudioMixerController
            continue
        name = re.search(r"\n  m_Name: (.*)", body).group(1).strip()
        master = re.search(r"m_MasterGroup: \{fileID: (-?\d+)\}", body).group(1)
        pairs = re.findall(r"- guid: (\w+)\n    name: (.*)", body)
        for guid, param in pairs:
            exposed[param] = guid
        # guid -> group: exposed parameter guid equals the group's m_Volume guid.
        group_by_volume_guid = {}
        for gfid, (gcls, gbody) in objects.items():
            if gcls != "243":
                continue
            vm = re.search(r"\n  m_Volume: (\w+)", gbody)
            if vm:
                group_by_volume_guid[vm.group(1)] = gfid
        parameters = {}
        for guid, param in pairs:
            gfid = group_by_volume_guid.get(guid)
            parameters[param] = groups[gfid]["name"] if gfid in groups else None
        return {
            "name": name,
            "fileId": fid,
            "masterGroup": groups[master]["name"] if master in groups else None,
            "groups": [
                {
                    "name": g["name"],
                    "parent": groups[g["parent"]]["name"] if g["parent"] in groups else None,
                    "volumeDb": 0.0,
                    "exposedParameter": next((p for p, n in parameters.items() if n == g["name"]), None),
                    "children": [groups[c]["name"] for c in g["children"] if c in groups],
                }
                for g in sorted(groups.values(), key=lambda x: x["name"])
            ],
            "exposedParameters": parameters,
        }
    return None


# --------------------------------------------------------------------------- #
# AudioSource templates of the Init prefab
# --------------------------------------------------------------------------- #
TEMPLATE_FIELDS = ["soundTemplate", "loopSoundTemplate", "mainTrackSource", "subTrackSource"]


def parse_audio_source_templates(cfg):
    name = cfg.get("prefab") or "MainManager"
    path = cfg.get("path")
    if not path or not os.path.exists(path):
        return []
    text = read_text(path)
    blocks = re.split(r"^--- !u!(\d+) &(\-?\d+)\n", text, flags=re.M)
    objects = {}
    for i in range(1, len(blocks), 3):
        objects[blocks[i + 1]] = (blocks[i], blocks[i + 2])

    # MonoBehaviour that owns the four fields (SoundManager / MusicManager).
    field_owner = {}
    for fid, (cls, body) in objects.items():
        if cls != "114":
            continue
        for field in TEMPLATE_FIELDS:
            m = re.search(r"^  %s: \{fileID: (\d+)\}" % field, body, re.M)
            if m:
                field_owner[field] = m.group(1)

    templates = []
    mixer = parse_mixer(MIXER_PATH)
    group_by_fileid = {}
    if mixer:
        mixer_text = read_text(MIXER_PATH)
        mblocks = re.split(r"^--- !u!(\d+) &(\-?\d+)\n", mixer_text, flags=re.M)
        for i in range(1, len(mblocks), 3):
            if mblocks[i] != "243":
                continue
            gname = re.search(r"\n  m_Name: (.*)", mblocks[i + 2]).group(1).strip()
            group_by_fileid[mblocks[i + 1]] = gname
    for field in TEMPLATE_FIELDS:
        fid = field_owner.get(field)
        if fid is None or fid not in objects:
            continue
        cls, body = objects[fid]
        # SoundSource.cs / MusicManager.cs MonoBehaviour -> audioSource field
        src = re.search(r"^  audioSource: \{fileID: (\d+)\}", body, re.M)
        if not src:
            src = re.search(r"^  %s: \{fileID: (\d+)\}" % field, body, re.M)
        src_id = src.group(1) if src else fid
        if src_id not in objects or objects[src_id][0] != "82":
            continue
        scalars = dict(re.findall(r"^  (\w+): (.+)$", objects[src_id][1], re.M))
        mixer_group = re.search(r"fileID: (\-?\d+)", scalars.get("OutputAudioMixerGroup", "") or "")
        # AudioSource.spatialBlend is serialized as the constant value of panLevelCustomCurve.
        blend = None
        curve = re.search(r"panLevelCustomCurve:\n(.*?)\n  \w", objects[src_id][1], re.S)
        if curve:
            keys = re.findall(r"time: ([\d.-]+)\n      value: ([\d.-]+)", curve.group(1))
            if keys and keys[0][0] == "0":
                blend = float(keys[0][1])
        templates.append(
            {
                "field": field,
                "prefab": name,
                "gameObject": scalar_fileid(objects[src_id][1], "m_GameObject"),
                "mixer": mixer["name"] if mixer else None,
                "mixerGroup": group_by_fileid.get(mixer_group.group(1)) if mixer_group else None,
                "volume": float(scalars.get("m_Volume", "1")),
                "pitch": float(scalars.get("m_Pitch", "1")),
                "loop": scalars.get("Loop", "0").strip() == "1",
                "mute": scalars.get("Mute", "0").strip() == "1",
                "playOnAwake": scalars.get("m_PlayOnAwake", "1").strip() == "1",
                "priority": int(scalars.get("Priority", "128")),
                "spatialBlend": blend,
                "dopplerLevel": float(scalars.get("DopplerLevel", "1")),
                "minDistance": float(scalars.get("MinDistance", "1")),
                "maxDistance": float(scalars.get("MaxDistance", "500")),
                "rolloffMode": int(scalars.get("rolloffMode", "0")),
            }
        )
    return templates


def scalar_fileid(body, key):
    m = re.search(r"^  %s: \{fileID: (\-?\d+)\}" % key, body, re.M)
    return m.group(1) if m else None


# --------------------------------------------------------------------------- #
# Cross validation against the game metas
# --------------------------------------------------------------------------- #
META_DIR = os.path.join(ASSETS_DIR, "GameContent", "Assets", "mvz2", "metas")


def collect_audio_references():
    """address -> [meta file names] referenced by sounds.xml / musics.xml / areas / stages."""
    refs = {}

    def add(address, where):
        refs.setdefault(address, []).append(where)

    files = {}
    for name in ("sounds.xml", "musics.xml", "areas.xml", "stages.xml", "mainmenuviews.xml", "archive.xml", "credits.xml"):
        p = os.path.join(META_DIR, name)
        if os.path.exists(p):
            files[name] = read_text(p)
    for name, text in files.items():
        for attr in ("main", "sub"):
            for m in re.finditer(r'<track[^>]*\b%s="([^"]+)"' % attr, text):
                add(m.group(1), name)
        if name == "sounds.xml":
            for m in re.finditer(r'<sample[^>]*\bpath="([^"]+)"', text):
                add(m.group(1), name)
        if name in ("areas.xml", "stages.xml"):
            for m in re.finditer(r"<(?:music|musicID|MusicID)>([^<]+)</(?:music|musicID|MusicID)>", text):
                add(m.group(1).strip(), name)
    return refs


# --------------------------------------------------------------------------- #
def read_text(path):
    with open(path, "r", encoding="utf-8-sig", errors="replace") as f:
        return f.read()


def build_manifest(convert_mp3=True):
    entries = parse_addressable_groups()
    guid_index = build_guid_index()
    clips = []
    unlabelled = []
    missing_guid = []
    audio_not_addressable = set()
    addressable_audio_guids = set()
    converted = 0
    for e in entries:
        info = guid_index.get(e["guid"].lower())
        if info is None:
            missing_guid.append(e)
            continue
        path = info["sourcePath"]
        if not path.lower().endswith(AUDIO_EXTS):
            continue
        addressable_audio_guids.add(e["guid"].lower())
        meta_text = read_text(os.path.join(REPO_DIR, info["metaPath"])) if os.path.exists(os.path.join(REPO_DIR, info["metaPath"])) else ""
        importer = info["importer"]
        settings = parse_audio_importer(meta_text) if importer == "AudioImporter" else {}
        full = os.path.join(REPO_DIR, path)
        probe = probe_audio(full)
        source_probe = probe
        asset_path = info["assetPath"]
        converted_from = None
        if convert_mp3 and probe.get("container") == "mp3":
            # PORT-NOTE: lime-anit 的原生音频只支持 OGG/WAV（mp3 解码返回 null），
            # 而 Unity 导入时本来就是 Vorbis（compressionFormat: 1），故转成同名的 .ogg。
            mirror_target = os.path.join(PORT_DIR, "assets", os.path.splitext(asset_path)[0] + ".ogg")
            if convert_mp3_to_ogg(full, mirror_target):
                converted_from = asset_path
                asset_path = os.path.splitext(asset_path)[0] + ".ogg"
                probe = probe_audio(mirror_target)
                converted += 1
        clip = {
            "address": e["address"],
            "labels": e["labels"],
            "group": e["group"],
            "guid": e["guid"],
            "sourcePath": path,
            "assetPath": asset_path,
            "importer": importer,
            "length": probe.get("length", 0.0),
            "samples": probe.get("samples"),
            "lengthSource": probe.get("lengthSource"),
            "frequency": probe.get("frequency"),
            "channels": probe.get("channels"),
            "bitsPerSample": probe.get("bitsPerSample"),
            "codec": probe.get("codec"),
            "bytes": probe.get("bytes"),
            "format": probe.get("container"),
            "ext": probe.get("ext"),
            "extMismatch": probe.get("extMismatch"),
        }
        if converted_from is not None:
            clip["convertedFrom"] = converted_from
            clip["sourceLength"] = source_probe.get("length", 0.0)
            clip["sourceCodec"] = source_probe.get("codec")
            clip["sourceBytes"] = source_probe.get("bytes")
        clip.update(settings)
        clips.append(clip)
        if not e["labels"]:
            unlabelled.append(e["address"])

    # audio files that exist but are not addressable
    for root, _dirs, files in os.walk(ASSETS_DIR):
        for f in files:
            if not f.lower().endswith(AUDIO_EXTS) or f.endswith(".meta"):
                continue
            full = os.path.join(root, f)
            meta = full + ".meta"
            found = False
            if os.path.exists(meta):
                m = GUID_RE.search(read_text(meta))
                if m and m.group(1).lower() in addressable_audio_guids:
                    found = True
            if not found:
                audio_not_addressable.add(os.path.relpath(full, REPO_DIR).replace("\\", "/"))

    clips.sort(key=lambda c: c["address"])
    mixer = parse_mixer(MIXER_PATH)
    mixer["sourcePath"] = os.path.relpath(MIXER_PATH, REPO_DIR).replace("\\", "/")
    mixer["assetPath"] = os.path.relpath(MIXER_PATH, ASSETS_DIR).replace("\\", "/")
    mixer_meta = MIXER_PATH + ".meta"
    mixer["guid"] = GUID_RE.search(read_text(mixer_meta)).group(1) if os.path.exists(mixer_meta) else None
    templates = parse_audio_source_templates(
        {"prefab": os.path.splitext(os.path.basename(MAINMANAGER_PREFAB))[0], "path": MAINMANAGER_PREFAB}
    )

    label_counts = {}
    for c in clips:
        for l in c["labels"]:
            label_counts[l] = label_counts.get(l, 0) + 1

    manifest = {
        "generatedBy": "HaxePort/tools_build/export_audio_manifest.py",
        "portNote": (
            "Unity Addressables 目录 → HaxePort 运行期资源表。address 即 Addressables 的 PrimaryKey，"
            "ResourceManager 用它构造 NamespaceID（mvz2:<path>），labels 对应 LoadLabeledResources 的标签查询。"
            "clips[].loadType 是 Unity 的 AudioClipLoadType（0=DecompressOnLoad / 1=CompressedInMemory / 2=Streaming，"
            "本工程只有 0 和 2）：移植层不区分加载方式，一律在首次播放时按需解码并交给 lime 缓存"
            "（对应 Unity 的 Streaming；若首播卡顿需要优化，可预解码 loadType=0 的 482 个音效，合计约 67MB）。"
        ),
        "assetRoot": "assets",
        "resourceType": "unity.AudioClip",
        "clips": clips,
        # PORT-NOTE: 额外给出一份与主清单（resource_manifest.json，见 tools_build/build_manifest.py）
        # 同形的 entries 列表：同样的 address / path（相对 assets 根）/ labels，类型字段也用同一套
        # （kind = "Audio"，type = 文件容器扩展名）。这样 unity.addressableassets.ResourceManifest
        # 若被指向本文件也能直接吃下这些条目，两个清单的地址与路径体系保持一致。
        "entries": [
            {
                "address": c["address"],
                "path": c["assetPath"],
                "labels": c["labels"],
                "kind": "Audio",
                "type": c["ext"],
                "group": c["group"],
                "guid": c["guid"],
            }
            for c in clips
        ],
        "mixers": [mixer] if mixer else [],
        "audioSourceTemplates": templates,
        "stats": {
            "clipCount": len(clips),
            "labelCounts": label_counts,
            "totalBytes": sum(c.get("bytes") or 0 for c in clips),
            "byGroup": count_by(clips, "group"),
            "byFormat": count_by(clips, "format"),
            "byExtension": count_by(clips, "ext"),
            "extMismatchCount": sum(1 for c in clips if c.get("extMismatch")),
            "byLoadType": count_by(clips, "loadTypeName"),
            "convertedMp3Count": converted,
            "audioFilesWithoutAddressable": sorted(audio_not_addressable),
            "addressableEntriesWithoutGuidIndex": len(missing_guid),
            "clipsWithoutLabels": sorted(unlabelled),
        },
    }
    return manifest, guid_index


def count_by(items, key):
    out = {}
    for i in items:
        k = str(i.get(key))
        out[k] = out.get(k, 0) + 1
    return out


def cmd_check(manifest):
    clips = manifest["clips"]
    by_address = {c["address"]: c for c in clips}
    ok = True
    print("[check] manifest clips: %d" % len(clips))
    refs = collect_audio_references()
    unresolved = []
    for address, where in sorted(refs.items()):
        if address not in by_address:
            unresolved.append((address, sorted(set(where))))
    print("[check] meta audio references: %d, unresolved: %d" % (len(refs), len(unresolved)))
    if unresolved:
        # These are broken in the Unity project as well (sounds.xml points at
        # mvz2:entity/skeleton_horse/skeleton_horse_cry1..3, no such asset).
        # A missing addressable = FindInMods returns null = SoundManager plays nothing,
        # which is exactly what Unity does, so this is NOT a port defect.
        print("    (upstream data gaps, faithfully reproduced as 'no clip'):")
    for address, where in unresolved[:40]:
        print("    MISSING %s  (referenced by %s)" % (address, ",".join(where)))
    no_file = [c["address"] for c in clips if not os.path.exists(os.path.join(PORT_DIR, "assets", c["assetPath"]))]
    print("[check] clips whose mirrored file is missing: %d" % len(no_file))
    for a in no_file[:20]:
        print("    MISSING FILE %s" % a)
        ok = False
    bad_length = [c["address"] for c in clips if not c.get("length")]
    print("[check] clips without duration: %d" % len(bad_length))
    for a in bad_length[:20]:
        print("    NO DURATION %s (%s)" % (a, by_address[a]["lengthSource"]))
    ok = ok and not bad_length and not no_file
    print("[check] containers: %s (extension mismatches: %d)"
          % (manifest["stats"]["byFormat"], manifest["stats"].get("extMismatchCount", 0)))
    print("[check] groups: %s" % manifest["stats"]["byGroup"])
    print("[check] mixer groups: %s" % [g["name"] for g in manifest["mixers"][0]["groups"]] if manifest["mixers"] else "[check] no mixer")
    print("[check] audio source templates: %s" % [(t["field"], t["loop"], t["mixerGroup"]) for t in manifest["audioSourceTemplates"]])
    print("[check] RESULT: %s" % ("OK" if ok else "FAILED"))
    return ok


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="only validate the current manifest")
    ap.add_argument("--no-convert", action="store_true",
                    help="不把 mp3 转成 ogg（默认会转，因为本机 lime 分支的原生音频只支持 OGG/WAV）")
    ap.add_argument("--out", default=OUT_PATH)
    args = ap.parse_args()

    if args.check:
        with open(args.out, "r", encoding="utf-8") as f:
            manifest = json.load(f)
        return 0 if cmd_check(manifest) else 1

    manifest, _guid_index = build_manifest(convert_mp3=not args.no_convert)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    with open(args.out, "w", encoding="utf-8", newline="\n") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)
        f.write("\n")
    stats = manifest["stats"]
    print("wrote %s" % args.out)
    print("  clips: %d (%.1f MB)" % (stats["clipCount"], stats["totalBytes"] / 1048576.0))
    print("  labels: %s" % stats["labelCounts"])
    print("  groups: %s" % stats["byGroup"])
    print("  formats: %s" % stats["byFormat"])
    print("  loadTypes: %s" % stats["byLoadType"])
    print("  mp3→ogg converted: %d" % stats["convertedMp3Count"])
    print("  audio files not addressable: %d" % len(stats["audioFilesWithoutAddressable"]))
    print("  mixer groups: %s" % ([g["name"] for g in manifest["mixers"][0]["groups"]] if manifest["mixers"] else []))
    print("  exposed params: %s" % (manifest["mixers"][0]["exposedParameters"] if manifest["mixers"] else {}))
    print("  source templates: %s" % [(t["field"], t["mixerGroup"], t["loop"], t["volume"]) for t in manifest["audioSourceTemplates"]])
    return 0


if __name__ == "__main__":
    sys.exit(main())
