#!/usr/bin/env bash
# UI 点击链路的运行期验证：编译并运行 verify/clickchain 的探针。
#
#   bash HaxePort/tools_build/check_click_chain.sh          # 默认 cpp（与游戏同目标，**必须**）
#   bash HaxePort/tools_build/check_click_chain.sh --neko   # 仅作参考；本探针类型到 mvz2.localization，
#                                                          # neko 代码生成期会报 Field hashing conflict
#
# 运行期 cwd 用 HaxePort/（unity.Application.dataPath = "assets"，与游戏一致）。
# 输出目录默认是系统临时目录，不会污染仓库。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_CLICK_SMOKE_OUT:-${TMPDIR:-/tmp}/mvz2_click_smoke}"
TARGET="${1:---cpp}"

cd "$PORT_DIR" || exit 1
mkdir -p "$OUT_DIR"

HAXE_FLAGS=(
  -cp source -cp verify
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl
  -lib hscript -lib hxjsonast -lib json2object
  -main clickchain.ClickChainSmokeMain
  -D lime_use_old_deltatime
  --macro "flixel.system.macros.FlxDefines.run()"
)

if [ "$TARGET" = "--neko" ]; then
  haxe "${HAXE_FLAGS[@]}" -neko "$OUT_DIR/ClickChainSmoke.n" || exit 1
  neko "$OUT_DIR/ClickChainSmoke.n"
else
  haxe "${HAXE_FLAGS[@]}" -lib hxcpp -cpp "$OUT_DIR/cpp" || exit 1
  EXE="$(ls "$OUT_DIR/cpp/"*.exe 2>/dev/null | head -1)"
  if [ -z "$EXE" ]; then
    echo "找不到生成的 exe（$OUT_DIR/cpp）" >&2
    exit 1
  fi
  cp -f "$PORT_DIR/export/windows/bin/lime.ndll" "$OUT_DIR/cpp/" 2>/dev/null || true
  "$EXE"
fi
