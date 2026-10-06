#!/usr/bin/env bash
# 隔离工程的「运行 + 定时截屏 + 像素统计」一键复验。
# 用法： bash run_shot.sh <工程目录> <输出前缀> [运行秒数] [截屏次数]
# 例：   bash run_shot.sh tools_build/verify_shot after 30 4
set -u
proj="$1"
prefix="$2"
seconds="${3:-30}"
shots="${4:-4}"

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
bin="$root/$proj/export/windows/bin"
exe="$bin/MVZ2.exe"
shotsDir="$here/shots"

if [ ! -f "$exe" ]; then
	echo "ERROR: $exe 不存在"
	exit 1
fi

taskkill //F //IM MVZ2.exe >/dev/null 2>&1
rm -f "$bin/boot-trace.log"

echo "=== 启动 $exe（运行 ${seconds}s，截屏 ${shots} 次）==="
started=$(date +%s)
(
	cd "$bin" && ./MVZ2.exe >/dev/null 2>&1
) &
pid=$!

interval=$(( seconds / (shots + 1) ))
if [ "$interval" -lt 2 ]; then interval=2; fi

for i in $(seq 1 "$shots"); do
	sleep "$interval"
	if ! kill -0 "$pid" 2>/dev/null; then
		echo "--- 进程已退出，停止截屏 ---"
		break
	fi
	out="$shotsDir/${prefix}_t$((i * interval))s.png"
	powershell -NoProfile -ExecutionPolicy Bypass -File "$here/grab_shot.ps1" -Out "$out" 2>&1 | tail -1
done

if kill -0 "$pid" 2>/dev/null; then
	remaining=$(( seconds - interval * shots ))
	if [ "$remaining" -gt 0 ]; then sleep "$remaining"; fi
fi

if kill -0 "$pid" 2>/dev/null; then
	echo "=== 进程仍在运行（未崩溃），结束它 ==="
	taskkill //F //IM MVZ2.exe >/dev/null 2>&1
	state="仍在运行"
else
	wait "$pid" 2>/dev/null
	state="已退出，exit code=$?"
fi
echo "=== MVZ2.exe $state（运行约 $(( $(date +%s) - started ))s）==="

echo "=== boot-trace.log 末 20 行 ==="
tail -n 20 "$bin/boot-trace.log" 2>/dev/null || echo "(无 boot-trace.log)"
