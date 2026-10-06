#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MVZ2 Unity -> HaxeFlixel 移植：精灵/图集清单生成器（工作包 ③）

从 Unity 工程（<project root>/Assets）导出精灵定义到
`HaxePort/assets/sprites_manifest.json`，供 `mvz2.sprites.SpriteManifestLoader`
在运行期重建原工程的 SpriteManifest / GeneratedSpriteManifest 数据。

Unity 侧的数据来源（全部为原始工程文件，不做任何发明）：
  1. Addressables 分组资产  Assets/AddressableAssetsData/AssetGroups/*.asset
       → 每个条目的 guid + address + labels。"Sprite" 标签的条目即单帧精灵，
         "Spritesheet" 标签的条目即多帧精灵图集（Sprite[]）。
  2. *.meta 文件（guid 索引）
       → guid → 资产路径，用于把 Addressables 条目解析到真实贴图。
  3. 贴图 *.png.meta / *.jpg.meta
       → spriteMode / spritePixelsToUnits / alignment / spritePivot /
         spriteSheet.sprites[].{name,rect,pivot,alignment,internalID}。
  4. Assets/GameContent/Assets/mvz2/spritemanifests/**/*.asset (SpriteManifest)
       → 显式的 name → sprite(guid,fileID) / name → spritesheet(有序 fileID 列表)。
  5. Assets/GameContent/spriteatlases/*.spriteatlasv2
       → packables（文件夹 guid 列表），用于记录每个精灵属于哪些图集。
  6. HaxePort/assets/resource_manifest.json（工作包 ① 的产物，若存在）
       → 地址 -> 贴图路径 / kind 的唯一来源。本脚本据此为每个精灵记录 resourcePath，
         并校验两份清单的地址集合与路径一致性；运行期由 SpriteManifestLoader 同样以它为准。
         该清单由 HaxePort/tools_build/build_manifest.py 生成，需先于本脚本运行。

用法：
  python HaxePort/tools_build/convert_sprites.py [--project-root .] [--out HaxePort/assets/sprites_manifest.json]
"""

import argparse
import datetime
import json
import os
import re
import sys

GUID_RE = re.compile(r"^guid: ([0-9a-f]{32})$", re.M)
SPRITE_ADDR_RE = re.compile(r"m_Address: (.*)")
# Unity 对「单帧贴图」子资源使用的固定 fileID。
SINGLE_SPRITE_FILE_ID = 21300000

# TextureImporter/spriteSheet 的 alignment 整数取值 -> 归一化 pivot。
# 参见 Unity 文档 TextureImporterSettings.spriteAlignment：
#   "Center = 0, TopLeft = 1, TopCenter = 2, TopRight = 3, LeftCenter = 4,
#    RightCenter = 5, BottomLeft = 6, BottomCenter = 7, BottomRight = 8, Custom = 9"
# 证据（本工程内）：Assets/GameContent/Assets/mvz2/areamodels/{ship,palace}.prefab
# 的 SpriteRenderer 位置只有在「alignment 生效、Custom(9) 才用 spritePivot」时才能
# 恰好拼出 14 x 10.2 的关卡区域（palace.png 14x10.2 @(0,0) alignment=6 -> 铺满 (0,0)-(14,10.2)）。
ALIGNMENT_PIVOT = {
    0: (0.5, 0.5),   # Center
    1: (0.0, 1.0),   # TopLeft
    2: (0.5, 1.0),   # TopCenter
    3: (1.0, 1.0),   # TopRight
    4: (0.0, 0.5),   # LeftCenter
    5: (1.0, 0.5),   # RightCenter
    6: (0.0, 0.0),   # BottomLeft
    7: (0.5, 0.0),   # BottomCenter
    8: (1.0, 0.0),   # BottomRight
}
CUSTOM_ALIGNMENT = 9


def effective_pivot(alignment, raw_pivot):
    """Unity 的实际 pivot：alignment 非 Custom 时由 alignment 推导，Custom(9) 时用序列化 pivot。"""
    if alignment == CUSTOM_ALIGNMENT:
        return dict(raw_pivot)
    p = ALIGNMENT_PIVOT.get(alignment)
    return {"x": p[0], "y": p[1]} if p else dict(raw_pivot)


def read_text(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def png_size(path):
    """读取 PNG/JPG 尺寸。PNG 走 IHDR，JPG 走 SOFn 标记。"""
    with open(path, "rb") as f:
        head = f.read(32)
        if head[:8] == b"\x89PNG\r\n\x1a\n":
            w = int.from_bytes(head[16:20], "big")
            h = int.from_bytes(head[20:24], "big")
            return w, h
        if head[:2] == b"\xff\xd8":
            f.seek(2)
            data = f.read()
            i = 0
            while i < len(data) - 9:
                if data[i] != 0xFF:
                    i += 1
                    continue
                marker = data[i + 1]
                if marker in (0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7,
                              0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF):
                    h = int.from_bytes(data[i + 5:i + 7], "big")
                    w = int.from_bytes(data[i + 7:i + 9], "big")
                    return w, h
                if marker in (0xD8, 0xD9) or 0xD0 <= marker <= 0xD7:
                    i += 2
                    continue
                seglen = int.from_bytes(data[i + 2:i + 4], "big")
                i += 2 + seglen
    raise ValueError("unsupported image: %s" % path)


def num(s):
    """Unity YAML 里 0.5 / 48.5 / -3 都可能是浮点字面量。"""
    v = float(s)
    if v == int(v):
        return int(v)
    return v


# ---------------------------------------------------------------- guid 索引

def index_meta(root):
    """遍历 Assets/ 下所有 *.meta，返回 guid -> 资产绝对路径。"""
    guid2path = {}
    for dirpath, _dirnames, filenames in os.walk(root):
        for fn in filenames:
            if not fn.endswith(".meta"):
                continue
            p = os.path.join(dirpath, fn)
            try:
                m = GUID_RE.search(read_text(p)[:400])
            except OSError:
                continue
            if m:
                guid2path[m.group(1)] = p[: -len(".meta")]
    return guid2path


# ------------------------------------------------------- 贴图 .meta 解析

def parse_texture_meta(meta_path, guid):
    text = read_text(meta_path)

    def field(name, default=None):
        m = re.search(r"^  %s: (.+)$" % name, text, re.M)
        return m.group(1).strip() if m else default

    mode = int(field("spriteMode", "1"))
    ppu = float(field("spritePixelsToUnits", "100"))
    alignment = int(field("alignment", "0"))
    m = re.search(r"^  spritePivot: \{x: ([-\d.eE]+), y: ([-\d.eE]+)\}", text, re.M)
    raw_pivot = {"x": float(m.group(1)), "y": float(m.group(2))} if m else {"x": 0.5, "y": 0.5}
    pivot = effective_pivot(alignment, raw_pivot)

    slices = []
    # spriteSheet 段位于文件末尾（`  spriteSheet:`，两个空格缩进），其后再无同级的 TextureImporter 字段。
    idx = text.rfind("\n  spriteSheet:")
    if idx >= 0:
        tail = text[idx:]
        for block in tail.split("    - serializedVersion: 2")[1:]:
            name_m = re.search(r"^      name: (.*)$", block, re.M)
            rect_m = re.search(
                r"      rect:\n        serializedVersion: 2\n"
                r"        x: ([-\d.eE]+)\n        y: ([-\d.eE]+)\n"
                r"        width: ([-\d.eE]+)\n        height: ([-\d.eE]+)",
                block)
            piv_m = re.search(r"      pivot: \{x: ([-\d.eE]+), y: ([-\d.eE]+)\}", block)
            align_m = re.search(r"^      alignment: (-?\d+)$", block, re.M)
            iid_m = re.search(r"^      internalID: (-?\d+)$", block, re.M)
            sid_m = re.search(r"^      spriteID: ([0-9a-f]+)$", block, re.M)
            if rect_m is None or iid_m is None:
                continue
            slices.append({
                "name": name_m.group(1).strip() if name_m else None,
                "rect": {
                    "x": num(rect_m.group(1)), "y": num(rect_m.group(2)),
                    "width": num(rect_m.group(3)), "height": num(rect_m.group(4)),
                },
                "pivot": effective_pivot(
                    int(align_m.group(1)) if align_m else 0,
                    {"x": float(piv_m.group(1)), "y": float(piv_m.group(2))} if piv_m else {"x": 0.0, "y": 0.0}),
                "pivotRaw": {"x": float(piv_m.group(1)), "y": float(piv_m.group(2))} if piv_m else {"x": 0.0, "y": 0.0},
                "alignment": int(align_m.group(1)) if align_m else 0,
                "spriteID": sid_m.group(1) if sid_m else None,
                "internalID": int(iid_m.group(1)),
            })

    return {
        "guid": guid,
        "spriteMode": mode,
        "pixelsPerUnit": ppu,
        "alignment": alignment,
        "pivot": pivot,
        "pivotRaw": raw_pivot,
        "slices": slices,
    }


# --------------------------------------------------- Addressables 分组解析

def parse_addressables(root):
    """返回 (条目列表, 分组资产路径->分组名)。条目 = {guid,address,labels,group}。"""
    entries = []
    groups_dir = os.path.join(root, "AddressableAssetsData", "AssetGroups")
    if not os.path.isdir(groups_dir):
        return entries
    for fn in sorted(os.listdir(groups_dir)):
        if not fn.endswith(".asset"):
            continue
        path = os.path.join(groups_dir, fn)
        text = read_text(path)
        if "m_SerializeEntries:" not in text:
            continue  # Built In Data.asset 之类没有条目
        group = fn[: -len(".asset")]
        for block in text.split("m_SerializeEntries:")[1].split("  - m_GUID: ")[1:]:
            guid = block.split("\n")[0].strip()
            if not re.fullmatch(r"[0-9a-f]{32}", guid):
                continue
            addr_m = SPRITE_ADDR_RE.search(block)
            labels_m = re.search(r"m_SerializedLabels:\n((?:    - .*\n)*)", block)
            labels = []
            if labels_m:
                labels = [ln.strip("- \r\n") for ln in labels_m.group(1).split("\n") if ln.strip()]
            entries.append({
                "group": group,
                "guid": guid,
                "address": addr_m.group(1).strip() if addr_m else None,
                "labels": labels,
            })
    return entries


def split_namespace(address, default_nsp):
    """`mvz2:achievements/bonebreaker` -> ('mvz2', 'achievements/bonebreaker')。"""
    if address and ":" in address:
        nsp, path = address.split(":", 1)
        return nsp, path
    return default_nsp, address


# ------------------------------------------------- SpriteManifest 资产解析

def parse_sprite_manifest_assets(root, guid2path):
    """解析 Assets/**/spritemanifests/**/*.asset（SpriteManifest ScriptableObject）。"""
    manifests = []
    for dirpath, _dirnames, filenames in os.walk(root):
        if "spritemanifests" not in dirpath.split(os.sep):
            continue
        for fn in filenames:
            if not fn.endswith(".asset"):
                continue
            path = os.path.join(dirpath, fn)
            text = read_text(path)
            if "spriteEntries:" not in text or "spritesheetEntries:" not in text:
                continue
            if "m_Script" not in text:
                continue
            i = text.index("spriteEntries:")
            j = text.index("spritesheetEntries:")
            sprite_entries = [
                {"name": name, "fileID": int(fid), "guid": guid}
                for name, fid, guid in re.findall(
                    r"- name: (.*)\n    sprite: \{fileID: (-?\d+), guid: ([0-9a-f]{32}), type: 3\}",
                    text[i:j])
            ]
            sheet_entries = []
            for name, body in re.findall(
                    r"- name: (.*)\n    spritesheet:\n((?:    - \{[^\n]*\n)*)", text[j:]):
                refs = [(int(fid), guid) for fid, guid in
                        re.findall(r"fileID: (-?\d+), guid: ([0-9a-f]{32})", body)]
                sheet_entries.append({"name": name, "refs": refs})
            manifests.append({
                "assetPath": path,
                "spriteEntries": sprite_entries,
                "spritesheetEntries": sheet_entries,
            })
    return manifests


# ------------------------------------------------------ spriteatlasv2 解析

def parse_sprite_atlases(root, guid2path):
    atlases = {}
    atlas_dir = os.path.join(root, "GameContent", "spriteatlases")
    if not os.path.isdir(atlas_dir):
        return atlases
    for fn in sorted(os.listdir(atlas_dir)):
        if not fn.endswith(".spriteatlasv2"):
            continue
        path = os.path.join(atlas_dir, fn)
        text = read_text(path)
        name = os.path.splitext(fn)[0]
        packables = []
        for guid, _typ in re.findall(r"guid: ([0-9a-f]{32}), type: (\d+)", text):
            target = guid2path.get(guid)
            packables.append({"guid": guid, "path": target})
        atlases[name] = {
            "assetPath": os.path.relpath(path, root).replace("\\", "/"),
            "packables": packables,
        }
    return atlases


# ------------------------------------------------------------------ 主流程

def load_resource_manifest(path, project_root="."):
    """读取工作包 ① 的 assets/resource_manifest.json，返回 address -> path 的映射与清单信息。

    移植层的「地址 -> 资产路径」只保留这一份来源（生成器 tools_build/build_manifest.py）；
    本脚本只提供「地址 -> 帧矩形/pivot/像素比」，因此这里做衔接与一致性校验。
    """
    if not os.path.exists(path):
        return None, None
    data = json.load(open(path, encoding="utf-8"))
    paths = {}
    addresses = data.get("addresses")
    if isinstance(addresses, dict):
        for addr, info in addresses.items():
            if isinstance(info, dict) and info.get("path"):
                paths[addr] = info["path"]
    if not paths and isinstance(data.get("entries"), list):
        for e in data["entries"]:
            if isinstance(e, dict) and e.get("address") and e.get("path"):
                paths[e["address"]] = e["path"]
    info = {
        "file": os.path.relpath(os.path.abspath(path), os.path.abspath(project_root)).replace("\\", "/"),
        "generatedBy": data.get("generatedBy"),
        "addressCount": len(paths),
        "entryCount": data.get("entryCount"),
    }
    return paths, info


def build(project_root, out_path, resource_manifest_path=None):
    assets_root = os.path.join(project_root, "Assets")
    if not os.path.isdir(assets_root):
        raise SystemExit("找不到 Assets 目录：%s" % assets_root)

    guid2path = index_meta(assets_root)

    # 1) 所有贴图的 .meta 定义（png / jpg）
    textures = {}
    for guid, path in guid2path.items():
        if not (path.endswith(".png") or path.endswith(".jpg")):
            continue
        if path.endswith(".spriteatlasv2"):
            continue
        meta_path = path + ".meta"
        if not os.path.exists(meta_path):
            continue
        if "textureType" not in read_text(meta_path)[:4000]:
            continue  # 不是 TextureImporter 的 .meta（例如 spriteatlasv2 的）
        rel = os.path.relpath(path, assets_root).replace("\\", "/")
        try:
            width, height = png_size(path)
        except (OSError, ValueError):
            width, height = 0, 0
        info = parse_texture_meta(meta_path, guid)
        info.update({
            "unityPath": "Assets/" + rel,
            "assetPath": rel,
            "width": width,
            "height": height,
        })
        textures[guid] = info

    # 2) Addressables 条目
    entries = parse_addressables(assets_root)
    default_nsp = "mvz2"
    sprite_entries = [e for e in entries if "Sprite" in e["labels"]]
    sheet_entries = [e for e in entries if "Spritesheet" in e["labels"]]

    # 3) SpriteManifest 资产：显式 name -> sprite / spritesheet 映射
    #    同时记录每个名字属于哪些 SpriteManifest（决定它随 Init 还是 Main 加载）。
    manifests = parse_sprite_manifest_assets(assets_root, guid2path)
    manifest_sprites = {}   # name -> (guid, fileID)
    manifest_sheets = {}    # name -> [fileID,...]
    entry_by_asset_path = {}
    for e in entries:
        p = guid2path.get(e["guid"])
        if p:
            entry_by_asset_path[os.path.abspath(p).replace("\\", "/")] = e
    manifest_membership = {}  # name -> {"address":..., "labels":[...]} 所属 SpriteManifest
    manifest_infos = []
    for man in manifests:
        abs_path = os.path.abspath(man["assetPath"]).replace("\\", "/")
        info = entry_by_asset_path.get(abs_path)
        manifest_infos.append({
            "assetPath": "Assets/" + os.path.relpath(man["assetPath"], assets_root).replace("\\", "/"),
            "assetAssetPath": os.path.relpath(man["assetPath"], assets_root).replace("\\", "/"),
            "address": info["address"] if info else None,
            "labels": info["labels"] if info else [],
            "spriteEntryCount": len(man["spriteEntries"]),
            "spritesheetEntryCount": len(man["spritesheetEntries"]),
        })
        membership = {
            "manifest": info["address"] if info else None,
            "manifestLabels": info["labels"] if info else [],
        }
        for e in man["spriteEntries"]:
            manifest_sprites.setdefault(e["name"], (e["guid"], e["fileID"]))
            manifest_membership.setdefault(e["name"], membership)
        for e in man["spritesheetEntries"]:
            manifest_sheets.setdefault(e["name"], [fid for fid, _g in e["refs"]])
            manifest_membership.setdefault(e["name"], membership)

    # 4) 单帧精灵
    sprites = {}
    warnings = []

    def add_single_sprite(nsp, path, guid, group, labels, source, manifest_labels=None):
        tex = textures.get(guid)
        if tex is None:
            warnings.append("精灵 %s:%s 的贴图（guid=%s）没有 TextureImporter .meta" % (nsp, path, guid))
            return
        slices = tex["slices"]
        if tex["spriteMode"] == 1 or not slices:
            rect = {"x": 0, "y": 0, "width": tex["width"], "height": tex["height"]}
            pivot = dict(tex["pivot"])
            pivot_raw = dict(tex["pivotRaw"])
            alignment = tex["alignment"]
            spr_name = os.path.splitext(os.path.basename(tex["unityPath"]))[0]
        else:
            # 多帧贴图被整体当作单帧引用（本项目不存在，保留兜底）。
            s = slices[0]
            rect, pivot, pivot_raw, alignment = s["rect"], dict(s["pivot"]), dict(s["pivotRaw"]), s["alignment"]
            spr_name = s["name"] or path
            warnings.append("精灵 %s:%s 指向 spriteMode=2 的贴图，已取第一帧" % (nsp, path))
        membership = manifest_membership.get(path)
        entry = {
            "id": "%s:%s" % (nsp, path),
            "namespace": nsp,
            "path": path,
            "name": spr_name,
            "texture": guid,
            "rect": rect,
            "pivot": pivot,
            "pivotRaw": pivot_raw,
            "alignment": alignment,
            "pixelsPerUnit": tex["pixelsPerUnit"],
            "group": group,
            "labels": labels,
            "manifest": membership["manifest"] if membership else None,
            "manifestLabels": (membership["manifestLabels"] if membership
                               else [l for l in labels if l in ("Init", "Main")]),
            "atlases": [],
            "sources": [source],
        }
        prev = sprites.get(path)
        if prev is not None:
            # 同一路径同时出现在 Addressables 与 SpriteManifest 中：保留 Addressables 的
            # group/labels，manifest 信息取任一非空来源。
            entry["group"] = prev["group"]
            entry["labels"] = prev["labels"]
            if not entry["manifest"]:
                entry["manifest"] = prev["manifest"]
                entry["manifestLabels"] = prev["manifestLabels"]
            entry["sources"] = sorted(set(prev["sources"] + [source]))
        sprites[path] = entry

    addr_by_path = {}
    for e in entries:
        p = guid2path.get(e["guid"])
        if p and e["address"]:
            nsp, path = split_namespace(e["address"], default_nsp)
            addr_by_path.setdefault(path, e)

    for e in sprite_entries:
        target = guid2path.get(e["guid"])
        if target is None:
            warnings.append("Addressables 条目 %s 的 guid 无法解析到资产" % e["address"])
            continue
        nsp, path = split_namespace(e["address"], default_nsp)
        add_single_sprite(nsp, path, e["guid"], e["group"], e["labels"], "addressable")

    for name, (guid, file_id) in manifest_sprites.items():
        # 只出现在 SpriteManifest 中（Addressables 里没有 Sprite 标签）的精灵。
        info = addr_by_path.get(name)
        nsp = default_nsp
        group = info["group"] if info else nsp
        labels = info["labels"] if info else []
        add_single_sprite(nsp, name, guid, group, labels, "manifest")

    # 5) 精灵图集（Sprite[]）
    sheets = {}
    for e in sheet_entries:
        target = guid2path.get(e["guid"])
        if target is None:
            warnings.append("图集条目 %s 的 guid 无法解析到资产" % e["address"])
            continue
        nsp, path = split_namespace(e["address"], default_nsp)
        tex = textures.get(e["guid"])
        if tex is None:
            warnings.append("图集 %s:%s 没有 TextureImporter .meta" % (nsp, path))
            continue
        by_id = {s["internalID"]: s for s in tex["slices"]}
        order = manifest_sheets.get(path)
        slices = []
        if order:
            for iid in order:
                s = by_id.get(iid)
                if s is None:
                    warnings.append("图集 %s:%s 的帧 internalID=%s 在贴图 .meta 中不存在" % (nsp, path, iid))
                    continue
                slices.append(s)
        else:
            slices = list(tex["slices"])
            warnings.append("图集 %s:%s 未在 SpriteManifest 中出现，帧顺序取自贴图 .meta" % (nsp, path))
        membership = manifest_membership.get(path)
        sheets[path] = {
            "id": "%s:%s" % (nsp, path),
            "namespace": nsp,
            "path": path,
            "name": os.path.splitext(os.path.basename(tex["unityPath"]))[0],
            "texture": e["guid"],
            "group": e["group"],
            "labels": e["labels"],
            "manifest": membership["manifest"] if membership else None,
            "manifestLabels": (membership["manifestLabels"] if membership
                               else [l for l in e["labels"] if l in ("Init", "Main")]),
            "atlases": [],
            "sources": ["addressable", "manifest"],
            "sliceOrder": "manifest" if order else "meta",
            "texturePivot": dict(tex["pivot"]),
            "texturePivotRaw": dict(tex["pivotRaw"]),
            "textureAlignment": tex["alignment"],
            "slices": [{
                "name": s["name"],
                "rect": s["rect"],
                "pivot": dict(s["pivot"]),
                "pivotRaw": dict(s["pivotRaw"]),
                "alignment": s["alignment"],
                "pixelsPerUnit": tex["pixelsPerUnit"],
                "spriteID": s["spriteID"],
                "internalID": s["internalID"],
                # internalID 可能是 64 位（超过 JSON 数字在 32 位运行期的精度），
                # 另存一份十进制字符串供 Haxe 侧无损读取。
                "internalIDString": str(s["internalID"]),
            } for s in slices],
        }

    # 6) 图集成员关系（spriteatlasv2 的 packables 是文件夹，按贴图所在目录归属）
    atlases = parse_sprite_atlases(assets_root, guid2path)
    for atlas_name, atlas in atlases.items():
        folders = [os.path.abspath(p["path"]).replace("\\", "/") + "/"
                   for p in atlas["packables"] if p["path"]]
        sprite_ids, sheet_ids = [], []
        for path, spr in sprites.items():
            tex_path = os.path.abspath(textures[spr["texture"]]["unityPath"]).replace("\\", "/")
            if any(tex_path.startswith(f) for f in folders):
                spr["atlases"].append(atlas_name)
                sprite_ids.append(spr["id"])
        for path, sheet in sheets.items():
            tex_path = os.path.abspath(textures[sheet["texture"]]["unityPath"]).replace("\\", "/")
            if any(tex_path.startswith(f) for f in folders):
                sheet["atlases"].append(atlas_name)
                sheet_ids.append(sheet["id"])
        atlas["unresolvedPackables"] = [
            p["guid"] for p in atlas["packables"] if not p["path"]
        ]
        atlas["sprites"] = sorted(sprite_ids)
        atlas["spriteSheets"] = sorted(sheet_ids)
        atlas["packableFolders"] = sorted(
            os.path.relpath(p["path"], assets_root).replace("\\", "/")
            for p in atlas["packables"] if p["path"]
        )

    # 8) 与工作包 ① 的资产清单衔接（地址 -> 贴图路径以它为准）
    res_paths, res_info = (load_resource_manifest(resource_manifest_path, project_root)
                          if resource_manifest_path else (None, None))
    resource_join = None
    if res_paths is not None:
        matched = 0
        missing = []
        mismatched = []
        not_image = []
        for entry in list(sprites.values()) + list(sheets.values()):
            target = res_paths.get(entry["id"])
            entry["resourcePath"] = target
            if target is None:
                missing.append(entry["id"])
                continue
            matched += 1
            expected = textures[entry["texture"]]["assetPath"] if entry["texture"] in textures else None
            if expected is not None and target != expected:
                mismatched.append({"id": entry["id"], "resourceManifest": target, "spriteManifest": expected})
        resource_join = dict(res_info)
        resource_join.update({
            "matched": matched,
            "missing": sorted(missing),
            "pathMismatch": mismatched,
        })
        if missing:
            warnings.append("① 的 asset 清单里没有这些精灵地址：%s" % sorted(missing)[:5])
        if mismatched:
            warnings.append("① 的 asset 清单与精灵清单的贴图路径不一致：%d 条" % len(mismatched))
    else:
        for entry in list(sprites.values()) + list(sheets.values()):
            entry["resourcePath"] = None
        warnings.append("未找到 ① 的 resource_manifest.json，resourcePath 留空"
                        "（运行期会回退到本清单的 assetPath）。")

    # 9) 输出
    out = {
        "formatVersion": 1,
        "generatedBy": "HaxePort/tools_build/convert_sprites.py",
        "generatedAt": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
        "sourceProject": "Assets/",
        "assetRoot": "assets/",
        "namespace": default_nsp,
        "notes": {
            "coordinate": ("rect 为贴图内的像素矩形，pivot 为 0..1 归一化值，二者均使用 Unity 坐标系"
                           "（原点在贴图左下角，y 轴向上）。"),
            "assetPath": "assetPath/unityPath 里的 assetPath 相对 HaxePort/assets/，unityPath 相对仓库根。",
            "pivot": ("pivot = Unity 的实际取值：alignment != 9(Custom) 时由 alignment 推导，"
                      "== 9 时取 .meta 中的 spritePivot（保留在 pivotRaw）。"
                      "依据：areamodels/{ship,palace}.prefab 的 SpriteRenderer 位置只有在 alignment 生效时"
                      "才能恰好拼出 14x10.2 的关卡区域。"),
            "loadSet": ("manifest/manifestLabels 表示该条目属于哪个 SpriteManifest 资产"
                        "（等价于原工程 LoadInitSpriteManifests / LoadMainSpriteManifests 的 Init/Main 分组）。"),
            "atlases": "atlases[].packables 是 spriteatlasv2 中的打包文件夹，成员按贴图所在目录归属。",
        },
        "textures": textures,
        "sprites": sprites,
        "spriteSheets": sheets,
        "atlases": atlases,
        "spriteManifests": manifest_infos,
        "resourceManifest": resource_join,
        "warnings": warnings,
    }
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    with open(out_path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(out, f, ensure_ascii=False, indent=1, sort_keys=True)
        f.write("\n")

    return out


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    default_root = os.path.dirname(os.path.dirname(here))  # repo root（HaxePort 的上一级）
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--project-root", default=default_root,
                    help="Unity 工程根目录（应包含 Assets/），默认仓库根目录")
    ap.add_argument("--out", default=os.path.join(here, "..", "assets", "sprites_manifest.json"),
                    help="输出 JSON 路径")
    ap.add_argument("--resource-manifest",
                    default=os.path.join(here, "..", "assets", "resource_manifest.json"),
                    help="工作包 ① 的资产清单（地址 -> 路径），用于衔接与一致性校验；不存在时跳过")
    args = ap.parse_args()

    out = build(args.project_root, args.out, args.resource_manifest)
    print("输出：%s" % os.path.abspath(args.out))
    print("textures=%d sprites=%d spriteSheets=%d atlases=%d spriteManifests=%d warnings=%d" % (
        len(out["textures"]), len(out["sprites"]), len(out["spriteSheets"]),
        len(out["atlases"]), len(out["spriteManifests"]), len(out["warnings"])))
    join = out.get("resourceManifest")
    if join:
        print("resource_manifest.json 衔接：matched=%d missing=%d pathMismatch=%d（清单地址数 %d）" % (
            join["matched"], len(join["missing"]), len(join["pathMismatch"]), join["addressCount"]))
    for w in out["warnings"][:20]:
        print("  WARN: %s" % w)
    return 0


if __name__ == "__main__":
    sys.exit(main())
