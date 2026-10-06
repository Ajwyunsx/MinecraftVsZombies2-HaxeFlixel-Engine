#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""场景/prefab 数据 -> Haxe 字段 的可写性静态校验（工作包 ②）

`ScenePrefabLoader` 重建对象图时，`ScenePrefabFieldApplier` 按名字把导出数据写进组件字段。
它在 hxcpp 上不做类型检查（`Reflect.setField` 对 `String`/`Int` 字段写错类型不会立刻报错，
下次读取才段错误），所以**必须在转换期**发现「数据形态与字段声明类型不匹配」。

本脚本离线复刻 `ModelPrefabContext.decode` + `ScenePrefabFieldApplier` 的判定逻辑，
对 `assets/scene_prefabs/**` 的每条字段记录做检查，输出会**在运行期崩溃或写错类型**的组合。

判定规则（与 ScenePrefabFieldApplier 一致）：
  * 引用 `{n[,c]}`          -> 目标字段必须是类/接口类型（或 Dynamic）
  * 资产 `{asset}`          -> 目标字段必须是 unity.Sprite / Material 等，或 Dynamic
  * 结构体 `{t,v}`          -> 目标字段必须是同族 unity 结构体（Vector2/3/4/Color/Rect/Quaternion）
                              或 Dynamic（decode 会 new 出结构体）
  * 无标记 dict             -> **危险**：decode 会造匿名对象。目标字段是类/结构体/数组时，
                              运行期拿到的不是期望类型（`Array.copy`/方法调用会空引用）。
                              只有 Dynamic / 匿名对象字段可以接受。
  * 数组                  -> 目标字段必须是 Array<T>；元素递归检查
  * 标量                  -> 目标字段必须是标量/枚举/Dynamic

用法：
    python HaxePort/tools_build/check_scene_apply.py            # 摘要 + 明细
    python HaxePort/tools_build/check_scene_apply.py --json
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sys
from collections import Counter

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_PORT_DIR = os.path.dirname(SCRIPT_DIR)

# Haxe 类：`class Foo extends Bar {` —— 用来建立继承链（继承来的字段也要能查）。
CLASS_RE = re.compile(r"^\s*(?:@:\w+(?:\([^)]*\))?\s*)?(?:public|private|final|abstract|\s)*"
                      r"class\s+([A-Za-z_]\w*)\s*(?:<[^>]*>)?\s*(?:extends\s+([\w.]+))?", re.M)
# Haxe 字段：`var foo:Type` / `var foo(default, null):Type` / 属性 `var foo(get, set):Type`，捕获初始化表达式。
FIELD_RE = re.compile(r"^\s*(?:@:\w+(?:\([^)]*\))?\s*)*"
                      r"(?:public|private|static|inline|override|dynamic|\s)*"
                      r"var\s+([A-Za-z_]\w*)\s*(?:\([^)]*\))?\s*:\s*([^=;\n]+?)"
                      r"(?:\s*=\s*([^;\n]+))?;", re.M)
# Haxe 枚举抽象：`enum abstract Foo(Int) {` —— 这些类型的字段可以接受标量。
ENUM_ABSTRACT_RE = re.compile(r"enum\s+abstract\s+([A-Za-z_]\w*)\s*\(\s*([\w.]+)\s*\)")

SCALAR_TYPES = {"Int", "Float", "Bool", "String", "Dynamic", "Void"}


def parse_haxe_classes(port_dir: str) -> dict:
    """`haxe 全限定类名 -> {字段: 类型}`（含继承字段，子类覆盖父类）。"""
    source_root = os.path.join(port_dir, "source")
    per_file: dict = {}
    enum_abstracts: set = set()
    for path in glob.glob(os.path.join(source_root, "**", "*.hx"), recursive=True):
        rel = os.path.relpath(path, port_dir).replace("\\", "/")
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                text = f.read()
        except OSError:
            continue
        for em in ENUM_ABSTRACT_RE.finditer(text):
            enum_abstracts.add(em.group(1))
        pkg_match = re.search(r"^\s*package\s+([\w.]+)\s*;", text, re.M)
        package = pkg_match.group(1) if pkg_match else ""
        module = os.path.splitext(os.path.basename(path))[0]
        # 一个模块可能有多个类型（主类型 = 模块名）。
        for match in CLASS_RE.finditer(text):
            name, parent = match.group(1), match.group(2)
            full = (package + "." + name) if package else name
            # 只取该类自身的字段（粗略：从 class 头到下一个 class 头）。
            body_start = match.end()
            nxt = CLASS_RE.search(text, body_start)
            body = text[body_start:nxt.start()] if nxt else text[body_start:]
            fields = {}
            for fm in FIELD_RE.finditer(body):
                fields.setdefault(fm.group(1), fm.group(2).strip())
            per_file[full] = {"parent": parent, "fields": fields, "file": rel}
    # 合并继承字段（父类字段对子类可见；`extends` 若是同包简名则补包名）。
    resolved: dict = {}

    def resolve(full, seen=None):
        if full in resolved:
            return resolved[full]
        info = per_file.get(full)
        if info is None:
            return {}
        merged = {}
        parent = info["parent"]
        if parent is not None:
            parent_full = parent
            if "." not in parent:
                pkg = full.rpartition(".")[0]
                if (pkg + "." + parent) in per_file:
                    parent_full = pkg + "." + parent
            merged.update(resolve(parent_full, seen))
        merged.update(info["fields"])
        resolved[full] = merged
        return merged

    for full in per_file:
        resolve(full)
    return ({full: {"fields": resolved.get(full, {}), "file": per_file[full]["file"]}
             for full in per_file},
            enum_abstracts)


def collect_exported(port_dir: str):
    """产出 (prefabKey, nodeIndex, nodeName, script, field, rawValue) 记录。"""
    records = []
    for path in glob.glob(os.path.join(port_dir, "assets", "scene_prefabs", "**", "*.json"),
                          recursive=True):
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
        except (OSError, ValueError):
            continue
        for i, node in enumerate(data.get("nodes", [])):
            for comp in node.get("components", []):
                script = comp.get("script")
                if script is None:
                    continue
                for field, value in (comp.get("fields") or {}).items():
                    records.append((data["key"], i, node["name"], script, field, value))
    return records


def raw_kind(value) -> str:
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "bool"
    if isinstance(value, (int, float)):
        return "number"
    if isinstance(value, str):
        return "string"
    if isinstance(value, list):
        return "array"
    if isinstance(value, dict):
        if "n" in value:
            return "ref"
        if "asset" in value:
            return "asset"
        if "t" in value:
            return "struct"
        return "dict"
    return "unknown"


STRUCT_TAGS = {"Vector2", "Vector3", "Vector4", "Quaternion", "Color", "Color32", "Rect"}
STRUCT_TYPES = {"Vector2", "Vector3", "Vector4", "Quaternion", "Color", "Color32", "Rect", "Bounds"}


def base_type(type_text: str) -> str:
    t = type_text.strip()
    # Null<T> / Array<T> / Map<K,V> 等
    if t.startswith("Null<") and t.endswith(">"):
        t = t[5:-1]
    # unity.Vector2 -> Vector2（结构体可能写成限定名）
    if t.startswith("unity.") and t[6:] in STRUCT_TYPES:
        t = t[6:]
    return t


def classify_mismatch(raw, type_text: str, enum_abstracts: set):
    """返回 None（可写）或原因字符串。"""
    if type_text is None:
        return None  # 字段没在 Haxe 侧找到（由 ScenePrefabLoader.missingFields 统计）
    kind = raw_kind(raw)
    t = base_type(type_text)
    is_dynamic = t in ("Dynamic", "Any")
    if is_dynamic:
        return None
    if kind == "null":
        return None
    if kind in ("bool", "number", "string"):
        if t in SCALAR_TYPES:
            return None
        # 枚举抽象（enum abstract Foo(Int)）的字段可以接受标量：hxcpp 上就是 Int。
        if t.rpartition(".")[2] in enum_abstracts:
            return None
        if t in STRUCT_TYPES:
            # 标量写进结构体字段：decode 直接返回标量 -> 字段被写成数字，之后读属性崩。
            return "标量 -> 结构体字段"
        # 数字写进 String / String 写进 Int 都会被 ScenePrefabFieldApplier.isAssignable 拦住（记 missing）
        return "标量 -> 非标量字段"
    if kind == "struct":
        tag = raw.get("t")
        if t in STRUCT_TYPES:
            return None if (tag == t or (tag == "Vector4" and t == "Quaternion")) else \
                "结构体 %s -> %s 字段" % (tag, t)
        if t.startswith("Array<"):
            return None
        return "结构体 %s -> %s 字段" % (tag, t)
    if kind in ("ref", "asset"):
        if t in SCALAR_TYPES or t in STRUCT_TYPES:
            return "%s -> %s 字段" % (kind, t)
        if t.startswith("Array<"):
            return "%s -> 数组字段" % kind
        return None
    if kind == "array":
        if not t.startswith("Array<"):
            return "数组 -> %s 字段" % t
        inner = t[6:-1] if t.endswith(">") else "Dynamic"
        # 元素类型检查（取数组第一个非 null 元素）。
        for item in raw:
            if item is None:
                continue
            reason = classify_mismatch(item, inner, enum_abstracts)
            if reason is not None:
                return "数组元素：%s" % reason
            break
        return None
    if kind == "dict":
        # decode 会造匿名对象。目标字段是类/结构体/数组时，运行期类型不符。
        if t == "Dynamic":
            return None
        return "无标记 dict -> %s 字段（decode 造匿名对象）" % t
    return None


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--port-dir", default=DEFAULT_PORT_DIR)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args(argv)

    classes, enum_abstracts = parse_haxe_classes(args.port_dir)
    by_simple: dict = {}
    for full, info in classes.items():
        by_simple.setdefault(full.rpartition(".")[2], []).append(full)

    records = collect_exported(args.port_dir)
    problems = []
    for key, index, node_name, script, field, value in records:
        simple = script.rpartition(".")[2]
        candidates = by_simple.get(simple, [])
        type_text = None
        for full in candidates:
            if field in classes[full]["fields"]:
                type_text = classes[full]["fields"][field]
                break
        reason = classify_mismatch(value, type_text, enum_abstracts)
        if reason is not None:
            problems.append({
                "prefab": key, "node": index, "nodeName": node_name, "script": script,
                "field": field, "type": type_text, "rawKind": raw_kind(value),
                "reason": reason,
                "rawSample": json.dumps(value, ensure_ascii=False)[:160],
            })

    if args.json:
        print(json.dumps({"total": len(records), "problems": problems},
                         ensure_ascii=False, indent=1))
        return 0

    print("字段记录总数：%d，可疑组合：%d" % (len(records), len(problems)))
    counter = Counter((p["script"], p["field"], p["type"], p["reason"]) for p in problems)
    print("\n按 (脚本, 字段, 声明类型, 原因) 聚合：")
    for (script, field, type_text, reason), count in counter.most_common():
        print("  %5d  %s.%s : %s  <- %s" % (count, script, field, type_text, reason))
        for p in problems:
            if p["script"] == script and p["field"] == field:
                print("         e.g. %s/%s(%d) %s" % (p["prefab"], p["nodeName"], p["node"],
                                                      p["rawSample"]))
                break
    return 0


if __name__ == "__main__":
    sys.exit(main())
