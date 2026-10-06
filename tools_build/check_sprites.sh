#!/usr/bin/env bash
# 精灵/贴图纸张接线到 Flixel 的运行期验证（本工作包）。
# 真实读取 HaxePort/assets/sprites_manifest.json + resource_manifest.json，真实解码 PNG，
# 把 unity.Sprite 转成 FlxFrame / FlxImageFrame / FlxAtlasFrames 并断言帧矩形与像素。
#
#   bash HaxePort/tools_build/check_sprites.sh                 # 默认 cpp（与游戏同一目标），逐项断言
#   bash HaxePort/tools_build/check_sprites.sh --neko          # neko（快）
#   bash HaxePort/tools_build/check_sprites.sh --all           # 全量取帧（709 精灵 + 222 图集），只统计
#   bash HaxePort/tools_build/check_sprites.sh --all --neko
#
# 运行期 cwd 用 HaxePort/（unity.Application.dataPath = "assets"，与游戏一致）。
# 输出目录默认在系统临时目录（$TMPDIR/mvz2_sprite_smoke），不污染仓库。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_SPRITE_SMOKE_OUT:-${TMPDIR:-/tmp}/mvz2_sprite_smoke}"
TARGET="--cpp"
MAIN="sprites.SpriteFrameSmokeMain"
EXE_NAME="SpriteFrameSmokeMain"

for arg in "$@"; do
  case "$arg" in
    --neko) TARGET="--neko" ;;
    --cpp)  TARGET="--cpp" ;;
    --all)  MAIN="sprites.AllSheetsSmoke"; EXE_NAME="AllSheetsSmoke" ;;
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
