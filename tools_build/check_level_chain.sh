#!/usr/bin/env bash
# 关卡协程链路的运行期验证：编译并运行 unity.BehaviourRegistry / Coroutine 的行为探针。
#
# 钉住两个真实阻断（详见 verify/levelchain/LevelChainSmokeMain.hx 的文件头）：
#   ① AddComponent 建出来的组件（关卡场景树 / 页面 prefab 子树）的协程原先无人驱动；
#   ② `while (!inner.finished) co.waitFrames(1)` 工厂轮询写法永久挂住。
#
#   bash HaxePort/tools_build/check_level_chain.sh          # 默认 cpp（与游戏同目标）
#   bash HaxePort/tools_build/check_level_chain.sh --neko   # neko（快）
#
# **neko 不可用（已实测）**：本探针会类型到 mvz2.level.LevelController → 连带
#   mvz2.localization，neko 代码生成期报 `Field hashing conflict GetLocalizedStringPlural and _id`
#   （PORTING.md §构建与验证 已记录该限制；既有 `check_scene.sh --neko` 同样失败）。
#   因此请用默认的 cpp 目标运行。
#
# 运行期 cwd 用 HaxePort/（unity.Application.dataPath = "assets"，与游戏一致）。
# 输出目录默认在系统临时目录，不污染仓库。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_LEVEL_CHAIN_OUT:-${TMPDIR:-/tmp}/mvz2_level_chain}"
TARGET="--cpp"
MAIN="levelchain.LevelChainSmokeMain"
EXE_NAME="LevelChainSmokeMain"

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
