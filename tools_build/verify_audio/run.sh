#!/usr/bin/env bash
# 运行验证工程的 MVZ2.exe 一段时间后结束，并打印 boot-trace.log 末尾。
# 用法：bash run.sh [运行秒数，默认 40]
set -u
here="$(cd "$(dirname "$0")" && pwd)"
bin="$here/export/windows/bin"
seconds="${1:-40}"

taskkill //F //IM MVZ2.exe >/dev/null 2>&1
rm -f "$bin/boot-trace.log"

cd "$bin"
./MVZ2.exe >/dev/null 2>&1 &
pid=$!
sleep "$seconds"

if kill -0 "$pid" 2>/dev/null; then
	state="仍在运行（未崩溃）"
	taskkill //F //IM MVZ2.exe >/dev/null 2>&1
else
	wait "$pid"
	state="已退出，exit code=$?"
fi
echo "=== MVZ2.exe $state（运行 ${seconds}s）==="
tail -n "${2:-60}" "$bin/boot-trace.log"
