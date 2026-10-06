#!/usr/bin/env bash
# 工作包 ② 的运行期验证：编译并运行关卡/UI prefab 序列化数据管线的自检。
#
#   bash HaxePort/tools_build/check_scene.sh            # 默认 cpp（与游戏同目标）
#   bash HaxePort/tools_build/check_scene.sh --neko     # neko（快，但 mvz2 的 UI/Manager 层
#                                                      # 在 neko 生成期会报字段哈希冲突，见 PORTING.md）
#
# 运行期 cwd 用 HaxePort/（unity.Application.dataPath = "assets"，与游戏一致）。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_SCENE_SMOKE_OUT:-${TMPDIR:-/tmp}/mvz2_scene_smoke}"
TARGET="${1:---cpp}"

cd "$PORT_DIR" || exit 1
mkdir -p "$OUT_DIR"

HAXE_FLAGS=(
  -cp source -cp verify
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl
  -lib hscript -lib hxjsonast -lib json2object
  -main scenes.ScenePrefabSmokeMain
  -D lime_use_old_deltatime
  --macro "flixel.system.macros.FlxDefines.run()"
)

if [ "$TARGET" = "--neko" ]; then
  haxe "${HAXE_FLAGS[@]}" -neko "$OUT_DIR/SceneSmoke.n" || exit 1
  neko "$OUT_DIR/SceneSmoke.n"
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
