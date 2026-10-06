#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# PORT-NOTE: Unity Addressables 不移植（见 HaxePort/PORTING.md §其他约定）。
# 本脚本把 Unity 的 Addressables 目录（AssetGroups/*.asset + Schemas/*.asset）与全工程
# *.meta 的 GUID 表，转换成运行期可用的地址清单 HaxePort/assets/resource_manifest.json。
#
# 对应 C# 侧：Assets/Scripts/MVZ2/Managers/ResourceManager*.cs 通过
#   Addressables.LoadAssetAsync<T>(address)          -> 按地址取资源
#   Addressables.LoadAssetsAsync<T>(labels, mergeMode) -> 按标签取资源（MergeMode.Intersection 等）
# 因此清单除地址外还保留每条地址的 labels / group，供运行期做标签查询。
#
# 输入：
#   Assets/AddressableAssetsData/AssetGroups/*.asset          （组定义 + m_SerializeEntries）
#   Assets/AddressableAssetsData/AssetGroups/Schemas/*.asset  （组的 bundle 模式 / 是否入包）
#   Assets/**/*.meta                                          （GUID <-> 资源路径映射）
# 输出：
#   HaxePort/assets/resource_manifest.json
#
# 设计要点：
#   * 不依赖第三方库（PyYAML 等）：Unity 生成的 YAML 子集结构高度规整，这里用行级状态机解析，
#     避免 YAML 1.1 把 `on`/`yes` 之类地址误判成 bool。
#   * 地址前缀 `Assets/` 对应 HaxePort/assets/ 的同名相对路径；mvz2:* 这类逻辑地址通过 GUID
#     反查真实文件路径。
#   * 地址指向文件夹（folderAsset: yes）时，按 Unity Addressables 的行为展开为该文件夹下
#     所有资源，子地址 = 子资源的工程路径（Unity 对文件夹入组的子资源默认就用资源路径当地址）。
#     原文件夹地址本身不再作为可加载地址（Unity 运行期也不能直接加载文件夹），但会记录在
#     顶层 `folders` 映射里备查。
#
# TODO-PORT: 本脚本只产出「清单」，不做格式转换。清单里 type 为 "其它" 的条目
# （anim / controller / overrideController / mat / shader / hlsl / spriteatlasv2 / unity /
#  bytes / jpg / ttf 等）在 HaxeFlixel 运行期无法直接当资源加载，需要由资源转换工作包
#  （Unity 专有格式 -> png/ogg/xml/自定义数据）产出对应文件后，再由清单的消费者决定映射方式。
# TODO-PORT: 资源镜像 HaxePort/assets 目前缺 Assets/Prefabs、Assets/Tests 等目录，导致 5 条
# （4 个 Prefabs/Init 预制体 + TestScene 场景）在清单里被标记为 missing。等镜像补齐后
# 重跑本脚本即可消除（脚本只读、幂等，可直接重复运行）。
#
# 用法：
#   python HaxePort/tools_build/build_manifest.py            # 在仓库根目录执行
#   python HaxePort/tools_build/build_manifest.py --project-root . --out HaxePort/assets/resource_manifest.json

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import OrderedDict

ASSETS_DIR = "Assets"
ADDRESSABLE_DATA_DIR = os.path.join(ASSETS_DIR, "AddressableAssetsData")
ASSET_GROUPS_DIR = os.path.join(ADDRESSABLE_DATA_DIR, "AssetGroups")
SCHEMAS_DIR = os.path.join(ASSET_GROUPS_DIR, "Schemas")
DEFAULT_OUT = os.path.join("HaxePort", "assets", "resource_manifest.json")
DEFAULT_RESOURCE_ROOT = os.path.join("HaxePort", "assets")

ASSETS_PREFIX = "Assets/"
OTHER_TYPE = "其它"

# 文档约定的类型白名单，其余一律归入 "其它"。
TYPE_BY_EXT = {
    "png": "png",
    "ogg": "ogg",
    "wav": "wav",
    "mp3": "mp3",
    "xml": "xml",
    "json": "json",
    "txt": "txt",
    "prefab": "prefab",
    "asset": "asset",
    "otf": "otf",
}

# 兼容镜像用的加载分派类别。并行工作包 unity.addressableassets.ResourceLocation.hx 读取的
# `kind` 字段取值为 Image/Audio/Text/Model/Font/Other，这里沿用同名同取值（判定细节见 kind_of）。
KIND_BY_EXT = {
    "png": "Image", "jpg": "Image", "jpeg": "Image", "bmp": "Image", "gif": "Image",
    "tga": "Image", "psd": "Image", "tif": "Image", "tiff": "Image", "exr": "Image",
    "ogg": "Audio", "wav": "Audio", "mp3": "Audio", "aiff": "Audio", "aif": "Audio",
    "m4a": "Audio", "aac": "Audio", "flac": "Audio",
    "xml": "Text", "json": "Text", "txt": "Text", "csv": "Text", "bytes": "Text",
    "po": "Text", "pot": "Text", "mo": "Text", "yml": "Text", "yaml": "Text",
    "prefab": "Model", "fbx": "Model", "obj": "Model", "unity": "Model", "dae": "Model",
    "otf": "Font", "ttf": "Font", "fontsettings": "Font",
}
KIND_BY_IMPORTER = {
    "TextScriptImporter": "Text",
    "AudioImporter": "Audio",
    "TrueTypeFontImporter": "Font",
    "ModelImporter": "Model",
    "PrefabImporter": "Model",
}
# 只有 TextureImporter 才意味着"图片"。NativeFormatImporter 覆盖 .anim/.mat/.asset 等
# 原生序列化资源，把它们当图片会让运行期的加载分派走错分支。
IMAGE_IMPORTERS = ("TextureImporter",)

# Addressables 的 schema 脚本 GUID（来自各 Schema .asset 的 m_Script.guid）。
SCHEMA_KIND_BY_SCRIPT_GUID = {
    "e5d17a21594effb4e9591490b009e7aa": "BundledAssetGroupSchema",
    "b1487f5d688e4f94f828f879d599dbdc": "PlayerDataGroupSchema",
    "5834b5087d578d24c926ce20cd31e6d6": "ContentUpdateGroupSchema",
}

# Addressables 的 BundleMode 枚举：PackSeparately=0 / PackTogether=1 / PackTogetherByLabel=2。
BUNDLE_MODE_NAMES = {0: "PackSeparately", 1: "PackTogether", 2: "PackTogetherByLabel"}

RE_META_GUID = re.compile(r"^guid:\s*([0-9a-fA-F]{32})\s*$")
RE_META_FOLDER = re.compile(r"^folderAsset:\s*yes\s*$")
RE_META_IMPORTER = re.compile(r"^([A-Za-z][A-Za-z0-9_]*Importer):\s*$")
RE_HEX_GUID = re.compile(r"^[0-9a-fA-F]{32}$")
RE_GROUP_NAME = re.compile(r"^  m_GroupName:\s*(.*?)\s*$")
RE_GROUP_M_GUID = re.compile(r"^  m_GUID:\s*(\S+)\s*$")
RE_ENTRY_START = re.compile(r"^  - m_GUID:\s*(\S+)\s*$")
RE_ENTRY_ADDRESS = re.compile(r"^    m_Address:\s*(.*?)\s*$")
RE_ENTRY_LABELS_HEAD = re.compile(r"^    m_SerializedLabels:\s*$")
RE_ENTRY_LABEL_ITEM = re.compile(r"^    - (.*?)\s*$")
RE_SCHEMA_REF = re.compile(r"^    - \{fileID:\s*\d+,\s*guid:\s*([0-9a-fA-F]{32}),\s*type:\s*\d+\}\s*$")
RE_SCHEMA_GROUP_REF = re.compile(r"^  m_Group:\s*\{fileID:\s*\d+,\s*guid:\s*([0-9a-fA-F]{32}),")
RE_SCHEMA_SCRIPT_REF = re.compile(r"^  m_Script:\s*\{fileID:\s*\d+,\s*guid:\s*([0-9a-fA-F]{32}),")
RE_SIMPLE_INT = re.compile(r"^  ([A-Za-z_][A-Za-z0-9_]*):\s*(-?\d+)\s*$")
RE_SIMPLE_STR = re.compile(r"^  ([A-Za-z_][A-Za-z0-9_]*):\s*(.*?)\s*$")
RE_SECTION = re.compile(r"^  [A-Za-z_]")


def read_lines(path: str):
    with open(path, "r", encoding="utf-8-sig", errors="replace") as f:
        return f.read().split("\n")


def unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
        return value[1:-1]
    return value


def ext_of(path: str) -> str:
    name = path.rsplit("/", 1)[-1]
    if "." not in name:
        return ""
    return name.rsplit(".", 1)[-1].lower()


def type_of(path: str) -> str:
    return TYPE_BY_EXT.get(ext_of(path), OTHER_TYPE)


def kind_of(unity_path: str, importer: str):
    """加载分派类别：Image / Audio / Text / Model / Font / Other。

    PORT-NOTE: 字段名与取值沿用并行工作包 unity.addressableassets.ResourceLocation 的约定；
    判定顺序按扩展名优先，只有扩展名不认识时才退回 importer 名。注意 build_resource_manifest.py
    把 NativeFormatImporter 也当成图片导入器，会把 .anim/.mat/.asset 判成 Image，这里不沿用该行为。
    """
    ext = ext_of(unity_path)
    if ext in KIND_BY_EXT:
        return KIND_BY_EXT[ext]
    if importer in IMAGE_IMPORTERS:
        return "Image"
    if importer in KIND_BY_IMPORTER:
        return KIND_BY_IMPORTER[importer]
    return "Other"


# ---------------------------------------------------------------------------
# *.meta：GUID <-> 资源路径
# ---------------------------------------------------------------------------

def scan_meta_guids(project_root: str):
    """返回 (guid -> {path, isFolder, importer})，path 为 `Assets/...` 形式的工程相对路径。"""
    assets_root = os.path.join(project_root, ASSETS_DIR)
    by_guid = {}
    duplicates = []
    for dirpath, dirnames, filenames in os.walk(assets_root):
        for filename in filenames:
            if not filename.endswith(".meta"):
                continue
            meta_path = os.path.join(dirpath, filename)
            asset_path = meta_path[: -len(".meta")]
            rel = os.path.relpath(asset_path, project_root).replace("\\", "/")
            guid = None
            is_folder = False
            importer = None
            try:
                with open(meta_path, "r", encoding="utf-8-sig", errors="replace") as f:
                    for _ in range(6):
                        line = f.readline()
                        if not line:
                            break
                        line = line.rstrip("\r\n")
                        m = RE_META_GUID.match(line)
                        if m and guid is None:
                            guid = m.group(1).lower()
                        if RE_META_FOLDER.match(line):
                            is_folder = True
                        # Unity 的 importer 类名是文件头里第一个顶格且以冒号结尾的行
                        # （如 TextureImporter: / AudioImporter: / PrefabImporter:）。
                        m = RE_META_IMPORTER.match(line)
                        if m and importer is None:
                            importer = m.group(1)
            except OSError as exc:
                print("WARN: cannot read %s: %s" % (meta_path, exc), file=sys.stderr)
                continue
            if guid is None:
                print("WARN: no guid in %s" % meta_path, file=sys.stderr)
                continue
            if guid in by_guid:
                duplicates.append((guid, by_guid[guid]["path"], rel))
                continue
            by_guid[guid] = {"path": rel, "isFolder": is_folder, "importer": importer}
    return by_guid, duplicates


# ---------------------------------------------------------------------------
# AssetGroups/*.asset
# ---------------------------------------------------------------------------

def parse_group_file(path: str):
    lines = read_lines(path)
    group = {
        "name": None,
        "guid": None,
        "entries": [],
        "schemaGuids": [],
    }
    current = None
    in_schemas = False

    def flush():
        nonlocal current
        if current is not None:
            group["entries"].append(current)
            current = None

    state = "top"
    for raw in lines:
        line = raw.rstrip("\r")
        if state in ("entry", "labels"):
            if RE_ENTRY_START.match(line):
                flush()
                m = RE_ENTRY_START.match(line)
                current = {"guid": m.group(1), "address": None, "labels": []}
                state = "entry"
                continue
            if RE_ENTRY_ADDRESS.match(line):
                m = RE_ENTRY_ADDRESS.match(line)
                current["address"] = unquote(m.group(1))
                state = "entry"
                continue
            if RE_ENTRY_LABELS_HEAD.match(line):
                state = "labels"
                continue
            if state == "labels" and RE_ENTRY_LABEL_ITEM.match(line):
                current["labels"].append(unquote(RE_ENTRY_LABEL_ITEM.match(line).group(1)))
                continue
            if RE_SECTION.match(line):
                flush()
                state = "top"
                # 落回顶层继续解析本行
            else:
                state = "entry"
                continue

        if state == "top":
            m = RE_ENTRY_START.match(line)
            if m:
                current = {"guid": m.group(1), "address": None, "labels": []}
                state = "entry"
                continue
            m = RE_GROUP_NAME.match(line)
            if m and group["name"] is None:
                group["name"] = unquote(m.group(1))
                continue
            m = RE_GROUP_M_GUID.match(line)
            if m and group["guid"] is None:
                group["guid"] = m.group(1).lower()
                continue
            if line.startswith("  m_SchemaSet:"):
                in_schemas = True
                continue
            if in_schemas:
                m = RE_SCHEMA_REF.match(line)
                if m:
                    group["schemaGuids"].append(m.group(1).lower())
                    continue
                if RE_SECTION.match(line) and not line.startswith("    "):
                    # 退出 m_SchemaSet 之前的兄弟字段（如 m_ReadOnly / m_Settings）
                    if not line.startswith("  m_SchemaSet"):
                        in_schemas = False
            continue
    flush()
    return group


def parse_schema_file(path: str):
    lines = read_lines(path)
    schema = {
        "name": None,
        "scriptGuid": None,
        "groupGuid": None,
        "kind": None,
        "fields": OrderedDict(),
    }
    for raw in lines:
        line = raw.rstrip("\r")
        m = RE_SCHEMA_SCRIPT_REF.match(line)
        if m and schema["scriptGuid"] is None:
            schema["scriptGuid"] = m.group(1).lower()
            schema["kind"] = SCHEMA_KIND_BY_SCRIPT_GUID.get(schema["scriptGuid"], "UnknownSchema")
            continue
        m = RE_SCHEMA_GROUP_REF.match(line)
        if m and schema["groupGuid"] is None:
            schema["groupGuid"] = m.group(1).lower()
            continue
        m = RE_SIMPLE_INT.match(line)
        if m:
            schema["fields"][m.group(1)] = int(m.group(2))
            continue
        m = RE_SIMPLE_STR.match(line)
        if m and m.group(1) == "m_Name" and schema["name"] is None:
            schema["name"] = unquote(m.group(2))
    return schema


# ---------------------------------------------------------------------------
# 地址解析
# ---------------------------------------------------------------------------

def to_resource_rel_path(unity_path: str) -> str:
    """`Assets/GameContent/x.png` -> `GameContent/x.png`（相对 HaxePort/assets）。"""
    if unity_path.startswith(ASSETS_PREFIX):
        return unity_path[len(ASSETS_PREFIX):]
    return unity_path


def expand_folder(project_root: str, folder_rel: str, guid_by_path):
    """展开 folderAsset，返回 [(child_unity_path, child_guid_or_None)]（按路径排序，跳过 .meta/.cs）。"""
    abs_dir = os.path.join(project_root, folder_rel)
    children = []
    if not os.path.isdir(abs_dir):
        return children
    for dirpath, dirnames, filenames in os.walk(abs_dir):
        dirnames.sort()
        for filename in sorted(filenames):
            if filename.endswith(".meta") or filename.endswith(".cs"):
                continue
            abs_path = os.path.join(dirpath, filename)
            child_rel = os.path.relpath(abs_path, project_root).replace("\\", "/")
            children.append((child_rel, guid_by_path.get(child_rel)))
    children.sort()
    return children


def main() -> int:
    parser = argparse.ArgumentParser(description="Build HaxePort runtime resource manifest from Unity Addressables data.")
    parser.add_argument("--project-root", default=None, help="仓库根目录（默认取脚本上溯三级）")
    parser.add_argument("--out", default=None, help="输出 JSON 路径（默认 <root>/HaxePort/assets/resource_manifest.json）")
    parser.add_argument("--resource-root", default=None, help="资源根目录（默认 <root>/HaxePort/assets）")
    args = parser.parse_args()

    # Windows 控制台默认 cp936，会把 "其它" 这类中文打成乱码；这里强制 UTF-8 以保证输出可读。
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            try:
                stream.reconfigure(encoding="utf-8", errors="replace")
            except (ValueError, OSError):
                pass

    if args.project_root:
        project_root = os.path.abspath(args.project_root)
    else:
        project_root = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))

    out_path = os.path.abspath(args.out) if args.out else os.path.join(project_root, DEFAULT_OUT)
    resource_root = os.path.abspath(args.resource_root) if args.resource_root else os.path.join(project_root, DEFAULT_RESOURCE_ROOT)

    groups_dir = os.path.join(project_root, ASSET_GROUPS_DIR)
    schemas_dir = os.path.join(project_root, SCHEMAS_DIR)
    if not os.path.isdir(groups_dir):
        print("ERROR: Addressables AssetGroups directory not found: %s" % groups_dir, file=sys.stderr)
        return 2

    print("[manifest] project root  : %s" % project_root)
    print("[manifest] resource root : %s" % resource_root)
    if not os.path.isdir(resource_root):
        print("WARN: resource root does not exist, every entry will be reported as missing: %s" % resource_root,
              file=sys.stderr)

    # 1) GUID 表
    meta_by_guid, meta_dups = scan_meta_guids(project_root)
    guid_by_path = {info["path"]: guid for guid, info in meta_by_guid.items()}
    print("[manifest] meta guids    : %d (duplicate guid entries: %d)" % (len(meta_by_guid), len(meta_dups)))

    # 2) Schemas —— 组文件里通过 schema 资源自身的 GUID 引用它们，这里先建两张表：
    #    按 schema 资源 GUID（来自 .meta），以及按 schema 内 m_Group 指向的组 GUID。
    schemas_by_asset_guid = {}
    schemas_by_group_guid = {}
    if os.path.isdir(schemas_dir):
        for name in sorted(os.listdir(schemas_dir)):
            if not name.endswith(".asset"):
                continue
            path = os.path.join(schemas_dir, name)
            schema = parse_schema_file(path)
            if not schema["scriptGuid"]:
                continue
            schema_asset_rel = os.path.relpath(path, project_root).replace("\\", "/")
            schema["assetGuid"] = guid_by_path.get(schema_asset_rel)
            if schema["assetGuid"]:
                schemas_by_asset_guid[schema["assetGuid"]] = schema
            if schema["groupGuid"]:
                schemas_by_group_guid.setdefault(schema["groupGuid"], []).append(schema)
    print("[manifest] schemas       : %d" % len(schemas_by_asset_guid))

    # 3) Groups
    group_files = sorted(
        name for name in os.listdir(groups_dir)
        if name.endswith(".asset") and os.path.isfile(os.path.join(groups_dir, name))
    )
    groups = []
    for name in group_files:
        group = parse_group_file(os.path.join(groups_dir, name))
        group["file"] = "Assets/AddressableAssetsData/AssetGroups/" + name
        groups.append(group)
    print("[manifest] asset groups  : %d" % len(groups))

    # 4) 逐条解析
    addresses = OrderedDict()          # address -> entry dict
    folders = OrderedDict()            # address -> [child addresses]
    group_infos = OrderedDict()
    missing = []
    unresolved = []
    builtin_entries = []
    duplicate_addresses = OrderedDict()
    same_path_dups = []

    raw_entry_count = 0
    folder_entry_count = 0
    expanded_child_count = 0

    def add_entry(address, unity_path, guid, group_name, labels, is_folder_child, importer=None):
        nonlocal expanded_child_count
        rel = to_resource_rel_path(unity_path)
        entry = OrderedDict()
        entry["path"] = rel
        entry["type"] = type_of(unity_path)
        entry["kind"] = kind_of(unity_path, importer)
        entry["guid"] = guid
        entry["group"] = group_name
        entry["labels"] = list(labels)
        if is_folder_child:
            expanded_child_count += 1
        if address in addresses:
            primary = addresses[address]
            if primary["path"] == rel:
                # 同一资产被两个组同时标记为 addressable（源工程里 Assets/Animation 与
                # Assets/Animation/Init 重叠）。Unity catalog 里同一个 key 只会命中同一个
                # location，这里把两边标签取并集，不另建 alternate。
                merged = list(primary["labels"])
                for label in entry["labels"]:
                    if label not in merged:
                        merged.append(label)
                primary["labels"] = merged
                if entry["group"] != primary["group"]:
                    groups_list = primary.setdefault("alsoInGroups", [])
                    if entry["group"] not in groups_list:
                        groups_list.append(entry["group"])
                same_path_dups.append(address)
                return
            duplicate_addresses.setdefault(address, 1)
            duplicate_addresses[address] += 1
            primary.setdefault("alternates", []).append(entry)
            return
        addresses[address] = entry

    for group in groups:
        group_name = group["name"] or os.path.basename(group["file"])
        bundle_schema = None
        player_data_schema = None
        static_content = None
        for sg in group["schemaGuids"]:
            schema = schemas_by_asset_guid.get(sg)
            if not schema:
                continue
            if schema["kind"] == "BundledAssetGroupSchema":
                bundle_schema = schema
            elif schema["kind"] == "PlayerDataGroupSchema":
                player_data_schema = schema
            elif schema["kind"] == "ContentUpdateGroupSchema":
                static_content = schema["fields"].get("m_StaticContent")
        if bundle_schema is None and player_data_schema is None and group["guid"]:
            for schema in schemas_by_group_guid.get(group["guid"], []):
                if schema["kind"] == "BundledAssetGroupSchema" and bundle_schema is None:
                    bundle_schema = schema
                elif schema["kind"] == "PlayerDataGroupSchema" and player_data_schema is None:
                    player_data_schema = schema
                elif schema["kind"] == "ContentUpdateGroupSchema" and static_content is None:
                    static_content = schema["fields"].get("m_StaticContent")
        info = OrderedDict()
        info["guid"] = group["guid"]
        info["schema"] = (player_data_schema or bundle_schema or {}).get("kind")
        info["labels"] = sorted({label for entry in group["entries"] for label in entry["labels"]})
        if bundle_schema is not None:
            info["includeInBuild"] = bool(bundle_schema["fields"].get("m_IncludeInBuild", 1))
            mode = bundle_schema["fields"].get("m_BundleMode")
            info["bundleMode"] = BUNDLE_MODE_NAMES.get(mode, mode)
        if player_data_schema is not None:
            info["includeResourcesFolders"] = bool(player_data_schema["fields"].get("m_IncludeResourcesFolders", 0))
            info["includeBuildSettingsScenes"] = bool(player_data_schema["fields"].get("m_IncludeBuildSettingsScenes", 0))
        if static_content is not None:
            info["staticContent"] = bool(static_content)
        info["entryCount"] = len(group["entries"])
        info["file"] = group["file"]
        group_infos[group_name] = info

        is_player_data = player_data_schema is not None
        for entry in group["entries"]:
            raw_entry_count += 1
            guid = entry["guid"]
            address = entry["address"]
            if not address:
                continue
            if not RE_HEX_GUID.match(guid):
                # Built In Data 组用 "Resources" / "EditorSceneList" 这样的伪 GUID 引用 Unity 内建数据。
                builtin_entries.append(OrderedDict([("group", group_name), ("address", address), ("guid", guid)]))
                continue
            resolved = meta_by_guid.get(guid.lower())
            if resolved is None:
                unresolved.append(OrderedDict([("group", group_name), ("address", address), ("guid", guid)]))
                continue
            if resolved["isFolder"]:
                folder_entry_count += 1
                children = expand_folder(project_root, resolved["path"], guid_by_path)
                child_addresses = []
                for child_path, child_guid in children:
                    child_meta = meta_by_guid.get(child_guid) if child_guid else None
                    add_entry(child_path, child_path, child_guid, group_name, entry["labels"], True,
                              child_meta["importer"] if child_meta else None)
                    child_addresses.append(child_path)
                folders[address] = child_addresses
                continue
            if is_player_data:
                # PlayerDataGroupSchema 的组内容由 Unity 内部生成，条目指向内建清单而非具体资源。
                builtin_entries.append(OrderedDict([("group", group_name), ("address", address), ("guid", guid)]))
                continue
            add_entry(address, resolved["path"], guid.lower(), group_name, entry["labels"], False,
                      resolved["importer"])

    # 5) 统计
    by_type = OrderedDict()
    by_group = OrderedDict()
    missing_count = 0
    entry_total = 0
    unique_paths = set()
    checked_paths = {}
    for address in sorted(addresses.keys()):
        for entry in [addresses[address]] + addresses[address].get("alternates", []):
            entry_total += 1
            by_type[entry["type"]] = by_type.get(entry["type"], 0) + 1
            by_group[entry["group"]] = by_group.get(entry["group"], 0) + 1
            unique_paths.add(entry["path"])
            if entry["path"] not in checked_paths:
                checked_paths[entry["path"]] = os.path.isfile(
                    os.path.join(resource_root, entry["path"].replace("/", os.sep))
                )
            # PORT-NOTE: `exists` 供 unity.addressableassets.ResourceManifest 读取
            # （ResourceLocation.Exists —— 清单声明该条目在镜像里是否真的存在）。
            entry["exists"] = checked_paths[entry["path"]]
            if not checked_paths[entry["path"]]:
                missing_count += 1
                missing.append(OrderedDict([
                    ("address", address),
                    ("path", entry["path"]),
                    ("type", entry["type"]),
                    ("guid", entry["guid"]),
                    ("group", entry["group"]),
                ]))
    by_type = OrderedDict(sorted(by_type.items(), key=lambda kv: (-kv[1], kv[0])))
    by_group = OrderedDict(sorted(by_group.items(), key=lambda kv: (-kv[1], kv[0])))

    # 标签索引：C# 侧 ResourceManager 主要是靠标签取资源的
    # （Addressables.LoadAssetsAsync<T>(labels, MergeMode) / IResourceLocator.Locate(label, type)），
    # 这里给出 label -> [[address, path, type], ...]，便于运行期直接做并集/交集。
    label_index = OrderedDict()
    for address in sorted(addresses.keys()):
        for entry in [addresses[address]] + addresses[address].get("alternates", []):
            for label in entry["labels"]:
                label_index.setdefault(label, []).append([address, entry["path"], entry["type"]])
    label_index = OrderedDict((k, label_index[k]) for k in sorted(label_index.keys()))

    kind_counts = OrderedDict()
    compat_entries = []
    for address in sorted(addresses.keys()):
        for entry in [addresses[address]] + addresses[address].get("alternates", []):
            exists = checked_paths.get(entry["path"], False)
            kind_counts[entry["kind"]] = kind_counts.get(entry["kind"], 0) + 1
            # 兼容镜像：并行工作包 unity.addressableassets.ResourceLocation/ResourceManifest
            # 读取的是 entries 数组形态（address/path/source/labels/group/guid/kind/exists）。
            compat_entries.append(OrderedDict([
                ("address", address),
                ("path", entry["path"]),
                ("source", ASSETS_PREFIX + entry["path"]),
                ("labels", entry["labels"]),
                ("group", entry["group"]),
                ("guid", entry["guid"]),
                ("kind", entry["kind"]),
                ("exists", exists),
            ]))
    kind_counts = OrderedDict(sorted(kind_counts.items(), key=lambda kv: (-kv[1], kv[0])))

    stats = OrderedDict()
    stats["serializeEntries"] = raw_entry_count
    stats["folderEntries"] = folder_entry_count
    stats["expandedFolderChildren"] = expanded_child_count
    stats["builtinEntriesSkipped"] = len(builtin_entries)
    stats["unresolvedGuids"] = len(unresolved)
    stats["addressCount"] = len(addresses)
    stats["entryCount"] = entry_total
    stats["duplicateAddressCount"] = len(duplicate_addresses)
    stats["samePathDuplicateCount"] = len(same_path_dups)
    stats["uniquePathCount"] = len(unique_paths)
    stats["missingFileCount"] = missing_count
    stats["missingFileCountUnique"] = sum(1 for v in checked_paths.values() if not v)
    stats["byType"] = by_type
    stats["byKind"] = kind_counts
    stats["byGroup"] = by_group

    manifest = OrderedDict()
    manifest["version"] = 1
    manifest["generatedBy"] = "HaxePort/tools_build/build_manifest.py"
    manifest["source"] = "Assets/AddressableAssetsData/AssetGroups"
    manifest["resourceRoot"] = "HaxePort/assets"
    manifest["addresses"] = OrderedDict((k, addresses[k]) for k in sorted(addresses.keys()))
    # 兼容别名：与 unity.addressableassets.ResourceLocation / build_resource_manifest.py 约定的
    # 顶层字段保持一致（generatedFrom / assetsRoot / entryCount / entries），使同一个 JSON 能同时
    # 被两套消费者读取。真实来源仍是上面的 addresses。
    manifest["generatedFrom"] = "Assets/AddressableAssetsData/AssetGroups"
    manifest["assetsRoot"] = "HaxePort/assets"
    manifest["entryCount"] = len(compat_entries)
    manifest["entries"] = compat_entries
    manifest["labelIndex"] = label_index
    manifest["folders"] = folders
    manifest["groups"] = group_infos
    manifest["missing"] = missing
    manifest["stats"] = stats
    if unresolved:
        manifest["unresolvedGuids"] = unresolved
    if builtin_entries:
        manifest["builtinEntries"] = builtin_entries
    if meta_dups:
        manifest["duplicateMetaGuids"] = [
            OrderedDict([("guid", g), ("kept", a), ("ignored", b)]) for g, a, b in sorted(meta_dups)
        ]

    out_dir = os.path.dirname(out_path)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
    with open(out_path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)
        f.write("\n")

    size = os.path.getsize(out_path)
    print("[manifest] out           : %s (%.1f KB)" % (out_path, size / 1024.0))
    print("[manifest] addresses     : %d (entries %d, unique paths %d)" % (len(addresses), entry_total, len(unique_paths)))
    print("[manifest] folder expand : %d folders -> %d children" % (folder_entry_count, expanded_child_count))
    print("[manifest] by type       : %s" % json.dumps(by_type, ensure_ascii=False))
    print("[manifest] missing files : %d (unique paths %d)" % (missing_count, stats["missingFileCountUnique"]))
    print("[manifest] unresolved    : %d, builtin skipped: %d, duplicate addresses: %d (same path: %d)"
          % (len(unresolved), len(builtin_entries), len(duplicate_addresses), len(same_path_dups)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
