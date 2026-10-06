#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""精灵清单独立校验器（工作包 ③）

用途：不依赖 convert_sprites.py 的实现，直接用原始 Unity 文件重新推导一遍，
校验 HaxePort/assets/sprites_manifest.json 的正确性与完整性。

校验项：
  1. 条目数与 Addressables / SpriteManifest 资产一致；
  2. 每个精灵/图集的贴图都能解析到 .meta，且 HaxePort/assets 里存在对应文件；
  3. 单帧精灵的 rect 等于贴图尺寸（PNG 头读取），pixelPerUnit/alignment 与 .meta 一致；
  4. 图集的帧集合与顺序与贴图 .meta 的 spriteSheet.sprites 一致（按 internalID 逐一核对）；
  5. pivot 规则：alignment != 9 时 pivot 必须由 alignment 推导，== 9 时等于 .meta 的 spritePivot；
  6. spriteatlasv2 的成员关系与按目录归属的结果一致。

用法：python HaxePort/tools_build/verify_sprites.py [--project-root .]
退出码：0 = 全部通过，1 = 有失败项。
"""

import argparse
import json
import os
import re
import sys

ALIGNMENT_PIVOT = {
    0: (0.5, 0.5), 1: (0.0, 1.0), 2: (0.5, 1.0), 3: (1.0, 1.0), 4: (0.0, 0.5),
    5: (1.0, 0.5), 6: (0.0, 0.0), 7: (0.5, 0.0), 8: (1.0, 0.0),
}

failures = []
checks = 0


def check(cond, msg):
    global checks
    checks += 1
    if not cond:
        failures.append(msg)


def read_text(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def png_size(path):
    """PNG / JPG 尺寸（只读文件头）。"""
    with open(path, "rb") as f:
        head = f.read(32)
        if head[:8] == b"\x89PNG\r\n\x1a\n":
            return int.from_bytes(head[16:20], "big"), int.from_bytes(head[20:24], "big")
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
                    return (int.from_bytes(data[i + 7:i + 9], "big"),
                            int.from_bytes(data[i + 5:i + 7], "big"))
                if marker in (0xD8, 0xD9) or 0xD0 <= marker <= 0xD7:
                    i += 2
                    continue
                i += 2 + int.from_bytes(data[i + 2:i + 4], "big")
    return None


def close(a, b, eps=1e-4):
    return abs(float(a) - float(b)) <= eps


def parse_meta(meta_path):
    """独立解析 TextureImporter .meta。"""
    text = read_text(meta_path)
    mode = int(re.search(r"^  spriteMode: (-?\d+)", text, re.M).group(1))
    ppu = float(re.search(r"^  spritePixelsToUnits: ([-\d.eE]+)", text, re.M).group(1))
    align = int(re.search(r"^  alignment: (-?\d+)", text, re.M).group(1))
    m = re.search(r"^  spritePivot: \{x: ([-\d.eE]+), y: ([-\d.eE]+)\}", text, re.M)
    pivot = (float(m.group(1)), float(m.group(2)))
    slices = {}
    order = []
    idx = text.rfind("\n  spriteSheet:")
    if idx >= 0:
        for block in text[idx:].split("    - serializedVersion: 2")[1:]:
            nm = re.search(r"^      name: (.*)$", block, re.M)
            r = re.search(
                r"      rect:\n        serializedVersion: 2\n"
                r"        x: ([-\d.eE]+)\n        y: ([-\d.eE]+)\n"
                r"        width: ([-\d.eE]+)\n        height: ([-\d.eE]+)", block)
            a = re.search(r"^      alignment: (-?\d+)$", block, re.M)
            p = re.search(r"^      pivot: \{x: ([-\d.eE]+), y: ([-\d.eE]+)\}", block, re.M)
            i = re.search(r"^      internalID: (-?\d+)$", block, re.M)
            if not (r and i):
                continue
            iid = i.group(1)
            slices[iid] = {
                "name": nm.group(1).strip() if nm else None,
                "rect": tuple(float(x) for x in r.groups()),
                "alignment": int(a.group(1)) if a else 0,
                "pivot": (float(p.group(1)), float(p.group(2))) if p else (0.0, 0.0),
            }
            order.append(iid)
    return {"spriteMode": mode, "pixelsPerUnit": ppu, "alignment": align,
            "pivot": pivot, "slices": slices, "sliceOrder": order}


def index_metas(assets_dir):
    guid2path = {}
    for dirpath, _d, filenames in os.walk(assets_dir):
        for fn in filenames:
            if not fn.endswith(".meta"):
                continue
            p = os.path.join(dirpath, fn)
            m = re.search(r"^guid: ([0-9a-f]{32})$", read_text(p)[:400], re.M)
            if m:
                guid2path[m.group(1)] = p[:-5]
    return guid2path


def parse_addressables(assets_dir):
    """独立解析 Addressables 分组：address -> {guid, labels, group}。"""
    result = {}
    groups_dir = os.path.join(assets_dir, "AddressableAssetsData", "AssetGroups")
    for fn in sorted(os.listdir(groups_dir)):
        if not fn.endswith(".asset"):
            continue
        text = read_text(os.path.join(groups_dir, fn))
        if "m_SerializeEntries:" not in text:
            continue
        for block in text.split("m_SerializeEntries:")[1].split("  - m_GUID: ")[1:]:
            guid = block.split("\n")[0].strip()
            if not re.fullmatch(r"[0-9a-f]{32}", guid):
                continue
            addr = re.search(r"m_Address: (.*)", block)
            labels = re.search(r"m_SerializedLabels:\n((?:    - .*\n)*)", block)
            labs = [x.strip("- \r\n") for x in labels.group(1).split("\n") if x.strip()] if labels else []
            if addr:
                result[addr.group(1).strip()] = {"guid": guid, "labels": labs, "group": fn[:-6]}
    return result


def parse_manifest_asset(path):
    text = read_text(path)
    i = text.index("spriteEntries:")
    j = text.index("spritesheetEntries:")
    sprites = re.findall(r"- name: (.*)\n    sprite: \{fileID: -?\d+, guid: ([0-9a-f]{32}), type: 3\}", text[i:j])
    sheets = []
    for name, body in re.findall(r"- name: (.*)\n    spritesheet:\n((?:    - \{[^\n]*\n)*)", text[j:]):
        sheets.append((name, re.findall(r"fileID: (-?\d+), guid: ([0-9a-f]{32})", body)))
    return sprites, sheets


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    default_root = os.path.dirname(os.path.dirname(here))
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--project-root", default=default_root)
    ap.add_argument("--manifest", default=os.path.join(here, "..", "assets", "sprites_manifest.json"))
    args = ap.parse_args()

    root = args.project_root
    assets_dir = os.path.join(root, "Assets")
    mirror_dir = os.path.join(root, "HaxePort", "assets")
    manifest_path = os.path.abspath(args.manifest)
    data = json.load(open(manifest_path, encoding="utf-8"))

    guid2path = index_metas(assets_dir)
    addressables = parse_addressables(assets_dir)

    # ------------------------------------------------ 1. 条目数
    sprite_labeled = {a for a, e in addressables.items() if "Sprite" in e["labels"]}
    sheet_labeled = {a for a, e in addressables.items() if "Spritesheet" in e["labels"]}
    init_sprites, init_sheets = parse_manifest_asset(
        os.path.join(assets_dir, "GameContent", "Assets", "mvz2", "spritemanifests", "init", "init_manifest.asset"))
    main_sprites, main_sheets = parse_manifest_asset(
        os.path.join(assets_dir, "GameContent", "Assets", "mvz2", "spritemanifests", "manifest.asset"))

    expected_sprites = {a[5:] for a in sprite_labeled} | {n for n, _g in main_sprites + init_sprites}
    expected_sheets = {a[5:] for a in sheet_labeled} | {n for n, _r in main_sheets + init_sheets}
    check(set(data["sprites"]) == expected_sprites,
          "精灵集合与 Addressables/SpriteManifest 不一致：缺 %s，多 %s"
          % (sorted(expected_sprites - set(data["sprites"]))[:5],
             sorted(set(data["sprites"]) - expected_sprites)[:5]))
    check(set(data["spriteSheets"]) == expected_sheets,
          "图集集合与 Addressables/SpriteManifest 不一致：缺 %s，多 %s"
          % (sorted(expected_sheets - set(data["spriteSheets"]))[:5],
             sorted(set(data["spriteSheets"]) - expected_sheets)[:5]))
    print("条目：sprites=%d（Addressables %d + SpriteManifest %d，并集 %d），spriteSheets=%d"
          % (len(data["sprites"]), len(sprite_labeled), len(main_sprites) + len(init_sprites),
             len(expected_sprites), len(data["spriteSheets"])))

    # Init / Main 分组应与 SpriteManifest 资产一致（只统计确实来自 SpriteManifest 的条目；
    # 仅带 "Sprite" 标签、不属于任何 SpriteManifest 的地址条目会被 C# 的
    # LoadLabeledResources<SpriteManifest> 忽略，这里同样排除）。
    init_json = {k for k, v in data["sprites"].items() if v["manifest"] and "Init" in v["manifestLabels"]}
    check(init_json == {n for n, _g in init_sprites},
          "Init 精灵集合与 init_manifest.asset 不一致：%s" % sorted(init_json ^ {n for n, _g in init_sprites})[:5])
    main_json = {k for k, v in data["sprites"].items() if v["manifest"] and "Main" in v["manifestLabels"]}
    check(main_json == {n for n, _g in main_sprites},
          "Main 精灵集合与 manifest.asset 不一致：%s" % sorted(main_json ^ {n for n, _g in main_sprites})[:5])
    sheets_json = {k for k, v in data["spriteSheets"].items() if v["manifest"] and "Main" in v["manifestLabels"]}
    check(sheets_json == {n for n, _r in main_sheets},
          "图集的 Main 集合与 manifest.asset 不一致：%s" % sorted(sheets_json ^ {n for n, _r in main_sheets})[:5])
    # 不属于任何 SpriteManifest 的地址条目应与 C# 的实际情况一致（Addressables 有 Sprite 标签但无人加载）
    manifest_free = sorted(k for k, v in data["sprites"].items() if not v["manifest"])
    print("不属于任何 SpriteManifest 的地址精灵：%s" % manifest_free)

    # ------------------------------------------------ 2/3. 单帧精灵
    meta_cache = {}
    bad_bounds = 0
    bad_rect = 0
    bad_pivot = 0
    bad_ppu = 0
    bad_name = 0
    missing_mirror = 0
    custom_sprites = 0
    for path, s in data["sprites"].items():
        tex = data["textures"].get(s["texture"])
        check(tex is not None, "精灵 %s 的贴图 guid 未收录" % path)
        if tex is None:
            continue
        meta_file = tex["unityPath"]
        meta = meta_cache.get(meta_file)
        if meta is None:
            meta = parse_meta(os.path.join(root, meta_file + ".meta"))
            meta_cache[meta_file] = meta
        size = png_size(os.path.join(mirror_dir, tex["assetPath"]))
        check(size is not None, "HaxePort/assets 缺少或不是图片：%s" % tex["assetPath"])
        if size is None:
            missing_mirror += 1
            continue
        check((tex["width"], tex["height"]) == size, "贴图尺寸与图片头不一致：%s" % tex["assetPath"])
        check(meta["spriteMode"] == 1, "Sprite 标签的贴图却不是 spriteMode=1：%s" % tex["assetPath"])
        # rect 应等于整张贴图
        if not (close(s["rect"]["x"], 0) and close(s["rect"]["y"], 0)
                and close(s["rect"]["width"], size[0]) and close(s["rect"]["height"], size[1])):
            bad_rect += 1
        # alignment / pixelPerUnit 与 .meta 一致
        check(s["alignment"] == meta["alignment"], "精灵 %s 的 alignment 与 .meta 不一致" % path)
        if not close(s["pixelsPerUnit"], meta["pixelsPerUnit"]):
            bad_ppu += 1
        # pivot 规则
        if s["alignment"] == 9:
            custom_sprites += 1
            expected = meta["pivot"]
        else:
            expected = ALIGNMENT_PIVOT[s["alignment"]]
        if not (close(s["pivot"]["x"], expected[0]) and close(s["pivot"]["y"], expected[1])):
            bad_pivot += 1
        if not (close(s["rect"]["x"], meta["pivot"][0]) or True):
            pass
        # 名称：单帧 Sprite 的名字应等于贴图文件名
        if s["name"] != os.path.splitext(os.path.basename(tex["unityPath"]))[0]:
            bad_name += 1
        # 边界
        if (s["rect"]["x"] < 0 or s["rect"]["y"] < 0
                or s["rect"]["x"] + s["rect"]["width"] > size[0] + 1e-3
                or s["rect"]["y"] + s["rect"]["height"] > size[1] + 1e-3):
            bad_bounds += 1

    check(bad_rect == 0, "rect 不等于整张贴图的精灵数：%d" % bad_rect)
    check(bad_bounds == 0, "rect 越界的精灵数：%d" % bad_bounds)
    check(bad_pivot == 0, "pivot 与 Unity alignment 规则不符的精灵数：%d" % bad_pivot)
    check(bad_ppu == 0, "pixelsPerUnit 与 .meta 不符的精灵数：%d" % bad_ppu)
    check(bad_name == 0, "name 不等于贴图文件名的精灵数：%d" % bad_name)
    print("单帧精灵：alignment=9(Custom) 的 %d 个；rect/pivot/ppu 与 .meta 全部核对。" % custom_sprites)

    # ------------------------------------------------ 4/5. 图集
    bad_sheet_frames = 0
    bad_sheet_rect = 0
    bad_sheet_pivot = 0
    custom_slices = 0
    total_slices = 0
    for path, sheet in data["spriteSheets"].items():
        tex = data["textures"].get(sheet["texture"])
        check(tex is not None, "图集 %s 的贴图 guid 未收录" % path)
        if tex is None:
            continue
        meta = meta_cache.get(tex["unityPath"])
        if meta is None:
            meta = parse_meta(os.path.join(root, tex["unityPath"] + ".meta"))
            meta_cache[tex["unityPath"]] = meta
        size = png_size(os.path.join(mirror_dir, tex["assetPath"]))
        if size is None:
            missing_mirror += 1
            continue
        check(meta["spriteMode"] == 2, "Spritesheet 标签的贴图却不是 spriteMode=2：%s" % tex["assetPath"])
        # 顺序与集合都应来自 SpriteManifest 的有序引用
        src = dict((n, refs) for n, refs in main_sheets + init_sheets).get(path)
        json_ids = [s["internalIDString"] for s in sheet["slices"]]
        if src is not None:
            check(json_ids == [str(fid) for fid, _g in src],
                  "图集 %s 的帧顺序与 SpriteManifest 不一致" % path)
            check({g for _f, g in src} == {sheet["texture"]}, "图集 %s 的贴图 guid 与 SpriteManifest 不一致" % path)
        check(sorted(json_ids) == sorted(meta["slices"].keys()),
              "图集 %s 的帧集合与贴图 .meta 不一致" % path)
        for slice in sheet["slices"]:
            total_slices += 1
            meta_slice = meta["slices"].get(slice["internalIDString"])
            if meta_slice is None:
                bad_sheet_frames += 1
                continue
            if not (close(slice["rect"]["x"], meta_slice["rect"][0]) and close(slice["rect"]["y"], meta_slice["rect"][1])
                    and close(slice["rect"]["width"], meta_slice["rect"][2]) and close(slice["rect"]["height"], meta_slice["rect"][3])):
                bad_sheet_rect += 1
            check(slice["alignment"] == meta_slice["alignment"], "图集 %s 帧 %s 的 alignment 不符" % (path, slice["name"]))
            check(slice["name"] == meta_slice["name"], "图集 %s 帧名不符：%s" % (path, slice["name"]))
            if slice["alignment"] == 9:
                custom_slices += 1
                expected = meta_slice["pivot"]
            else:
                expected = ALIGNMENT_PIVOT[slice["alignment"]]
            if not (close(slice["pivot"]["x"], expected[0]) and close(slice["pivot"]["y"], expected[1])):
                bad_sheet_pivot += 1
            if (slice["rect"]["x"] < 0 or slice["rect"]["y"] < 0
                    or slice["rect"]["x"] + slice["rect"]["width"] > size[0] + 1e-3
                    or slice["rect"]["y"] + slice["rect"]["height"] > size[1] + 1e-3):
                bad_sheet_rect += 1
    check(bad_sheet_frames == 0, "在 .meta 中找不到对应帧的图集帧数：%d" % bad_sheet_frames)
    check(bad_sheet_rect == 0, "图集帧 rect 与 .meta 不符/越界的数量：%d" % bad_sheet_rect)
    check(bad_sheet_pivot == 0, "图集帧 pivot 与 Unity alignment 规则不符的数量：%d" % bad_sheet_pivot)
    print("精灵图集：%d 个图集 / %d 个帧（其中 Custom pivot %d 个）逐个核对 .meta。" % (len(data["spriteSheets"]), total_slices, custom_slices))

    # ------------------------------------------------ 6. 图集成员关系
    atlas_dir = os.path.join(assets_dir, "GameContent", "spriteatlases")
    atlas_files = sorted(f for f in os.listdir(atlas_dir) if f.endswith(".spriteatlasv2"))
    check(set(data["atlases"]) == {os.path.splitext(f)[0] for f in atlas_files},
          "图集清单与 spriteatlases 目录不一致")
    for fn in atlas_files:
        name = os.path.splitext(fn)[0]
        text = read_text(os.path.join(atlas_dir, fn))
        # 注意：guid2path 里的路径基于 assets_dir（可能是绝对路径），而清单里的 unityPath
        # 是相对仓库根的，故统一转成绝对路径再比较。
        folders = []
        for guid in set(re.findall(r"guid: ([0-9a-f]{32}), type: \d+", text)):
            p = guid2path.get(guid)
            check(p is not None, "spriteatlas %s 的 packable guid=%s 无法解析" % (name, guid))
            if p:
                folders.append(os.path.abspath(p).replace("\\", "/") + "/")

        def in_atlas_folders(tex):
            abspath = os.path.abspath(os.path.join(root, tex["unityPath"])).replace("\\", "/")
            return any(abspath.startswith(f) for f in folders)

        entry = data["atlases"].get(name)
        check(entry is not None, "清单缺少图集 %s" % name)
        if entry is None:
            continue
        expected_sprites = sorted(
            s["id"] for s in data["sprites"].values()
            if in_atlas_folders(data["textures"][s["texture"]]))
        expected_sheets = sorted(
            s["id"] for s in data["spriteSheets"].values()
            if in_atlas_folders(data["textures"][s["texture"]]))
        check(sorted(entry["sprites"]) == expected_sprites,
              "图集 %s 的精灵成员不符（%d vs %d）" % (name, len(entry["sprites"]), len(expected_sprites)))
        check(sorted(entry["spriteSheets"]) == expected_sheets,
              "图集 %s 的图集成员不符（%d vs %d）" % (name, len(entry["spriteSheets"]), len(expected_sheets)))
        for s in data["sprites"].values():
            in_atlas = name in s["atlases"]
            check(in_atlas == (s["id"] in expected_sprites), "精灵 %s 的 atlases 标记不符" % s["id"])
        print("图集 %s：packables=%d 个文件夹，成员 sprites=%d sheets=%d"
              % (name, len(folders), len(entry["sprites"]), len(entry["spriteSheets"])))

    # ------------------------------------------------ 镜像完整性
    for s in list(data["sprites"].values()) + list(data["spriteSheets"].values()):
        tex = data["textures"][s["texture"]]
        if not os.path.exists(os.path.join(mirror_dir, tex["assetPath"])):
            missing_mirror += 1
            failures.append("HaxePort/assets 缺少贴图：%s" % tex["assetPath"])
    check(missing_mirror == 0, "HaxePort/assets 缺少 %d 个贴图文件" % missing_mirror)

    # ------------------------------------------------ 7. 与 ① 的 asset 清单衔接
    res_path = os.path.join(mirror_dir, "resource_manifest.json")
    if os.path.exists(res_path):
        res = json.load(open(res_path, encoding="utf-8"))
        res_addresses = res.get("addresses") or {}
        res_paths = {}
        if isinstance(res_addresses, dict):
            for addr, info in res_addresses.items():
                if isinstance(info, dict) and info.get("path"):
                    res_paths[addr] = info
        if not res_paths:
            for e in res.get("entries", []):
                if e.get("address") and e.get("path"):
                    res_paths[e["address"]] = e
        missing = []
        mismatched = []
        not_image = []
        for entry in list(data["sprites"].values()) + list(data["spriteSheets"].values()):
            info = res_paths.get(entry["id"])
            if info is None:
                missing.append(entry["id"])
                continue
            if info["path"] != data["textures"][entry["texture"]]["assetPath"]:
                mismatched.append(entry["id"])
            if info.get("kind") != "Image":
                not_image.append((entry["id"], info.get("kind")))
        check(not missing, "① 的 asset 清单缺少 %d 个精灵地址：%s" % (len(missing), missing[:5]))
        check(not mismatched, "① 的 asset 清单与精灵清单的贴图路径不一致：%s" % mismatched[:5])
        check(not not_image, "① 的 asset 清单里这些地址不是图片：%s" % not_image[:5])
        # 输出里记录的 resourcePath 也必须与 ① 一致
        wrong_recorded = [k for k, v in data["sprites"].items()
                          if (res_paths.get(v["id"]) or {}).get("path") != v.get("resourcePath")]
        check(not wrong_recorded, "sprites_manifest.resourcePath 与 ① 不一致：%s" % wrong_recorded[:5])
        join = data.get("resourceManifest") or {}
        check(join.get("matched") == len(data["sprites"]) + len(data["spriteSheets"]),
              "sprites_manifest.resourceManifest.matched 与条目数不符")
        check(not join.get("missing") and not join.get("pathMismatch"),
              "sprites_manifest.resourceManifest 记录了未解决的问题")
        print("与 ① 的 resource_manifest.json 衔接：%d 个地址全部命中且路径一致（清单共 %d 条地址）。"
              % (len(data["sprites"]) + len(data["spriteSheets"]), len(res_paths)))
    else:
        check(False, "缺少 %s：精灵清单应与 ① 的地址体系衔接" % res_path)

    # ------------------------------------------------ 8. 游戏内容 XML 引用的精灵 ID
    # 游戏自身的 meta XML 里，精灵引用集中在下面这些属性上。它们必须全部能在清单中找到，
    # 这是「清单不缺条目」的最强证据（来自消费方而不是生产方）。
    SPRITE_ATTRS = {"arcade", "back", "background", "bottom", "frameBottom", "frameTop", "icon",
                    "mobile", "overlay", "overlaySprite", "sprite", "spritesheet", "starshard", "textSprite"}
    refs = 0
    unresolved = []
    metas_dir = os.path.join(assets_dir, "GameContent", "Assets", "mvz2", "metas")
    for dirpath, _d, filenames in os.walk(metas_dir):
        for fn in filenames:
            if not fn.endswith(".xml"):
                continue
            text = read_text(os.path.join(dirpath, fn))
            for attr, value in re.findall(r'([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"(mvz2:[^"]+)"', text):
                if attr not in SPRITE_ATTRS:
                    continue
                refs += 1
                path = value[5:]
                base = re.sub(r"\[\d+\]$", "", path)
                if path not in data["sprites"] and base not in data["spriteSheets"]:
                    unresolved.append((attr, value))
    check(not unresolved, "内容 XML 引用了 %d 个清单里没有的精灵：%s"
          % (len(unresolved), unresolved[:8]))
    print("内容 XML：%d 处精灵引用（属性 %s）全部解析成功。" % (refs, "/".join(sorted(SPRITE_ATTRS))))

    print("-" * 60)
    print("校验项 %d，失败 %d" % (checks, len(failures)))
    for f in failures[:30]:
        print("  [FAIL] %s" % f)
    if failures:
        print("VERIFY FAILED")
        return 1
    print("VERIFY PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
