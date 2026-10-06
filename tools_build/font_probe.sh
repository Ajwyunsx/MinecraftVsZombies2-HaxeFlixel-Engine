#!/usr/bin/env bash
# 字体工作包：启动隔离工程的 MVZ2.exe -> 定时截屏 -> 杀进程 -> 打印 boot-trace 关键行。
# 用法： bash font_probe.sh <输出前缀> [运行秒数]
set -u
here="$(cd "$(dirname "$0")" && pwd)"
bin="$here/verify_shot/export/windows/bin"
prefix="${1:-font}"
seconds="${2:-25}"

taskkill //F //IM MVZ2.exe >/dev/null 2>&1
rm -f "$bin/boot-trace.log"
cd "$bin" || exit 1
(./MVZ2.exe >/dev/null 2>&1 &)

sleep "$seconds"
powershell -NoProfile -ExecutionPolicy Bypass -File "$here/grab_shot.ps1" -Out "$here/shots/${prefix}.png" 2>&1 | tail -1
taskkill //F //IM MVZ2.exe >/dev/null 2>&1
echo "=== boot-trace 关键行 ==="
grep -n "渲染统计\|Image 诊断\|文本\|Font\|font\|字体" "$bin/boot-trace.log" | tail -12
echo "=== error 计数 ==="
grep -c "\[error\]" "$bin/boot-trace.log"
