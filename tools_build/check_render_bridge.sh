#!/usr/bin/env bash
# 渲染桥（unity → Flixel）的运行期验证（本工作包）。
# 不依赖游戏资源：纯逻辑断言排序层表、相机屏幕↔世界换算的 Y 轴方向与往返一致性、
# backgroundColor → FlxG.cameras.bgColor、RenderBridge 的 transform 同步、destroy 摘除子树。
#
#   bash HaxePort/tools_build/check_render_bridge.sh           # 默认 cpp（与游戏同一目标）
#   bash HaxePort/tools_build/check_render_bridge.sh --neko    # neko（快）
#
# 运行期 cwd 用 HaxePort/（unity.Application.dataPath = "assets"，与游戏一致）。
# 输出目录默认在系统临时目录，不污染仓库。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_RENDER_BRIDGE_OUT:-${TMPDIR:-/tmp}/mvz2_render_bridge}"
TARGET="--cpp"
MAIN="renderbridge.RenderBridgeSmokeMain"
EXE_NAME="RenderBridgeSmokeMain"

for arg in "$@"; do
  case "$arg" in
    --neko) TARGET="--neko" ;;
    --cpp)  TARGET="--cpp" ;;
    *) echo "未知参数：$arg" >&2; exit 2 ;;
  esac
done

cd "$PORT_DIR" || exit 1
mkdir -p "$OUT_DIR"

HAXE_FLAGS=(
  -cp source -cp verify
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl
  -lib hscript -lib hxjsonast -lib json2object
  -main "$MAIN"
  -D lime_use_old_deltatime
  --macro "flixel.system.macros.FlxDefines.run()"
)

if [ "$TARGET" = "--neko" ]; then
  haxe "${HAXE_FLAGS[@]}" -neko "$OUT_DIR/$EXE_NAME.n" || exit 1
  neko "$OUT_DIR/$EXE_NAME.n"
else
  haxe "${HAXE_FLAGS[@]}" -lib hxcpp -cpp "$OUT_DIR/cpp" || exit 1
  EXE="$(ls "$OUT_DIR/cpp/$EXE_NAME"*.exe 2>/dev/null | head -1)"
  if [ -z "$EXE" ]; then
    echo "找不到生成的 exe（$OUT_DIR/cpp）" >&2
    exit 1
  fi
  cp -f "$PORT_DIR/export/windows/bin/lime.ndll" "$OUT_DIR/cpp/" 2>/dev/null || true
  "$EXE"
fi
