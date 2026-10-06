#!/usr/bin/env python3
"""扫描 Haxe 移植端把文本解析交给 Std.parseInt / Std.parseFloat 的地方，逐条对照 C# 原码判断语义是否等价。

背景（工作包 F）：`source/unity/ColorUtility.hx` 用 `Std.parseInt("FF")` 解析十六进制对 ——
Haxe 的 `Std.parseInt` 对裸十六进制返回 null（"FF"→null）、对部分十六进制静默截断（"7F"→7），
导致所有 `#RRGGBB(AA)` 颜色解析失败（cpp 全量 Meta 加载日志里 106 条
`Cannot create property "mvz2:..." of type "color"`）。

同类风险有三类：
  A. 十六进制 / 带前缀：C# 用 `NumberStyles.HexNumber` / `Convert.ToInt32(s, 16)` / 手写 hex 解析，
     移植端若换成 Std.parseInt 就会全错（ColorUtility 即此类）。判据：`parseInt` 同一行出现
     `substr` / `charAt` / `"0x"`。
  B. 严格失败语义：C# 用 `int.TryParse` / `float.TryParse` / `double.TryParse`（数据里出现坏值必须
     返回 false），Std.parseInt/parseFloat 会接受 `"12abc"`、`"0x10"`、`"1.5x"`、溢出回绕。
  C. 抛异常的 Parse：C# `int.Parse` / `float.Parse` / `double.Parse`（失败抛异常），Haxe 静默给
     null/NaN/0，二者都无法在 Haxe 里 1:1 表达（列入报告，不自动改）。

算法：
  1. 收集 `HaxePort/source/**/*.hx` 里所有 `Std.parseInt` / `Std.parseFloat` / `ParseHelper.*` 站点。
  2. 每个站点按同类 A/B/C 分类；再用「同文件名（去分部后缀）的 C# 原文件」找出 C# 侧用到的解析
     API 作为对照证据（`Assets/Scripts/**/<stem>.cs`）。
  3. 数据侧回归：扫 `HaxePort/assets/GameContent/**/*.xml` 的属性值，列出「宽松解析接受、.NET 拒绝」
     的候选（`0x…`、`12abc`、`1.5f`、`1,5` …），确认收敛到严格语义后没有真实数据被拒。
  4. 附带清单：C# 侧全部解析 API 的使用计数，以及 Haxe 侧是否有对应实现文件（人工核对用）。

用法： python HaxePort/tools_build/scan_parse_shims.py [--json out.json]
环境变量 HX_ROOT 可覆盖 Haxe 源码根目录（用于对旧版本/修复前的副本自检）。
"""
import json
import os
import re
import sys
from collections import defaultdict, Counter

try:  # Windows 控制台默认 GBK，中文报告会乱码
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CS_ROOT = os.path.join(ROOT, "Assets", "Scripts")
HX_ROOT = os.environ.get("HX_ROOT") or os.path.join(ROOT, "HaxePort", "source")
ASSET_XML_ROOTS = [
    os.path.join(ROOT, "HaxePort", "assets", "GameContent"),
    os.path.join(ROOT, "Assets", "GameContent"),
]

CS_PARSE_APIS = [
    ("NumberStyles.HexNumber", r"NumberStyles\.HexNumber"),
    ("Convert.ToInt32(...,16)", r"Convert\.ToInt32\s*\([^)]*,\s*16\s*\)"),
    ("Convert.ToSingle/Double/Int32", r"Convert\.To(?:Single|Double|Int32|Int64)\s*\("),
    ("int.Parse", r"\bint\.Parse\s*\("),
    ("long.Parse", r"\blong\.Parse\s*\("),
    ("float.Parse", r"\bfloat\.Parse\s*\("),
    ("double.Parse", r"\bdouble\.Parse\s*\("),
    ("int.TryParse", r"\bint\.TryParse\s*\("),
    ("long.TryParse", r"\blong\.TryParse\s*\("),
    ("float.TryParse", r"\bfloat\.TryParse\s*\("),
    ("double.TryParse", r"\bdouble\.TryParse\s*\("),
    ("Enum.Parse/TryParse", r"\bEnum\.(?:Parse|TryParse)\s*\("),
    ("ColorUtility.TryParseHtmlString", r"ColorUtility\.TryParseHtmlString\s*\("),
]

HX_HIT_RE = re.compile(
    r"(?P<callee>Std\.parse(?:Int|Float)|ParseHelper\.(?:ParseInt|ParseFloat|TryParseInt|TryParseLong|TryParseFloat|TryParseDouble))\s*\("
)
# C# 侧「失败即抛异常」的解析 API（Haxe 侧只能退化成 null/NaN/0）。
THROWING_APIS = {
    "int.Parse", "long.Parse", "float.Parse", "double.Parse",
    "Enum.Parse/TryParse", "Convert.ToSingle/Double/Int32",
}
# C# 侧「失败返回 false」的解析 API（必须收敛到 ParseHelper.TryParse* 的严格语义）。
TRYING_APIS = {
    "int.TryParse", "long.TryParse", "float.TryParse", "double.TryParse",
    "Enum.Parse/TryParse", "ColorUtility.TryParseHtmlString",
}
NUMERIC_ATTR_RE = re.compile(r'([A-Za-z_][\w:.-]*)\s*=\s*"([^"]*)"')
# 会被 XMLHelper.GetAttributeInt/Float/… / ColorUtility 解析的属性值：
#   数值类型节点上的数值属性 + gradient 的 <key hex=… time=… alpha=…>。
NUMERIC_TAG_RE = re.compile(
    r"<(int|integer|float|double|long|vector2|vector3|vector2int|vector3int|color|key)\b[^>]*>", re.I)
NUMERIC_KEYS = {"value", "x", "y", "z", "time", "alpha", "weight"}
# Unity ColorUtility.TryParseHtmlString 接受的十六进制写法：'#' + 3/4/6/8 位十六进制数字。
STRICT_HEX_RE = re.compile(r"^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")
STRICT_INT_RE = re.compile(r"^[+-]?\d+$")
STRICT_FLOAT_RE = re.compile(r"^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$")


def cs_index():
    """stem -> [(path, [parse api names])]"""
    idx = defaultdict(list)
    if not os.path.isdir(CS_ROOT):
        return idx
    for dirpath, _dn, files in os.walk(CS_ROOT):
        for fn in files:
            if not fn.endswith(".cs"):
                continue
            path = os.path.join(dirpath, fn)
            with open(path, encoding="utf-8-sig", errors="replace") as fh:
                src = fh.read()
            apis = [name for name, rx in CS_PARSE_APIS if re.search(rx, src)]
            if apis:
                idx[os.path.splitext(fn)[0]].append((
                    os.path.relpath(path, ROOT).replace("\\", "/"), apis))
    return idx


def strip_comments(src):
    """把注释替换成空白（保留行号与字符串字面量），避免把注释里的示例代码当成真实调用点。"""
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                out.append(" ")
                i += 1
        elif c == "/" and i + 1 < n and src[i + 1] == "*":
            while i < n and not (src[i] == "*" and i + 1 < n and src[i + 1] == "/"):
                out.append("\n" if src[i] == "\n" else " ")
                i += 1
            out.append("  ")
            i += 2
        elif c in "\"'":
            quote = c
            out.append(c)
            i += 1
            while i < n:
                if src[i] == "\\" and i + 1 < n:
                    out.append(src[i:i + 2])
                    i += 2
                    continue
                out.append(src[i])
                if src[i] == quote:
                    i += 1
                    break
                i += 1
        else:
            out.append(c)
            i += 1
    return "".join(out)


FUNC_RE = re.compile(r"\bfunction\s+([A-Za-z_]\w*)\s*\(")


def classify(text, arg, enclosing, cs_apis):
    """把 Haxe 站点分类。

    STRICT-IMPL       : ParseHelper 内部严格解析实现本身
    STRICT-NOW        : 经 ParseHelper.TryParse*（已对齐 .NET TryParse 的严格语义）
    STRICT-MISSING    : 直接 Std.parseInt/parseFloat，但 C# 原文件用的是 TryParse → 需要人工核对
    HEX-RISK          : 十六进制解析（parseInt + substr/charAt 或 "0x" 字面量）
    THROW-DIVERGENCE  : C# 用会抛异常的 Parse/Convert，Haxe 侧只能返回 null/NaN/0
    ROUNDTRIP         : 数值 → 字符串 → 数值往返，不是文本解析
    OK                : 其余（受控十进制文本）
    """
    if enclosing and enclosing in ("ParseInt", "ParseFloat"):
        return "THROW-DIVERGENCE", "对应 C# int.Parse/float.Parse 的包装（失败抛异常），Haxe 返回 null/NaN"
    if enclosing and (enclosing.startswith("tryParse") or enclosing.startswith("compareNumeric")):
        return "STRICT-IMPL", "ParseHelper 的严格解析实现（.NET NumberStyles 语义）"
    if "ParseHelper.TryParse" in text:
        return "STRICT-NOW", "经 ParseHelper 严格解析（对齐 .NET TryParse）"
    if "ParseHelper.Parse" in text:
        return "THROW-DIVERGENCE", "C# int.Parse/float.Parse 失败抛异常；Haxe 返回 null/NaN"
    if re.search(r"parseInt\s*\([^)]*(?:substr|charAt|slice)", text) or '"0x"' in text or '"0X"' in text:
        return "HEX-RISK", "十六进制解析：Std.parseInt 对裸十六进制返回 null / 静默截断"
    if re.match(r"^\s*Std\.string\s*\(", arg or ""):
        return "ROUNDTRIP", "数值 → 字符串 → 数值往返，非文本解析"
    if set(cs_apis) & THROWING_APIS:
        return "THROW-DIVERGENCE", "C# 侧为 Parse/Convert（失败抛异常），Std.* 静默返回 null/NaN/0"
    if set(cs_apis) & TRYING_APIS:
        return "STRICT-MISSING", "C# 侧为 TryParse（严格失败语义），此处直接用了 Std.parseInt/parseFloat"
    return "OK", "其余受控十进制文本解析"


def scan_haxe(cs):
    hits = []
    for dirpath, _dn, files in os.walk(HX_ROOT):
        for fn in files:
            if not fn.endswith(".hx"):
                continue
            path = os.path.join(dirpath, fn)
            rel = os.path.relpath(path, ROOT).replace("\\", "/")
            stem = os.path.splitext(fn)[0]
            with open(path, encoding="utf-8-sig", errors="replace") as fh:
                lines = strip_comments(fh.read()).splitlines()
            for ln, text in enumerate(lines, 1):
                enclosing = None
                for k in range(ln - 1, -1, -1):
                    fm = FUNC_RE.search(lines[k])
                    if fm:
                        enclosing = fm.group(1)
                        break
                for m in HX_HIT_RE.finditer(text):
                    # 取被解析的实参（同一行内配平括号）
                    arg = None
                    depth = 0
                    start = m.end()
                    for k in range(start, len(text)):
                        ch = text[k]
                        if ch == "(":
                            depth += 1
                        elif ch == ")":
                            if depth == 0:
                                arg = text[start:k]
                                break
                            depth -= 1
                    cs_apis = [api for _p, apis in cs.get(stem.split("_")[0], []) for api in apis]
                    rule, why = classify(text, arg, enclosing, cs_apis)
                    hits.append({
                        "rule": rule, "reason": why,
                        "hx": "%s:%d" % (rel, ln),
                        "callee": m.group("callee"),
                        "arg": (arg or "").strip(),
                        "line": text.strip(),
                        "stem": stem.split("_")[0],
                    })
    return hits


def scan_assets():
    """宽松解析接受、.NET 严格解析拒绝的属性值候选（只看真正走数字解析的属性）。"""
    offenders = []
    seen = set()
    total_attrs = 0
    for root in ASSET_XML_ROOTS:
        if not os.path.isdir(root):
            continue
        for dirpath, _dn, files in os.walk(root):
            for fn in files:
                if not fn.endswith(".xml"):
                    continue
                path = os.path.join(dirpath, fn)
                with open(path, encoding="utf-8-sig", errors="replace") as fh:
                    src = fh.read()
                for tag in NUMERIC_TAG_RE.finditer(src):
                    tag_name = tag.group(1).lower()
                    for m in NUMERIC_ATTR_RE.finditer(tag.group(0)):
                        key, value = m.group(1), m.group(2)
                        if key == "hex" or (key == "value" and tag_name == "color"):
                            kind = "hex"
                        elif key in NUMERIC_KEYS and tag_name != "color":
                            kind = "number"
                        else:
                            continue
                        total_attrs += 1
                        if kind == "hex" and STRICT_HEX_RE.match(value):
                            continue
                        if kind == "number" and (STRICT_INT_RE.match(value) or STRICT_FLOAT_RE.match(value)):
                            continue
                        k = (key, value)
                        if k in seen:
                            continue
                        seen.add(k)
                        offenders.append({
                            "file": os.path.relpath(path, ROOT).replace("\\", "/"),
                            "attr": key, "value": value,
                        })
    return total_attrs, offenders


def main():
    cs = cs_index()
    hits = scan_haxe(cs)
    by_rule = Counter(h["rule"] for h in hits)

    print("== Haxe 解析站点：合计 %d ==" % len(hits))
    for rule in sorted(by_rule):
        print("  %-16s %d" % (rule, by_rule[rule]))

    print("\n== 逐条（含 C# 原码对照）==")
    for h in sorted(hits, key=lambda x: (x["rule"], x["hx"])):
        cands = cs.get(h["stem"]) or []
        if not cands:
            base = h["stem"].split(".")[0]
            cands = [v for k, v in cs.items() if k.split("_")[0] == base for v in v]
        cs_desc = "; ".join("%s [%s]" % (p, ",".join(a)) for p, a in cands[:2]) or "-"
        print("  [%s] %s  %s(%s)" % (h["rule"], h["hx"], h["callee"], h["arg"] or ""))
        print("        C# 侧解析 API：%s" % cs_desc)
        print("        %s" % h["reason"])

    print("\n== 数据侧回归（HaxePort/assets/GameContent + Assets/GameContent 的 XML 属性）==")
    total_attrs, offenders = scan_assets()
    print("  扫描属性 %d 个；宽松接受但 .NET 拒绝的候选 %d 个" % (total_attrs, len(offenders)))
    for o in offenders[:40]:
        print("    %s  %s=\"%s\"" % (o["file"], o["attr"], o["value"]))
    if len(offenders) > 40:
        print("    …（其余 %d 条见 --json 输出）" % (len(offenders) - 40))

    print("\n== C# 解析 API 使用计数（移植覆盖核对）==")
    api_counts = Counter()
    api_files = defaultdict(set)
    for dirpath, _dn, files in os.walk(CS_ROOT):
        for fn in files:
            if not fn.endswith(".cs"):
                continue
            path = os.path.join(dirpath, fn)
            with open(path, encoding="utf-8-sig", errors="replace") as fh:
                src = fh.read()
            for name, rx in CS_PARSE_APIS:
                n = len(re.findall(rx, src))
                if n:
                    api_counts[name] += n
                    api_files[name].add(os.path.splitext(fn)[0])
    for name, n in api_counts.most_common():
        print("  %-32s %4d 次（%d 个文件）" % (name, n, len(api_files[name])))

    out = None
    if "--json" in sys.argv:
        out = sys.argv[sys.argv.index("--json") + 1]
        with open(out, "w", encoding="utf-8") as fh:
            json.dump({
                "haxe_sites": hits,
                "rules": dict(by_rule),
                "asset_attrs_scanned": total_attrs,
                "asset_offenders": offenders,
                "cs_api_counts": dict(api_counts),
            }, fh, ensure_ascii=False, indent=1)
        print("\nsaved -> %s" % out)

    # 十六进制风险站点未消除时以非零退出，便于 CI 复验。
    if by_rule.get("HEX-RISK"):
        sys.exit(1)


if __name__ == "__main__":
    main()
