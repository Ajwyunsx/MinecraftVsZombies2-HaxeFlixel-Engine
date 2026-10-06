#!/usr/bin/env bash
# 工作包 F 的运行时验证：编译并运行十六进制颜色解析 / ParseHelper 严格解析冒烟测试。
#
#   bash HaxePort/tools_build/check_color.sh              # 默认 neko（快）：①②③
#   bash HaxePort/tools_build/check_color.sh --cpp        # 与游戏同一目标：①②③④（含真实 Meta XML 的颜色属性链路）
#   bash HaxePort/tools_build/check_color.sh --cpp --unit  # cpp 只跑 ①②③（不编译 XMLHelper 依赖图，快速回归）
#
# 输出目录默认是系统临时目录（$TMPDIR/mvz2_color_smoke），不会污染仓库。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_COLOR_SMOKE_OUT:-${TMPDIR:-/tmp}/mvz2_color_smoke}"
TARGET="${1:---neko}"
RUN_DIR="$PORT_DIR/export/windows/bin"

cd "$PORT_DIR" || exit 1
mkdir -p "$OUT_DIR"

HAXE_FLAGS=(
  -cp source -cp tools_build/verify_color
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl
  -lib hscript -lib hxjsonast -lib json2object
  -main colorsmoke.ColorParseSmoke
  -D lime_use_old_deltatime
  --macro "flixel.system.macros.FlxDefines.run()"
)

if [ "$TARGET" = "--neko" ]; then
  haxe "${HAXE_FLAGS[@]}" -neko "$OUT_DIR/ColorParseSmoke.n" || exit 1
  cd "$PORT_DIR" || exit 1
  neko "$OUT_DIR/ColorParseSmoke.n"
else
  # PORT-NOTE: 本冒烟程序只依赖 source/ 里的颜色与 XML 解析链，不需要 cpp 覆盖层
  # （该目录由其它工作包临时维护，可能处于半成品状态而遮蔽 source/）。
  # 需要时可用 MVZ2_CPP_OVERLAY=/path/to/overlay 显式启用。
  OVERLAY="${MVZ2_CPP_OVERLAY:-}"
  if [ -n "$OVERLAY" ] && [ -d "$OVERLAY" ]; then
    HAXE_FLAGS+=(-cp "$OVERLAY")
    echo "使用 cpp 覆盖层：$OVERLAY"
  fi
  # --unit 只跑 ①②③（颜色/解析的单元断言），不编译 XMLHelper 依赖图，用于快速回归。
  for extra in "${@:2}"; do
    if [ "$extra" = "--unit" ]; then
      HAXE_FLAGS+=(-D color_smoke_unit_only)
      echo "仅单元段（跳过真实 XML 段）"
    fi
  done
  haxe "${HAXE_FLAGS[@]}" -cpp "$OUT_DIR/cpp" || exit 1
  EXE="$(ls "$OUT_DIR/cpp/"*.exe 2>/dev/null | head -1)"
  if [ -z "$EXE" ]; then
    echo "找不到生成的 exe（$OUT_DIR/cpp）" >&2
    exit 1
  fi
  cp -f "$RUN_DIR/lime.ndll" "$OUT_DIR/cpp/" 2>/dev/null || true
  cd "$PORT_DIR" || exit 1        # 真实数据段按相对路径找 assets/
  "$EXE"
fi
