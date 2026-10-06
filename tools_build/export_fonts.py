#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MVZ2 Unity -> HaxeFlixel 移植：TMP 字体资产转换器（字体/文本渲染工作包）

## 为什么需要这个脚本

C# 侧的文字全部由 TMPro 渲染：

    TextMeshProUGUI.font : TMP_FontAsset   （prefab 里是 {guid, fileID} 资产引用）
    TMP_FontAsset.sourceFontFile : Font    （m_SourceFontFileGUID -> 某个 .otf/.ttf）
    TMP_FontAsset.faceInfo       : FaceInfo（pointSize / scale / lineHeight / ascent / …）
    TMP_FontAsset.glyphTable / characterTable / atlasTextures（烘焙好的字形图集）

移植层没有 Unity 的资产系统，也没有「把 OTF 光栅化成图集」的运行时。因此本脚本在构建期把
TMP 字体资产里**所有影响排版的量**导出成 `HaxePort/assets/fonts_manifest.json`，并把图集贴图
落成 PNG（`HaxePort/assets/Fonts/atlas/*.png`），供运行期两种渲染路线使用：

  1. **OTF 路线（默认）** —— 用 `m_SourceFontFileGUID` 指到的 .otf/.ttf（lime 的 FONT 资产）
     交给 openfl 光栅化，字号按 TMP 的 `requestedPointSize / faceInfo.pointSize` 缩放。
     与 Unity 用的是**同一个字体文件**，观感一致。
  2. **图集路线（可选）** —— 用导出的 glyphRect/characterTable + 图集 PNG 建 `FlxBitmapFont`，
     像素级复刻 TMP 的烘焙结果（含 atlasPadding 留白与 bearing 偏移）。

## Unity 侧数据格式（逐字段查证）

`*.asset` 是 Unity 的 YAML 序列化。一个 TMP 字体资产文件里可能有多个对象：

    --- !u!114 &11400000   MonoBehaviour  = TMP_FontAsset 本体
    --- !u!21  &-4514157…  Material       = "minecraft_font Atlas Material"
    --- !u!28  &4118462…   Texture2D      = 图集贴图（Alpha8，见下）

**图集的像素格式**：`m_TextureFormat: 1` = `TextureFormat.Alpha8`，`m_Width × m_Height` 个
**单字节 alpha**，行主序，**第 0 行是图像顶部**（已用 `ascii.asset` 里 'A'/'L'/'T'/'f'/'y'
的像素图案逐行核对：`m_GlyphRect.m_Y` 直接就是「距顶部」的行号，不需要翻转）。
Unity 的 TMP 着色器用 `_MainTex.a` 当字形覆盖度，因此这里把 alpha 写进 RGBA 的 A 通道、
RGB 置白。

**多图集**：`minecraft_font.asset` 里有 7 张 Texture2D（1 张 4096×4096 的"主图集" +
6 张 256×256 的分图集）。主图集是 `m_AtlasPopulationMode: 1`（Dynamic）的运行时目标，
序列化时几乎是空的（只有 798 个非零字节 = 一个下划线字形）；真正的字形在分图集里。
运行期按 `glyph.m_AtlasIndex` 选对应图集。

## 用法

    python tools_build/export_fonts.py              # 写 assets/fonts_manifest.json + 图集 PNG
    python tools_build/export_fonts.py --no-atlas   # 只写清单，不落 PNG
    python tools_build/export_fonts.py --check      # 只校验清单与 Unity 侧一致（不写文件）
"""

import argparse
import json
import os
import re
import struct
import sys
import zlib

# ---------------------------------------------------------------- 路径

HERE = os.path.dirname(os.path.abspath(__file__))
PORT = os.path.dirname(HERE)                       # HaxePort/
REPO = os.path.dirname(PORT)                       # 仓库根
ASSETS = os.path.join(REPO, "Assets")

OUT_MANIFEST = os.path.join(PORT, "assets", "fonts_manifest.json")
OUT_ATLAS_DIR = os.path.join(PORT, "assets", "Fonts", "atlas")
# 相对 HaxePort/assets 的图集目录（写进清单，运行期按它取 PNG）
ATLAS_REL_DIR = "Fonts/atlas"

# TMP_FontAsset 的脚本 guid（Unity 包里的 TextMeshPro）：用来在 *.asset 里认出字体资产对象
TMP_FONTASSET_SCRIPT_GUIDS = {
    "71c1514a6bd24e1e882cebbe1904ce04",  # TMP_FontAsset
}

# 要导出的 TMP 字体资产（仓库相对路径，'Assets/...'）。前 5 个是本工程 prefab 里真正引用到的
# （见 assets/scene_prefabs/**/*.json 的 "font" 字段），后面两个是 TMP 自带的回退字体。
FONT_ASSET_GLOBS = [
    "Assets/Fonts/mojangles/minecraft_font.asset",
    "Assets/Fonts/mojangles/ascii.asset",
    "Assets/Fonts/mojangles/accented.asset",
    "Assets/Fonts/mojangles/nonlatin_european.asset",
    "Assets/Fonts/unifont.asset",
    "Assets/TextMesh Pro/Resources/Fonts & Materials/LiberationSans SDF.asset",
]


# ---------------------------------------------------------------- Unity YAML 小工具


def read_text(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def split_objects(text):
    """把 YAML 拆成 [(classId, fileID, body)]。

    Unity YAML 的锚点行形如 `--- !u!114 &11400000`，后跟类名行。
    """
    out = []
    for m in re.finditer(r"^--- !u!(\d+) &(-?\d+)\n(.*?)(?=^--- !u!|\Z)", text, re.M | re.S):
        out.append((int(m.group(1)), m.group(2), m.group(3)))
    return out


def get_int(body, key, default=None):
    m = re.search(r"^  %s: (-?\d+)\s*$" % re.escape(key), body, re.M)
    return int(m.group(1)) if m else default


def get_float(body, key, default=None):
    m = re.search(r"^  %s: (-?[\d.eE+-]+)\s*$" % re.escape(key), body, re.M)
    return float(m.group(1)) if m else default


def get_str(body, key, default=None):
    m = re.search(r"^  %s: (.*)$" % re.escape(key), body, re.M)
    return m.group(1).strip() if m else default


def get_indented_float(body, key, indent=4, default=None):
    m = re.search(r"^%s%s: (-?[\d.eE+-]+)\s*$" % (" " * indent, re.escape(key)), body, re.M)
    return float(m.group(1)) if m else default


# ---------------------------------------------------------------- guid -> 资产路径


def build_guid_index():
    """扫 Assets/**/*.meta 建 guid -> 仓库相对路径（'Assets/...'）。

    Unity 的资产引用只带 guid，运行期要落到真实文件就必须有这张表。扫描约 1.4 万个 meta，
    在 SSD 上 1~2 秒，可接受。
    """
    index = {}
    meta_re = re.compile(r"^guid: ([0-9a-fA-F]{32})\s*$", re.M)
    for root, dirs, files in os.walk(ASSETS):
        for fn in files:
            if not fn.endswith(".meta"):
                continue
            path = os.path.join(root, fn)
            try:
                with open(path, "r", encoding="utf-8", errors="replace") as f:
                    head = f.read(512)
            except OSError:
                continue
            m = meta_re.search(head)
            if not m:
                continue
            asset = path[: -len(".meta")]
            index[m.group(1)] = os.path.relpath(asset, REPO).replace("\\", "/")
    return index


# ---------------------------------------------------------------- OTF/TTF 度量（兜底）


def otf_metrics(path):
    """读 SFNT 的 head/hhea/OS2，给出 em 归一化的 ascent/descent/lineGap。

    用途：TMP 资产的 `m_SourceFontFile` 可能为 `{fileID: 0}`（例如 `ascii.asset`），
    此时 faceInfo 里仍然有 Unity 导入时算好的值；但为了交叉校验（并在 faceInfo 缺失时兜底），
    这里直接从字体文件读一遍。单位是「em 的倍数」，乘 pointSize 即得像素。
    """
    try:
        with open(path, "rb") as f:
            data = f.read()
    except OSError:
        return None
    if len(data) < 12:
        return None
    num = struct.unpack(">H", data[4:6])[0]
    tables = {}
    for i in range(num):
        off = 12 + i * 16
        if off + 16 > len(data):
            return None
        tag = data[off : off + 4].decode("latin1")
        _, o, l = struct.unpack(">III", data[off + 4 : off + 16])
        tables[tag] = (o, l)
    if "head" not in tables or "hhea" not in tables:
        return None
    ho, _ = tables["head"]
    upem = struct.unpack(">H", data[ho + 18 : ho + 20])[0]
    if upem == 0:
        return None
    ao, _ = tables["hhea"]
    asc, desc, gap = struct.unpack(">hhh", data[ao + 4 : ao + 10])
    num_h = struct.unpack(">H", data[ao + 34 : ao + 36])[0]
    res = {
        "unitsPerEm": upem,
        "ascent": asc / upem,
        "descent": desc / upem,
        "lineGap": gap / upem,
        "numHMetrics": num_h,
    }
    if "OS/2" in tables:
        oo, _ = tables["OS/2"]
        ver = struct.unpack(">H", data[oo : oo + 2])[0]
        ta, td, tg = struct.unpack(">hhh", data[oo + 68 : oo + 74])
        wa, wd = struct.unpack(">HH", data[oo + 74 : oo + 78])
        res["os2Version"] = ver
        res["typoAscender"] = ta / upem
        res["typoDescender"] = td / upem
        res["typoLineGap"] = tg / upem
        res["winAscent"] = wa / upem
        res["winDescent"] = wd / upem
        if ver >= 2:
            res["capHeight"] = struct.unpack(">h", data[oo + 88 : oo + 90])[0] / upem
            res["xHeight"] = struct.unpack(">h", data[oo + 86 : oo + 88])[0] / upem
    return res


# ---------------------------------------------------------------- 解析一个 TMP 字体资产

GLYPH_RE = re.compile(
    r"^  - m_Index: (\d+)\n"
    r"    m_Metrics:\n"
    r"      m_Width: (-?[\d.]+)\n"
    r"      m_Height: (-?[\d.]+)\n"
    r"      m_HorizontalBearingX: (-?[\d.]+)\n"
    r"      m_HorizontalBearingY: (-?[\d.]+)\n"
    r"      m_HorizontalAdvance: (-?[\d.]+)\n"
    r"    m_GlyphRect:\n"
    r"      m_X: (-?\d+)\n"
    r"      m_Y: (-?\d+)\n"
    r"      m_Width: (-?\d+)\n"
    r"      m_Height: (-?\d+)\n"
    r"    m_Scale: (-?[\d.]+)\n"
    r"    m_AtlasIndex: (-?\d+)",
    re.M,
)

CHAR_RE = re.compile(
    r"^  - m_ElementType: (\d+)\n"
    r"    m_Unicode: (\d+)\n"
    r"    m_GlyphIndex: (\d+)\n"
    r"    m_Scale: (-?[\d.]+)",
    re.M,
)


def parse_font_asset(rel_path, guid_index):
    """解析一个 TMP_FontAsset 的 *.asset，返回清单条目（dict）或 None。"""
    full = os.path.join(REPO, rel_path)
    if not os.path.exists(full):
        return None
    text = read_text(full)
    objs = split_objects(text)

    # ---- 1. 找 TMP_FontAsset 本体（MonoBehaviour + m_Script guid 命中）----
    font_body = None
    font_file_id = None
    for cls_id, file_id, body in objs:
        if cls_id != 114:
            continue
        m = re.search(r"^  m_Script: \{fileID: 11500000, guid: ([0-9a-f]{32}), type: 3\}", body, re.M)
        if not m:
            continue
        if m.group(1) in TMP_FONTASSET_SCRIPT_GUIDS:
            font_body = body
            font_file_id = file_id
            break
    if font_body is None:
        return None

    # ---- 2. 图集贴图（fileID -> 像素）----
    textures = {}
    for cls_id, file_id, body in objs:
        if cls_id != 28:
            continue
        w = get_int(body, "m_Width")
        h = get_int(body, "m_Height")
        fmt = get_int(body, "m_TextureFormat")
        nm = get_str(body, "m_Name") or ""
        m = re.search(r"^  _typelessdata: ([0-9a-fA-F]*)\s*$", body, re.M)
        raw = bytes.fromhex(m.group(1)) if m else b""
        textures[file_id] = {"name": nm, "width": w, "height": h, "format": fmt, "bytes": raw}

    # ---- 3. 图集引用顺序（m_AtlasTextures 的 fileID 列表 = atlasIndex 的语义）----
    atlas_ids = []
    m = re.search(r"^  m_AtlasTextures:\n((?:  - \{fileID: -?\d+\}\n)+)", font_body, re.M)
    if m:
        atlas_ids = re.findall(r"fileID: (-?\d+)", m.group(1))
    atlas_texture_index = get_int(font_body, "m_AtlasTextureIndex", 0)

    # ---- 4. FaceInfo ----
    face_body = re.search(r"^  m_FaceInfo:\n(.*?)\n  m_GlyphTable:", font_body, re.M | re.S)
    face_body = face_body.group(1) if face_body else ""
    face = {
        "faceIndex": get_indented_float(face_body, "m_FaceIndex", 4, 0),
        "familyName": (re.search(r"^    m_FamilyName: (.*)$", face_body, re.M) or [None, ""])[1]
        if re.search(r"^    m_FamilyName: (.*)$", face_body, re.M)
        else "",
        "styleName": (re.search(r"^    m_StyleName: (.*)$", face_body, re.M) or [None, ""])[1]
        if re.search(r"^    m_StyleName: (.*)$", face_body, re.M)
        else "",
    }
    for key, name in [
        ("m_PointSize", "pointSize"),
        ("m_Scale", "scale"),
        ("m_UnitsPerEM", "unitsPerEM"),
        ("m_LineHeight", "lineHeight"),
        ("m_AscentLine", "ascentLine"),
        ("m_CapLine", "capLine"),
        ("m_MeanLine", "meanLine"),
        ("m_Baseline", "baseline"),
        ("m_DescentLine", "descentLine"),
        ("m_SuperscriptOffset", "superscriptOffset"),
        ("m_SuperscriptSize", "superscriptSize"),
        ("m_SubscriptOffset", "subscriptOffset"),
        ("m_SubscriptSize", "subscriptSize"),
        ("m_UnderlineOffset", "underlineOffset"),
        ("m_UnderlineThickness", "underlineThickness"),
        ("m_StrikethroughOffset", "strikethroughOffset"),
        ("m_StrikethroughThickness", "strikethroughThickness"),
        ("m_TabWidth", "tabWidth"),
    ]:
        v = get_indented_float(face_body, key, 4)
        if v is not None:
            face[name] = v

    # ---- 5. 字形表 / 字符表 ----
    glyph_body = re.search(r"^  m_GlyphTable:\n(.*?)\n  m_CharacterTable:", font_body, re.M | re.S)
    glyphs = []
    if glyph_body:
        for g in GLYPH_RE.finditer(glyph_body.group(1)):
            glyphs.append(
                {
                    "index": int(g.group(1)),
                    "metrics": {
                        "width": float(g.group(2)),
                        "height": float(g.group(3)),
                        "bearingX": float(g.group(4)),
                        "bearingY": float(g.group(5)),
                        "advance": float(g.group(6)),
                    },
                    "rect": {
                        "x": int(g.group(7)),
                        "y": int(g.group(8)),
                        "width": int(g.group(9)),
                        "height": int(g.group(10)),
                    },
                    "scale": float(g.group(11)),
                    "atlasIndex": int(g.group(12)),
                }
            )

    char_body = re.search(r"^  m_CharacterTable:\n(.*?)\n  m_AtlasTextures:", font_body, re.M | re.S)
    chars = []
    if char_body:
        for c in CHAR_RE.finditer(char_body.group(1)):
            chars.append(
                {
                    "elementType": int(c.group(1)),
                    "unicode": int(c.group(2)),
                    "glyphIndex": int(c.group(3)),
                    "scale": float(c.group(4)),
                }
            )

    # ---- 6. 源字体文件 / 回退链 / 其它字段 ----
    def asset_ref(prefix):
        m = re.search(
            r"^  %s: \{fileID: (-?\d+), guid: ([0-9a-f]{32}), type: 3\}" % re.escape(prefix),
            font_body,
            re.M,
        )
        if not m:
            return None
        fid, g = m.group(1), m.group(2)
        return {"fileID": fid, "guid": g, "path": guid_index.get(g)}

    src_guid = get_str(font_body, "m_SourceFontFileGUID")
    fallbacks = []
    m = re.search(r"^  m_FallbackFontAssetTable:\n((?:  - \{[^}]*\}\n?)+)", font_body, re.M)
    if m:
        for g in re.findall(r"guid: ([0-9a-f]{32})", m.group(1)):
            fallbacks.append({"guid": g, "path": guid_index.get(g)})

    # ---- 7. 图集 PNG 落盘信息 ----
    atlas_list = []
    for idx, tid in enumerate(atlas_ids):
        tex = textures.get(tid)
        if tex is None:
            continue
        png_name = "%s_%s.png" % (
            os.path.splitext(os.path.basename(rel_path))[0],
            re.sub(r"[^0-9A-Za-z]+", "_", tex["name"]).strip("_").lower(),
        )
        atlas_list.append(
            {
                "atlasIndex": idx,
                "fileID": tid,
                "name": tex["name"],
                "width": tex["width"],
                "height": tex["height"],
                # Unity TextureFormat.Alpha8 = 1（单字节 alpha，行主序，第 0 行是顶部）
                "textureFormat": tex["format"],
                "png": "%s/%s" % (ATLAS_REL_DIR, png_name),
                "pngPath": "%s/%s" % (ATLAS_REL_DIR, png_name),
            }
        )

    otf = asset_ref("m_SourceFontFile")
    entry = {
        "name": get_str(font_body, "m_Name") or os.path.splitext(os.path.basename(rel_path))[0],
        "guid": None,  # 由调用方用 meta 补
        "fileID": font_file_id,
        "assetPath": rel_path,
        "assetId": "assets/" + rel_path,
        "version": get_str(font_body, "m_Version"),
        # m_AtlasPopulationMode: 0 = Static（字形已烘焙进图集）、1 = Dynamic（运行时从 OTF 光栅化）
        "atlasPopulationMode": get_int(font_body, "m_AtlasPopulationMode", 0),
        "isMultiAtlasTexturesEnabled": bool(get_int(font_body, "m_IsMultiAtlasTexturesEnabled", 0)),
        "atlasWidth": get_int(font_body, "m_AtlasWidth"),
        "atlasHeight": get_int(font_body, "m_AtlasHeight"),
        "atlasPadding": get_int(font_body, "m_AtlasPadding"),
        "atlasRenderMode": get_int(font_body, "m_AtlasRenderMode"),
        "atlasTextureIndex": atlas_texture_index,
        "atlasTextures": atlas_list,
        "faceInfo": face,
        "sourceFontFile": otf,
        "sourceFontFileGUID": src_guid,
        "fallbackFontAssets": fallbacks,
        "glyphs": glyphs,
        "characters": chars,
        "material": asset_ref("material"),
        "otfMetrics": otf_metrics(os.path.join(REPO, otf["path"])) if otf and otf.get("path") else None,
    }
    return entry


# ---------------------------------------------------------------- Alpha8 -> PNG


def write_png(path, width, height, alpha_bytes):
    """把 TextureFormat.Alpha8 的字节写成 32 位 RGBA PNG（RGB=255，A=原值）。

    纯标准库实现（zlib + struct），不依赖 Pillow：本机 Python 环境不保证有 Pillow，
    而构建脚本必须开箱即用（与 tools_build/analyze_shot.py 的自写 PNG 解码器一致）。
    """
    stride = width * 4
    raw = bytearray()
    for y in range(height):
        raw.append(0)  # filter type 0 (None)
        base = y * width
        row = alpha_bytes[base : base + width]
        if len(row) < width:
            row = row + b"\x00" * (width - len(row))
        # 展开成 RGBA
        for a in row:
            raw += b"\xff\xff\xff"
            raw.append(a)

    def chunk(tag, data):
        out = struct.pack(">I", len(data)) + tag + data
        out += struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        return out

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", ihdr)
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(png)
    return len(png)


# ---------------------------------------------------------------- 主流程


def collect_font_paths():
    """列出要导出的 TMP 字体资产（仓库相对路径）。"""
    out = []
    for rel in FONT_ASSET_GLOBS:
        if os.path.exists(os.path.join(REPO, rel)):
            out.append(rel)
    return out


def main():
    ap = argparse.ArgumentParser(description="导出 TMP 字体资产为 fonts_manifest.json")
    ap.add_argument("--no-atlas", action="store_true", help="不写图集 PNG，只写清单")
    ap.add_argument("--check", action="store_true", help="只校验（不写文件），清单缺失/不一致时退出码 1")
    ap.add_argument("--out", default=OUT_MANIFEST, help="清单输出路径")
    args = ap.parse_args()

    print("== export_fonts.py ==")
    print("repo   =", REPO)
    guid_index = build_guid_index()
    print("guid 索引条目 =", len(guid_index))

    # TMP 字体资产的 guid（meta）反查
    font_paths = collect_font_paths()
    if not font_paths:
        print("!! 没找到任何 TMP 字体资产", file=sys.stderr)
        return 2

    fonts = []
    for rel in font_paths:
        entry = parse_font_asset(rel, guid_index)
        if entry is None:
            print("!! 解析失败（不是 TMP_FontAsset？）：", rel, file=sys.stderr)
            continue
        meta = os.path.join(REPO, rel + ".meta")
        if os.path.exists(meta):
            m = re.search(r"^guid: ([0-9a-fA-F]{32})\s*$", read_text(meta), re.M)
            if m:
                entry["guid"] = m.group(1)
        fonts.append(entry)
        print(
            "  %-45s guid=%s glyphs=%d chars=%d atlas=%d popMode=%s"
            % (
                rel,
                entry["guid"],
                len(entry["glyphs"]),
                len(entry["characters"]),
                len(entry["atlasTextures"]),
                entry["atlasPopulationMode"],
            )
        )

    # 索引：guid -> 字体、assetPath -> 字体、sourceFontFileGUID -> 字体
    by_guid = {}
    by_source_guid = {}
    for f in fonts:
        if f["guid"]:
            by_guid[f["guid"]] = f["assetPath"]
        if f["sourceFontFileGUID"]:
            by_source_guid[f["sourceFontFileGUID"]] = f["assetPath"]

    # 每个字体的「字形覆盖率」摘要（诊断：动态字体的图集是空的，必须靠 OTF 路线）
    for f in fonts:
        rects = [g for g in f["glyphs"] if g["rect"]["width"] > 0 and g["rect"]["height"] > 0]
        f["stats"] = {
            "glyphCount": len(f["glyphs"]),
            "characterCount": len(f["characters"]),
            "glyphsWithRect": len(rects),
        }

    manifest = {
        "version": 1,
        "generatedBy": "HaxePort/tools_build/export_fonts.py",
        "source": "Assets/Fonts/**/*.asset（Unity TMP_FontAsset）",
        # 图集 PNG 相对 HaxePort/assets 的目录
        "atlasRoot": ATLAS_REL_DIR,
        # 本工程 prefab 里实际引用到的字体资产 guid（见 scene_prefabs/**/*.json 的 "font" 字段）
        "fonts": fonts,
        "byGuid": by_guid,
        "bySourceFontFileGuid": by_source_guid,
        "stats": {
            "fontCount": len(fonts),
            "totalGlyphs": sum(len(f["glyphs"]) for f in fonts),
            "totalCharacters": sum(len(f["characters"]) for f in fonts),
            "totalAtlasTextures": sum(len(f["atlasTextures"]) for f in fonts),
        },
    }

    if args.check:
        if not os.path.exists(args.out):
            print("!! 清单不存在：", args.out, file=sys.stderr)
            return 1
        old = json.loads(read_text(args.out))
        same = old.get("stats") == manifest["stats"]
        print("校验：清单 stats=%s 现场 stats=%s -> %s" % (old.get("stats"), manifest["stats"], "一致" if same else "不一致"))
        return 0 if same else 1

    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1, sort_keys=False)
    print("写出清单：", args.out, os.path.getsize(args.out), "B")

    if args.no_atlas:
        print("（--no-atlas：跳过图集 PNG）")
        return 0

    # 图集 PNG
    written = 0
    total = 0
    for rel in font_paths:
        text = read_text(os.path.join(REPO, rel))
        objs = split_objects(text)
        tex = {}
        for cls_id, file_id, body in objs:
            if cls_id != 28:
                continue
            w = get_int(body, "m_Width")
            h = get_int(body, "m_Height")
            m = re.search(r"^  _typelessdata: ([0-9a-fA-F]*)\s*$", body, re.M)
            raw = bytes.fromhex(m.group(1)) if m else b""
            tex[file_id] = (get_str(body, "m_Name") or "", w, h, raw)
        for cls_id, file_id, body in objs:
            if cls_id != 114:
                continue
            m = re.search(r"^  m_AtlasTextures:\n((?:  - \{fileID: -?\d+\}\n)+)", body, re.M)
            if not m:
                continue
            for tid in re.findall(r"fileID: (-?\d+)", m.group(1)):
                if tid not in tex:
                    continue
                nm, w, h, raw = tex[tid]
                if not w or not h or len(raw) != w * h:
                    print("   跳过图集（尺寸/字节数不符）：%s %dx%d bytes=%d" % (nm, w, h, len(raw)))
                    continue
                png_name = "%s_%s.png" % (
                    os.path.splitext(os.path.basename(rel))[0],
                    re.sub(r"[^0-9A-Za-z]+", "_", nm).strip("_").lower(),
                )
                out = os.path.join(OUT_ATLAS_DIR, png_name)
                n = write_png(out, w, h, raw)
                written += 1
                total += n
                print("   图集 PNG：%s  %dx%d  %d B" % (os.path.relpath(out, PORT), w, h, n))
    print("图集 PNG：%d 张，共 %d B" % (written, total))
    return 0


if __name__ == "__main__":
    sys.exit(main())
