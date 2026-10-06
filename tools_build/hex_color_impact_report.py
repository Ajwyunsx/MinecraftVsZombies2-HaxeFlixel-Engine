#!/usr/bin/env python3
"""量化「Std.parseInt 解析十六进制对」这个 bug 对真实素材的影响（工作包 F）。

`source/unity/ColorUtility.hx` 修复前用 `Std.parseInt(pair)` 解析 `#RRGGBB` 的两位十六进制对，
而 Haxe 的 `Std.parseInt` 不认裸十六进制（"FF" → null 使整个颜色解析失败；"7F" → 7 使颜色静默取错值）。
本脚本把「修复前算法」与「Unity/修复后算法」在 GameContent 里所有颜色字面量上对拍，
输出正确 / 静默取错值 / 直接失败三类计数与例子，用于报告与回归复核。

用法： python HaxePort/tools_build/hex_color_impact_report.py [--limit N]
"""
import argparse
import glob
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
XML_DIRS = [
    os.path.join(ROOT, "HaxePort", "assets", "GameContent"),
    os.path.join(ROOT, "Assets", "GameContent"),
]

COLOR_RE = re.compile(r'<color [^>]*value="(#[0-9a-fA-F]+)"')
KEY_RE = re.compile(r'<key [^>]*hex="(#[0-9a-fA-F]+)"')


def haxe_parse_int(s):
    """Haxe 4.3 Std.parseInt 的语义：可选符号、0x 前缀、遇非法字符停止（尾随垃圾忽略）。"""
    if not s:
        return None
    i = 0
    negative = False
    if s[0] in "+-":
        negative = s[0] == "-"
        i = 1
    rest = s[i:]
    if rest[:2].lower() == "0x":
        body, base = rest[2:], 16
    else:
        body, base = rest, 10
    digits = ""
    for c in body:
        if base == 16 and c in "0123456789abcdefABCDEF":
            digits += c
        elif base == 10 and c.isdigit():
            digits += c
        else:
            break
    if not digits:
        return None
    return (-1 if negative else 1) * int(digits, base)


def old_parse(v):
    """修复前的 ColorUtility.TryParseHtmlString（6/8 位分支；3 位分支行为见代码注释）。"""
    s = v[1:] if v.startswith("#") else v
    if len(s) in (6, 8):
        parts = [haxe_parse_int(s[j:j + 2]) for j in (0, 2, 4)]
        if any(p is None for p in parts):
            return None
        a = haxe_parse_int(s[6:8]) if len(s) == 8 else 255
        if a is None:
            return None
        return tuple(p / 255 for p in parts) + (a / 255,)
    if len(s) == 3:
        parts = [haxe_parse_int(s[i] + s[i]) for i in range(3)]
        if any(p is None for p in parts):
            return None
        return tuple(p / 255 for p in parts) + (1.0,)
    return None


def new_parse(v):
    """修复后（Unity 语义）：#RGB/#RGBA/#RRGGBB/#RRGGBBAA，缺省 alpha=FF。"""
    s = v
    if len(s) in (4, 5):  # #RGB / #RGBA → 展开
        s = "#" + "".join(c * 2 for c in s[1:])
    if len(s) not in (7, 9):
        return None
    try:
        rgb = [int(s[1 + j:3 + j], 16) for j in (0, 2, 4)]
        a = int(s[7:9], 16) if len(s) == 9 else 255
    except ValueError:
        return None
    return tuple(x / 255 for x in rgb) + (a / 255,)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=8, help="每类打印的例子数")
    args = ap.parse_args()

    literals = set()
    for d in XML_DIRS:
        for f in glob.glob(os.path.join(d, "**", "*.xml"), recursive=True):
            with open(f, encoding="utf-8", errors="replace") as fh:
                text = fh.read()
            literals.update(COLOR_RE.findall(text))
            literals.update(KEY_RE.findall(text))

    ok, wrong, failed = [], [], []
    for v in sorted(literals):
        expected = new_parse(v)
        if expected is None:
            print("[warn] 素材里出现新实现也不认识的写法：%s" % v)
            continue
        got = old_parse(v)
        if got is None:
            failed.append(v)
        elif max(abs(a - b) for a, b in zip(got, expected)) > 1e-9:
            wrong.append((v, got, expected))
        else:
            ok.append(v)

    total = len(ok) + len(wrong) + len(failed)
    print("颜色字面量（<color value=> + gradient <key hex=>）共 %d 个不同写法" % total)
    print("  修复前解析正确         ：%d %s" % (len(ok), ok[:args.limit]))
    print("  修复前静默取到错值     ：%d" % len(wrong))
    for v, got, exp in wrong[:args.limit]:
        print("      %s 旧=%s 新=%s" % (v, tuple(round(x, 4) for x in got), tuple(round(x, 4) for x in exp)))
    print("  修复前直接失败（丢属性）：%d %s" % (len(failed), failed[:args.limit]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
