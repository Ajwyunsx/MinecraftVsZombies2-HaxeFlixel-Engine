#!/usr/bin/env bash
# 协程步进器的运行时验证：编译并运行 unity.Coroutine / CoroutineRunner 的行为探针。
#
#   bash HaxePort/tools_build/check_coroutine.sh          # 默认 neko（快，约 10 秒）
#   bash HaxePort/tools_build/check_coroutine.sh --cpp    # 与游戏同一目标（慢）
#
# 输出目录默认是系统临时目录（$TMPDIR/mvz2_coroutine_smoke），不会污染仓库。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_COROUTINE_SMOKE_OUT:-${TMPDIR:-/tmp}/mvz2_coroutine_smoke}"
TARGET="${1:---neko}"

cd "$PORT_DIR" || exit 1
mkdir -p "$OUT_DIR"

HAXE_FLAGS=(
  -cp source -cp verify
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl
  -lib hscript -lib hxjsonast -lib json2object
  -main coroutine.CoroutineSmoke
  -D lime_use_old_deltatime
  --macro "flixel.system.macros.FlxDefines.run()"
)

if [ "$TARGET" = "--neko" ]; then
  haxe "${HAXE_FLAGS[@]}" -neko "$OUT_DIR/CoroutineSmoke.n" || exit 1
  neko "$OUT_DIR/CoroutineSmoke.n"
else
  haxe "${HAXE_FLAGS[@]}" -cpp "$OUT_DIR/cpp" || exit 1
  "$OUT_DIR/cpp/CoroutineSmoke"
fi
