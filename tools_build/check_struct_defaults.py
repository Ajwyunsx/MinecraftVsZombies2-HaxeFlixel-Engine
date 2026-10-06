#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Scanner / regression check for 「C# struct 默认值 vs Haxe null」地雷（工作包 G）。

背景
----
C# 的 UnityEngine 值类型（`Vector2/Vector3/Vector4/Color/Rect/Bounds/Quaternion/...`）是 struct：
字段即使不写初始化表达式也**永远不为 null**，默认值是"全零"（`Color` 是 (0,0,0,0) 透明黑）。
移植层把这些类型做成了 `abstract over class`（引用类型），于是同一份声明在 Haxe 里就是 null，
任何字段读取在 cpp 上都是空引用（debug 构建 `Null Object Reference`，release 构建 0xC0000005）。

本脚本扫描 `source/**/*.hx`，找出**类字段/静态字段**中「声明为这些 struct 类型、且没有初始化
表达式」的位置，并对照 `Assets/Scripts/**` 的 C# 原声明判断正确默认值：

* `C# 无初始化表达式`  → 应补 `default(T)`（零值）——即本工作包批量修复的情形；
* `C# 有初始化表达式`  → 必须翻译 C# 的初始化值（例如 `= Vector3.one * 0.5f`），不能一律置零；
* 找不到同名类的 C# 声明 → 需要人工核对（属性、分部类、shim 内部字段等）。

用法
----
    python tools_build/check_struct_defaults.py            # 打印报告（含 C# 证据）
    python tools_build/check_struct_defaults.py --check    # 回归检查：仍有未初始化字段则退出码 1
    python tools_build/check_struct_defaults.py --locals   # 额外列出函数内局部变量（C# 有明确赋值保证）

函数内局部变量不算字段：C# 的明确赋值规则保证它们在被读之前一定被赋值（Haxe 侧同结构即安全），
脚本把它们单独列出来供人工复核，默认不计入 `--check` 的失败。
"""
import argparse
import json
import os
import re
import sys
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))       # 仓库根目录
HAXE_SRC = os.path.join(ROOT, "HaxePort", "source")
CS_ROOT = os.path.join(ROOT, "Assets", "Scripts")

# C# struct 的 Unity 值类型（会出现「C# 默认值 vs Haxe null」地雷的全部类型）
STRUCT_TYPES = ["Vector2", "Vector3", "Vector4", "Color", "Rect", "Bounds",
                "Color32", "Quaternion", "Matrix4x4", "Vector2Int", "Vector3Int"]

FIELD_RE = re.compile(
    r"^(?:(?:@:\w+(?:\([^)]*\))?|public|private|static|inline|final|extern|override|dynamic|macro)\s+)*"
    r"var\s+([A-Za-z_]\w*)\s*:\s*(.+?)\s*(?:=\s*(.*?))?;\s*$"
)
TYPE_OPEN = re.compile(r"\b(?:class|struct|interface|enum)\s+([A-Za-z_]\w*)")
TYPE_DECL_RE = re.compile(r"\b(class|abstract|interface|enum)\s+([A-Za-z_]\w*)")


def strip_comments_strings(text):
    """把注释/字符串挖空（保持长度与行号），便于做基于 `{ } ;` 的块结构分析。"""
    out = []
    i, n = 0, len(text)
    state = None
    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if state is None:
            if c == "/" and nxt == "/":
                state = "line"; out.append("  "); i += 2; continue
            if c == "/" and nxt == "*":
                state = "block"; out.append("  "); i += 2; continue
            if c == "'":
                state = "sq"; out.append(" "); i += 1; continue
            if c == '"':
                state = "dq"; out.append(" "); i += 1; continue
            out.append(c); i += 1
        elif state == "line":
            out.append("\n" if c == "\n" else " ")
            if c == "\n":
                state = None
            i += 1
        elif state == "block":
            if c == "*" and nxt == "/":
                state = None; out.append("  "); i += 2; continue
            out.append("\n" if c == "\n" else " "); i += 1
        else:
            if c == "\\":
                out.append("  "); i += 2; continue
            if (state == "sq" and c == "'") or (state == "dq" and c == '"'):
                state = None
            out.append("\n" if c == "\n" else " "); i += 1
    return "".join(out)


def type_base(t):
    """`Vector2` / `unity.Vector2` / `Null<Vector2>` -> (kind, base)。"""
    t = t.strip()
    t = re.sub(r"^unity\.", "", t)
    if re.fullmatch(r"[A-Za-z_]\w*", t):
        return "plain", t
    m = re.fullmatch(r"Null<([A-Za-z_][\w\.]*)>", t)
    if m:
        return "nullable", re.sub(r"^unity\.", "", m.group(1))
    return "other", t


def scan_haxe(path):
    """返回该文件里所有「struct 类型 + 无初始化表达式」的 var 声明。"""
    raw = open(path, encoding="utf-8", errors="replace").read()
    if raw.startswith("\ufeff"):
        raw = raw[1:]
    code = strip_comments_strings(raw)
    raw_lines = raw.split("\n")

    headers = []
    for i, ln in enumerate(raw_lines, start=1):
        m = re.match(r"//\s*Ported from:\s*(\S+)", ln.strip())
        if m:
            headers.append((i, m.group(1)))

    hits = []
    stack = []          # "type" / "func" / "block"
    type_names = []
    stmt = ""
    stmt_line = 1
    line = 1
    for ch in code:
        if ch == "\n":
            stmt += " "
            line += 1
            continue
        if ch == "{":
            s = stmt.strip()
            if re.search(r"\b(class|abstract|interface|enum)\b", s):
                tm = TYPE_DECL_RE.search(s)
                stack.append("type")
                type_names.append(tm.group(2) if tm else "?")
            elif re.search(r"\bfunction\b", s) or re.search(r"\)\s*(:[^=;()]*)?$", s) or re.search(r"\bnew\s*\(.*\)\s*$", s):
                stack.append("func")
                type_names.append(None)
            else:
                stack.append("block")
                type_names.append(None)
            stmt = ""
            continue
        if ch == "}":
            if stack:
                stack.pop()
                type_names.pop()
            stmt = ""
            continue
        if ch == ";":
            s = (stmt + ";").strip()
            m = FIELD_RE.match(s)
            if m:
                name, typ, init = m.group(1), m.group(2), m.group(3)
                kind, base = type_base(typ)
                if init is None and base in STRUCT_TYPES:
                    hdr = next((p for (l, p) in reversed(headers) if l <= stmt_line), headers[0][1] if headers else "")
                    hits.append(dict(
                        file=os.path.relpath(path, ROOT).replace("\\", "/"),
                        line=stmt_line, decl_line=line, text=raw_lines[line - 1].rstrip(),
                        name=name, type=typ, base=base, base_kind=kind,
                        scope=stack[-1] if stack else None,
                        enclosing=next((n for k, n in zip(reversed(stack), reversed(type_names)) if k == "type"), None),
                        cs_file=hdr,
                    ))
            stmt = ""
            continue
        if stmt.strip() == "" and ch not in " \t":
            stmt_line = line
        stmt += ch
    return hits


def cs_decls(cs_path):
    """列出 C# 文件里所有类层级的字段/属性声明（含 [attribute] 行、Allman 花括号）。"""
    code = strip_comments_strings(open(cs_path, encoding="utf-8-sig", errors="replace").read())
    lines = code.split("\n")
    raw_lines = code.split("\n")
    stack = []
    stmt = ""
    decls = []
    for i, ln in enumerate(lines, start=1):
        if not ln.strip():
            stmt = ""
            continue
        for ch in ln:
            if ch == "{":
                s0 = stmt.strip()
                m = TYPE_OPEN.search(s0)
                pm = re.match(
                    r"^(?:(?:\[[^\]]*\]\s*)*)"
                    r"(?:(?:public|private|protected|internal|static|readonly|const|volatile|new|override|virtual|sealed|abstract|partial|extern|unsafe|event)\s+)*"
                    r"(?P<type>[A-Za-z_][\w\.]*(?:<[^;=(){}]*?>)?(?:\[\])?(?:\?)?)\s+(?P<name>[A-Za-z_]\w*)$", s0)
                if m and re.search(r"\b(class|struct|interface|enum)\b", stmt):
                    stack.append(m.group(1))
                elif pm:
                    decls.append(dict(line=i, class_name=next((n for n in reversed(stack) if n), None),
                                      stmt=s0, indent=len(ln) - len(ln.lstrip()), is_prop=True,
                                      ptype=pm.group("type"), pname=pm.group("name")))
                    stack.append(None)
                else:
                    stack.append(None)
                stmt = ""
            elif ch == "}":
                if stack:
                    stack.pop()
                stmt = ""
            elif ch == ";":
                s = (stmt + ";").strip()
                decls.append(dict(line=i, class_name=next((n for n in reversed(stack) if n), None),
                                  stmt=s, indent=len(ln) - len(ln.lstrip()), is_prop=False,
                                  ptype=None, pname=None))
                stmt = ""
            else:
                stmt += ch
    # 解析出 (class, 字段名, 类型, 有无初始化)
    out = []
    for d in decls:
        if d["is_prop"]:
            out.append(dict(line=d["line"], class_name=d["class_name"], name=d["pname"],
                            type=d["ptype"], tail="{prop}", indent=d["indent"], raw=d["stmt"]))
            continue
        m = re.match(
            r"^(?:(?:\[[^\]]*\]\s*)*)"
            r"(?:(?:public|private|protected|internal|static|readonly|const|volatile|new|override|virtual|sealed|abstract|partial|extern|unsafe|event)\s+)*"
            r"(?P<type>[A-Za-z_][\w\.]*(?:<[^;=(){}]*?>)?(?:\[\])?(?:\?)?)\s+(?P<name>[A-Za-z_]\w*)"
            r"\s*(?P<tail>(=[^;]*)?\{[^}]*\}|=>[^;]*|=[^;]*)?\s*;\s*$", d["stmt"])
        if not m or "(" in d["stmt"][:m.start("name")]:
            continue
        out.append(dict(line=d["line"], class_name=d["class_name"], name=m.group("name"),
                        type=m.group("type"), tail=(m.group("tail") or "").strip(), indent=d["indent"],
                        raw=d["stmt"]))
    return out


def classify(hit, cache):
    """返回 (category, C# 证据)。category: CS_DEFAULT / CS_INIT / CS_EXPRBODY / CS_AUTOPROP / NO_CS。"""
    cs_rel = hit["cs_file"]
    if not cs_rel:
        return "NO_CS", []
    p = os.path.join(ROOT, cs_rel.replace("/", os.sep))
    if not os.path.exists(p):
        return "NO_CS", []
    if p not in cache:
        cache[p] = cs_decls(p)
    cands = []
    for d in cache[p]:
        if d["name"] != hit["name"] or d["class_name"] != hit["enclosing"]:
            continue
        ct = d["type"].split(".")[-1]
        if ct != hit["base"] and not (hit["base"] == "Color" and ct == "Color32"):
            continue
        cands.append(d)
    cands.sort(key=lambda d: (d["indent"], d["line"]))
    if not cands:
        return "NO_CS", []
    top = cands[0]
    if top["tail"].startswith("="):
        return "CS_INIT", cands
    if top["tail"].startswith("=>"):
        return "CS_EXPRBODY", cands
    if top["tail"].startswith("{"):
        return "CS_AUTOPROP", cands
    return "CS_DEFAULT", cands


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="发现未初始化字段即退出码 1")
    ap.add_argument("--locals", action="store_true", help="同时列出函数内局部变量")
    ap.add_argument("--json", default=None, help="把完整结果写到该 json 文件")
    args = ap.parse_args()

    hits = []
    for dirpath, _d, fns in os.walk(HAXE_SRC):
        for fn in sorted(fns):
            if fn.endswith(".hx"):
                hits.extend(scan_haxe(os.path.join(dirpath, fn)))

    fields = [h for h in hits if h["scope"] == "type"]
    locals_ = [h for h in hits if h["scope"] != "type"]

    cache = {}
    cat = Counter()
    needs_manual = []
    for h in fields:
        c, evidence = classify(h, cache)
        h["category"] = c
        h["cs_evidence"] = evidence[:2]
        cat[c] += 1
        if c != "CS_DEFAULT":
            needs_manual.append(h)

    print("[struct-defaults] 未初始化的 struct 类型「类字段/静态字段」: %d 处" % len(fields))
    print("[struct-defaults] 按类型: %s" % dict(Counter(h["base"] for h in fields)))
    print("[struct-defaults] 按 C# 语义: %s" % dict(cat))
    print("[struct-defaults] 函数内局部变量（C# 明确赋值保证，仅供参考）: %d 处" % len(locals_))

    if needs_manual:
        print("\n需要人工核对（C# 有初始化表达式 / 属性 / 找不到同名类声明）：")
        for h in needs_manual:
            print("  %s:%d %s:%s [class=%s] -> %s" % (h["file"], h["decl_line"], h["name"], h["type"],
                                                      h["enclosing"], h["category"]))
            for d in h["cs_evidence"]:
                print("      C# L%d %s" % (d["line"], d["raw"]))

    if args.locals and locals_:
        print("\n函数内局部变量：")
        for h in sorted(locals_, key=lambda x: (x["file"], x["decl_line"])):
            print("  %s:%d %s:%s" % (h["file"], h["decl_line"], h["name"], h["type"]))

    if args.json:
        json.dump(dict(fields=fields, locals=locals_), open(args.json, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=1)

    if args.check and fields:
        print("\n[struct-defaults] FAIL: 仍有 %d 个未初始化的 struct 类字段" % len(fields))
        for h in fields:
            print("  %s:%d %s:%s" % (h["file"], h["decl_line"], h["name"], h["type"]))
        return 1
    if args.check:
        print("\n[struct-defaults] OK: 未发现未初始化的 struct 类字段")
    return 0


if __name__ == "__main__":
    sys.exit(main())
