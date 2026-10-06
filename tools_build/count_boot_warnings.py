#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""boot-trace.log 告警计数（工作包：集成验证）。

用途
----
判断「属性注册表宏是否生效」的核心指标是启动日志里这几类告警的数量变化。
本脚本把 boot-trace.log（或任意日志）里的告警分门别类数出来，并与基线对比。

用法（在 HaxePort/ 下执行）
--------------------------
    python tools_build/count_boot_warnings.py                       # 默认读 export/windows/bin/boot-trace.log
    python tools_build/count_boot_warnings.py <log> [<log2> ...]    # 读指定日志（可多个，逐个对比）
    python tools_build/count_boot_warnings.py --json <log>          # 只输出 JSON

基线（2026-10-02，属性注册表缺失时）：
    Trying to set a property with an invalid key!   16331
    Property with name ... is not registered.        8563
    Cannot find entity behaviour with ID mvz2:*      1986
    Cannot create property ... of type "color"          0（已修）
"""

import argparse
import json
import os
import re
import sys

# (键, 显示名, 匹配正则, 基线计数)  —— 基线为 None 表示「修好前不存在 / 无基线」
PATTERNS = [
    ("invalid_key", "Trying to set a property with an invalid key!",
     re.compile(r"Trying to set a property with an invalid key!"), 16331),
    ("unregistered_property", "Property with name ... is not registered.",
     re.compile(r"Property with name .* is not registered\."), 8563),
    ("entity_behaviour_missing", "Cannot find entity behaviour with ID mvz2:*",
     re.compile(r"Cannot find entity behaviour with ID mvz2:"), 1986),
    ("map_element_behaviour_missing", "Cannot find map element behaviour with ID mvz2:*",
     re.compile(r"Cannot find map element behaviour with ID mvz2:"), None),
    ("color_property", "Cannot create property ... of type \"color\"",
     re.compile(r'Cannot create property .* of type "color"'), 0),
    ("serialize_invalid_key", "Trying to serialize a property with key ... not registered.",
     re.compile(r"Trying to serialize a property with key .* which is not registered\."), None),
    ("registry_meta_unavailable", "Property registry metadata ... is not available at runtime",
     re.compile(r"Property registry metadata .* is not available at runtime"), None),
    ("duplicate_property", "Duplicate property meta",
     re.compile(r"Duplicate property meta"), None),
    ("probe", "PROBE ...（覆盖层插桩，非 source/ 产物）",
     re.compile(r"PROBE"), None),
]


def count_file(path):
    with open(path, encoding="utf-8", errors="replace") as f:
        text = f.read()
    counts = {}
    for key, _label, rx, _base in PATTERNS:
        counts[key] = len(rx.findall(text))
    return {
        "path": os.path.abspath(path),
        "bytes": os.path.getsize(path),
        "lines": text.count("\n") + (0 if text.endswith("\n") or not text else 1),
        "counts": counts,
    }


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    ap = argparse.ArgumentParser()
    ap.add_argument("logs", nargs="*", default=None,
                    help="日志路径；默认 export/windows/bin/boot-trace.log")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    here = os.path.dirname(os.path.abspath(__file__))
    root = os.path.dirname(here)
    logs = args.logs or [os.path.join(root, "export", "windows", "bin", "boot-trace.log")]

    results = []
    for path in logs:
        if not os.path.exists(path):
            print("!! 找不到日志: %s" % path, file=sys.stderr)
            continue
        results.append(count_file(path))

    if args.json:
        print(json.dumps(results, ensure_ascii=False, indent=2))
        return 0

    for r in results:
        print("== %s" % r["path"])
        print("   %d B / %d 行" % (r["bytes"], r["lines"]))
        print("   %-42s %10s %10s %s" % ("告警", "本轮", "基线", "变化"))
        for key, label, _rx, base in PATTERNS:
            cur = r["counts"][key]
            if base is None:
                delta = "-"
            elif cur == base:
                delta = "持平"
            elif cur < base:
                delta = "-%d" % (base - cur)
            else:
                delta = "+%d" % (cur - base)
            print("   %-42s %10d %10s %s" % (label[:42], cur, "-" if base is None else base, delta))
        print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
