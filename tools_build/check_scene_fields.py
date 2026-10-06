#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""关卡/UI prefab 序列化字段覆盖审计（工作包 ②）

对 `source/` 里每一个 `@:serializeField` 字段，回答三个问题：

  1. **有数据吗** —— 导出的 `assets/scene_prefabs/**` 里，同一 C# 脚本类 + 同名字段是否有值？
  2. **有初值吗** —— Haxe 声明里是否写了初始化表达式（对应 C# 的字段初始化器）？
  3. **C# 原声明是什么** —— 从 `Assets/Scripts/**` 的同名 .cs 里读出 `[SerializeField]` 声明原文，
     用来判断「零值兜底」是否等价于 C# 的缺数据行为。

输出三类：

  A. `no-data, no-initializer`  —— 数据缺失 **且** 声明没有初值 → 运行期是 null/0，最容易空引用。
  B. `no-data, zero-init`       —— 数据缺失，但已按 PORTING.md 的「C# struct 默认值」显式零初始化。
                                  值域等价于 C# 的 default（不是 null），属于「待补真值」。
  C. `has-data`                 —— 导出数据里有值，运行期由 `ScenePrefabLoader` / `ScenePrefabInjector`
                                  写入（无需兜底）。

用法（仓库根目录）：

    python HaxePort/tools_build/check_scene_fields.py            # 摘要 + 分类清单
    python HaxePort/tools_build/check_scene_fields.py --json     # 机器可读
    python HaxePort/tools_build/check_scene_fields.py --only-no-data
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_PORT_DIR = os.path.dirname(SCRIPT_DIR)
DEFAULT_PROJECT_ROOT = os.path.dirname(DEFAULT_PORT_DIR)

# Haxe 侧：`@:serializeField` 后面紧跟的字段声明（可能跨行）。
#   @:serializeField
#   private var foo:Bar = new Bar();
SERIALIZE_FIELD_RE = re.compile(
    r"@:serializeField\s*\n\s*(?:@:[^\n]*\n\s*)*"
    r"(?:public|private|static|inline)*\s*var\s+([A-Za-z_]\w*)\s*:\s*([^=;\n]+?)\s*(?:=\s*(.+?))?;",
    re.S,
)

# C# 侧：`[SerializeField]` 后面紧跟的字段声明。
CS_SERIALIZE_FIELD_RE = re.compile(
    r"\[\s*SerializeField\s*\]\s*(?:\[[^\]]*\]\s*)*"
    r"(?:public|private|protected|internal|static|readonly|\s)*"
    r"(?:\w+(?:<[^>]*>)?(?:\[\])?(?:\?)?)\s+([A-Za-z_]\w*)\s*(?:=\s*([^;]+?))?\s*;",
    re.S,
)

# Haxe 的 unity 结构体零值：这些类型的字段在 C# 里是 struct，default 恒为零值。
ZERO_INIT_RE = re.compile(
    r"new\s+(?:unity\.)?(Vector2|Vector3|Vector4|Color|Color32|Quaternion|Rect|Bounds|Matrix4x4)\s*\("
)


def haxe_class_simple_name(haxe_class: str) -> str:
    return haxe_class.rpartition(".")[2]


def resolve_script_name(haxe_class: str, exported_names, cs_names=()) -> str:
    """Haxe 全限定类名 -> 导出数据里的 C# 脚本全名。

    PORTING.md 的映射规则是「namespace 全小写、类名不变」，但小写是不可逆的
    （`MVZ2.Grids` -> `mvz2.grids` 可以，反向不行）。所以这里以**类名不变**为准，
    在候选脚本名里找同名类；找不到时退回「包名小写 + 类名」的猜测（诊断输出用）。

    `cs_names` 是 C# 侧的类名集合：抽象基类（`BlueprintSet` / `Dialog` / `ClassicBlueprintSet`）
    不会出现在导出数据里，但它们的字段声明需要从 .cs 里读，所以两个集合都要查。
    """
    simple = haxe_class_simple_name(haxe_class)
    pkg, _, _ = haxe_class.rpartition(".")
    for names in (exported_names, cs_names):
        candidates = [name for name in names if name.rpartition(".")[2] == simple]
        if not candidates:
            continue
        if len(candidates) == 1:
            return candidates[0]
        if pkg:
            # 同名多类（不同命名空间）时用包名匹配。
            for name in candidates:
                if name.rpartition(".")[0].lower() == pkg:
                    return name
        return candidates[0]
    return haxe_class


def collect_exported_fields(port_dir: str) -> dict:
    """从 assets/scene_prefabs/** 收集 `脚本全名 -> {字段 -> 出现次数}`。"""
    result: dict = {}
    pattern = os.path.join(port_dir, "assets", "scene_prefabs", "**", "*.json")
    for path in glob.glob(pattern, recursive=True):
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
        except (OSError, ValueError):
            continue
        for node in data.get("nodes", []):
            for comp in node.get("components", []):
                name = comp.get("script")
                if name is None:
                    continue
                bucket = result.setdefault(name, {})
                for field, value in (comp.get("fields") or {}).items():
                    bucket[field] = bucket.get(field, 0) + 1
    return result


def collect_cs_serialize_fields(project_root: str) -> dict:
    """从 Assets/Scripts/** 收集 `C# 全名 -> {字段 -> 声明原文}`（含 `[SerializeField]` 所在行）。

    PORT-NOTE: 一个 .cs 文件里可能有多个类（抽象基类 + 派生类、嵌套类），所以这里按
    **每个 class 声明**分别切分正文再取字段，而不是只取文件里的第一个类 ——
    否则 `ClassicBlueprintSet.slots`、`Dialog.dialogTransform` 这类基类字段查不到声明。
    """
    result: dict = {}
    root = os.path.join(project_root, "Assets", "Scripts")
    class_re = re.compile(r"^\s*(?:public|internal|sealed|abstract|partial|static|\s)*"
                          r"(?:class|struct)\s+([A-Za-z_]\w*)", re.M)
    for path in glob.glob(os.path.join(root, "**", "*.cs"), recursive=True):
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                text = f.read()
        except OSError:
            continue
        if "SerializeField" not in text:
            continue
        ns_match = re.search(r"^\s*namespace\s+([\w.]+)", text, re.M)
        namespace = ns_match.group(1) if ns_match else ""
        matches = list(class_re.finditer(text))
        for i, cls_match in enumerate(matches):
            cls_name = cls_match.group(1)
            body_start = cls_match.end()
            body_end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
            body = text[body_start:body_end]
            if "SerializeField" not in body:
                continue
            full = (namespace + "." + cls_name) if namespace else cls_name
            bucket = result.setdefault(full, {})
            for match in CS_SERIALIZE_FIELD_RE.finditer(body):
                field = match.group(1)
                bucket[field] = match.group(0).strip().replace("\n", " ")
    return result


def collect_haxe_serialize_fields(port_dir: str) -> list:
    """扫描 source/**/*.hx，返回 `@:serializeField` 字段记录列表。"""
    records = []
    root = os.path.join(port_dir, "source")
    for path in glob.glob(os.path.join(root, "**", "*.hx"), recursive=True):
        rel = os.path.relpath(path, port_dir).replace("\\", "/")
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                text = f.read()
        except OSError:
            continue
        if "@:serializeField" not in text:
            continue
        # 包名与主类型名（模块名 == 主类型名，PORTING.md 约定）。
        pkg_match = re.search(r"^\s*package\s+([\w.]+)\s*;", text, re.M)
        package = pkg_match.group(1) if pkg_match else ""
        module = os.path.splitext(os.path.basename(path))[0]
        haxe_class = (package + "." + module) if package else module
        for match in SERIALIZE_FIELD_RE.finditer(text):
            field, type_text, init = match.group(1), match.group(2), match.group(3)
            line = text[:match.start()].count("\n") + 1
            records.append({
                "file": rel,
                "line": line,
                "haxeClass": haxe_class,
                "script": None,
                "field": field,
                "type": type_text.strip(),
                "init": (init or "").strip(),
            })
    return records


def classify(record: dict, exported: dict, cs_fields: dict, subclass_closure: dict) -> str:
    """判断字段的数据来源。

    PORT-NOTE: C# 的 `[SerializeField]` 字段是**继承**的（`ClassicBlueprintSet.slots` 的实际数据
    落在子类 `BlueprintArray` / `BlueprintList` 的组件上，`Dialog.dialogTransform` 落在
    `CustomDialog` / `InputNameDialog` / `DeleteUserDialog` 上）。所以「有没有数据」必须连同
    **子类**一起查，否则会把正常的继承数据误判成缺数据。
    """
    names = subclass_closure.get(record["script"], [record["script"]])
    has_data = any(record["field"] in exported.get(name, {}) for name in names)
    if has_data:
        return "has-data"
    init = record["init"]
    if not init:
        return "no-data-no-init"
    if ZERO_INIT_RE.search(init):
        return "no-data-zero-init"
    return "no-data-other-init"


def build_subclass_closure(cs_fields: dict, exported: dict) -> dict:
    """`脚本全名 -> [自身 + 全部派生类脚本名]`（按 .cs 的 `class X : Y` 关系）。"""
    project_root = DEFAULT_PROJECT_ROOT
    parents: dict = {}
    class_re = re.compile(r"^\s*(?:public|internal|sealed|abstract|partial|static|\s)*"
                          r"(?:class|struct)\s+([A-Za-z_]\w*)\s*(?::\s*([\w.]+))?", re.M)
    for path in glob.glob(os.path.join(project_root, "Assets", "Scripts", "**", "*.cs"),
                          recursive=True):
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                text = f.read()
        except OSError:
            continue
        ns_match = re.search(r"^\s*namespace\s+([\w.]+)", text, re.M)
        namespace = ns_match.group(1) if ns_match else ""
        for match in class_re.finditer(text):
            name, parent = match.group(1), match.group(2)
            full = (namespace + "." + name) if namespace else name
            if parent is None:
                parents.setdefault(full, None)
                continue
            # 父类可能是同命名空间简名，也可能带命名空间。
            parent_full = parent if "." in parent else ((namespace + "." + parent) if namespace else parent)
            parents[full] = parent_full
    known = set(cs_fields) | set(exported) | set(parents)
    closure: dict = {}
    for full in known:
        chain = [full]
        cur = parents.get(full)
        seen = {full}
        while cur is not None and cur not in seen:
            seen.add(cur)
            chain.append(cur)
            cur = parents.get(cur)
        closure[full] = chain
    # 反向：把派生类并到祖先的链上（判断「字段有没有数据」时要看全部派生类）。
    result: dict = {}
    for full, chain in closure.items():
        for ancestor in chain:
            result.setdefault(ancestor, set()).add(full)
    return {k: sorted(v) for k, v in result.items()}


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--port-dir", default=DEFAULT_PORT_DIR)
    parser.add_argument("--project-root", default=DEFAULT_PROJECT_ROOT)
    parser.add_argument("--json", action="store_true", help="输出 JSON")
    parser.add_argument("--only-no-data", action="store_true", help="只列没有数据的字段")
    parser.add_argument("--limit", type=int, default=0, help="每类最多列多少条（0=全部）")
    args = parser.parse_args(argv)

    exported = collect_exported_fields(args.port_dir)
    cs_fields = collect_cs_serialize_fields(args.project_root)
    subclass_closure = build_subclass_closure(cs_fields, exported)
    records = collect_haxe_serialize_fields(args.port_dir)

    for record in records:
        record["script"] = resolve_script_name(record["haxeClass"], exported.keys(), cs_fields.keys())
        record["kind"] = classify(record, exported, cs_fields, subclass_closure)
        names = subclass_closure.get(record["script"], [record["script"]])
        cs = cs_fields.get(record["script"], {})
        for name in names:
            if record["field"] in cs_fields.get(name, {}):
                cs = cs_fields[name]
                break
        record["csDecl"] = cs.get(record["field"])
        record["csHasSerializeField"] = record["field"] in cs
        record["dataCount"] = sum(exported.get(name, {}).get(record["field"], 0) for name in names)
        record["dataSources"] = [name for name in names if record["field"] in exported.get(name, {})]

    groups: dict = {}
    for record in records:
        groups.setdefault(record["kind"], []).append(record)

    if args.json:
        print(json.dumps({"records": records,
                          "summary": {k: len(v) for k, v in groups.items()}},
                         ensure_ascii=False, indent=1))
        return 0

    print("Haxe @:serializeField 字段总数：%d" % len(records))
    for kind in ("has-data", "no-data-zero-init", "no-data-other-init", "no-data-no-init"):
        print("  %-20s %d" % (kind, len(groups.get(kind, []))))

    def dump(kind, title):
        items = groups.get(kind, [])
        if not items:
            return
        print("\n=== %s（%d 条）===" % (title, len(items)))
        shown = items if args.limit <= 0 else items[:args.limit]
        for record in shown:
            cs = ("  C#: " + record["csDecl"]) if record["csDecl"] else "  C#: (未在 Assets/Scripts 找到同名声明)"
            print("  %s:%d %s.%s : %s%s" % (record["file"], record["line"], record["script"],
                                            record["field"], record["type"],
                                            (" = " + record["init"]) if record["init"] else ""))
            print(cs)
        if args.limit > 0 and len(items) > args.limit:
            print("  …（还有 %d 条，--limit 0 看全部）" % (len(items) - args.limit))

    if args.only_no_data:
        dump("no-data-no-init", "A. 无数据且无初值（运行期 null/0，最危险）")
        dump("no-data-other-init", "A2. 无数据但有非零初值（C# 字段初始化器）")
        dump("no-data-zero-init", "B. 无数据但已零初始化（值域等价 C# default，待补真值）")
    else:
        dump("no-data-no-init", "A. 无数据且无初值（运行期 null/0，最危险）")
        dump("no-data-other-init", "A2. 无数据但有非零初值（C# 字段初始化器）")
        dump("no-data-zero-init", "B. 无数据但已零初始化（值域等价 C# default，待补真值）")
        dump("has-data", "C. 有导出数据（运行期由 prefab 注入）")

    # 反向检查：导出数据里有、但 Haxe 侧没有对应 @:serializeField 的字段（可能是漏移植的字段）。
    haxe_index = {(r["script"], r["field"]) for r in records}
    missing_in_haxe = []
    for script, fields in exported.items():
        if not script.startswith("MVZ2."):
            continue
        for field in fields:
            if (script, field) not in haxe_index and field != "enabled":
                missing_in_haxe.append((script, field))
    if missing_in_haxe:
        print("\n=== D. 导出数据有、Haxe 侧无 @:serializeField 声明（可能漏移植）: %d ==="
              % len(missing_in_haxe))
        for script, field in sorted(missing_in_haxe):
            print("  %s.%s" % (script, field))
    return 0


if __name__ == "__main__":
    sys.exit(main())
