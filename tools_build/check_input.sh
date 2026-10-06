#!/usr/bin/env bash
# 「鼠标/键盘输入」工作包的验证入口（对应 verify/input/InputSmokeTest.hx 的 ①②③④）：
#   ① Unity KeyCode → FlxKey 映射表（86 组按键 + 10 组"Flixel 里无法检测"的键）
#   ② KeyCode 0..359 全域穷举（映射结果必须是 FlxKey 真实跟踪的键或 NONE）
#   ③ 编译期 define 断言（FLX_MOUSE_ADVANCED / FLX_NO_MOUSE_ADVANCED / FLX_KEYBOARD / FLX_MOUSE）
#   ④ 运行期鼠标三键路由 + Unity KeyCode.MouseN 转发（需要真实 FlxGame）
#
#   bash HaxePort/tools_build/check_input.sh --neko         # ①②③，neko 目标（快，约 30 秒）
#   bash HaxePort/tools_build/check_input.sh --cpp          # ①②③，与游戏同目标（hxcpp，约 2 分钟）
#   bash HaxePort/tools_build/check_input.sh --window       # 用 tools_build/verify_input 隔离工程做真实
#                                                           # lime release 构建，①②③④ 全跑（会闪一下窗口）
#   bash HaxePort/tools_build/check_input.sh --window-debug # 同上，-debug 构建（覆盖 FlxKeyManager 在
#                                                           # debug 下 throw 'Invalid key code' 的路径）
#   bash HaxePort/tools_build/check_input.sh --typecheck    # 取 --window 产物里的真实 release define 集，
#                                                           # 对游戏本体（-main Main + 全模块 coverage）跑 cpp 类型检查
#
# 输出目录默认在系统临时目录（$TMPDIR/mvz2_input_smoke），不污染仓库。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_INPUT_SMOKE_OUT:-${TMPDIR:-/tmp}/mvz2_input_smoke}"
WIN_DIR="$HERE/verify_input"
GAME_BIN="$PORT_DIR/export/windows/bin"
MODE="${1:---neko}"

cd "$PORT_DIR" || exit 1
mkdir -p "$OUT_DIR"

LIB_ARGS=(
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl
  -lib hscript -lib hxjsonast -lib json2object
)

run_neko() {
  haxe -cp source -cp verify "${LIB_ARGS[@]}" \
    -main inputsmoke.InputSmokeTest -neko "$OUT_DIR/InputSmokeTest.n" \
    -D lime_use_old_deltatime \
    --macro "flixel.system.macros.FlxDefines.run()" || exit 1
  neko "$OUT_DIR/InputSmokeTest.n"
}

run_cpp() {
  haxe -cp source -cp verify "${LIB_ARGS[@]}" -lib hxcpp \
    -main inputsmoke.InputSmokeTest -cpp "$OUT_DIR/cpp" \
    -D lime_use_old_deltatime \
    --macro "flixel.system.macros.FlxDefines.run()" || exit 1
  local exe
  exe="$(ls "$OUT_DIR/cpp/"*.exe 2>/dev/null | head -1)"
  if [ -z "$exe" ]; then
    echo "找不到生成的 exe（$OUT_DIR/cpp）" >&2
    exit 1
  fi
  cp -f "$GAME_BIN/lime.ndll" "$OUT_DIR/cpp/" 2>/dev/null || true
  "$exe"
}

# --window / --window-debug：在隔离工程里做真实 lime 构建并运行（窗口尺寸 320x240，断言完立即 Sys.exit）
run_window() {
  local extra="${1:-}"
  ( cd "$WIN_DIR" && haxelib run lime build windows $extra ) || exit 1
  local exe="$WIN_DIR/export/windows/bin/InputSmoke.exe"
  if [ ! -f "$exe" ]; then
    echo "找不到产物: $exe" >&2
    exit 1
  fi
  echo "[window] 运行 $exe （会短暂弹出 320x240 窗口）"
  ( cd "$WIN_DIR/export/windows/bin" && ./InputSmoke.exe )
}

# --typecheck：从隔离工程的构建产物里取真实 define 集（obj/Options.txt，由 lime→hxcpp 实际写入），
# 再把「工程自己写的 define」喂给游戏本体的 cpp 类型检查。
# PORT-NOTE: 由 FlxDefines 推导出来的 FLX_* 一律不传（只保留 Project.xml 里手写的那几个 FLX_NO_*），
# 这样 FLX_MOUSE_ADVANCED 必须由 FlxDefines 从"没有 FLX_NO_MOUSE_ADVANCED"推导出来，检查才有意义。
run_typecheck() {
  local options="$WIN_DIR/export/windows/obj/Options.txt"
  if [ ! -f "$options" ]; then
    echo "缺少 $options —— 先跑一次 check_input.sh --window 生成真实 define 集" >&2
    exit 1
  fi

  local defs=()
  local line key val
  # PORT-NOTE: Options.txt 是「最近一次构建」写下的，跑过 --window-debug 之后它是 debug 集的
  # （含 debug=1 / FLX_DEBUG=1、不含 FLX_NO_DEBUG）。这里提示一下，避免拿 debug 集当 release 用。
  if grep -q "^debug=1" "$options"; then
    echo "[typecheck] 提示：$options 来自 -debug 构建；要按 release 集检查请先跑 check_input.sh --window" >&2
  fi
  while IFS= read -r line; do
    line="${line%$'\r'}"
    [ -z "$line" ] && continue
    key="${line%%=*}"
    val="${line#*=}"
    # PORT-NOTE: Options.txt 里有大量由 FlxDefines/lime/hxcpp 自己推导出来的 define
    # （FLX_MOUSE / FLX_KEYBOARD / FLX_GAMEINPUT_API…、target.*、utf16、static…），
    # 手工传会盖掉推导（那就白测了），其中 static/target.* 还是 haxe 的保留 flag 会直接报错。
    # 这里只放行「工程自己写的 define」与「平台 define」，其余一律不传、交给宏推导。
    case "$key" in
      FLX_NO_DEBUG | FLX_NO_TOUCH | FLX_NO_KEYBOARD | FLX_NO_GAMEPAD | FLX_NO_SOUND_TRAY | FLX_NO_FOCUS_LOST_SCREEN) ;;
      MVZ2_LOCALIZATION | MVZ2_DEBUG_CONSOLE | lime_use_old_deltatime) ;;
      desktop | windows | native | openfl_native) ;;
      lime_cairo | lime_cffi | lime_curl | lime_harfbuzz | lime_native | lime_openal | lime_opengl | lime_threads | lime_vorbis) ;;
      *) continue ;;
    esac
    if [ "$val" = "1" ] || [ "$val" = "true" ]; then
      defs+=("-D" "$key")
    else
      defs+=("-D" "$key=$val")
    fi
  done < "$options"

  echo "[typecheck] 取自 $options 的真实 define 数=${#defs[@]}"
  printf '%s\n' "${defs[@]}" | paste -sd' ' - | fold -w 160 | sed 's/^/[typecheck]   /'

  haxe -cp source -cp verify "${LIB_ARGS[@]}" -lib hxcpp \
    -main Main -cpp "$OUT_DIR/cpptype" --no-output \
    "${defs[@]}" \
    --remap flash:openfl \
    --macro "lime._internal.macros.DefineMacro.run()" \
    --macro "openfl.utils._internal.ExtraParamsMacro.include()" \
    --macro "flixel.system.macros.FlxDefines.run()" \
    --macro "coverage.CoverageCheck.run()"
  local rc=$?
  echo "[typecheck] haxe exit=$rc"
  return $rc
}

case "$MODE" in
  --neko) run_neko ;;
  --cpp) run_cpp ;;
  --window) run_window "" ;;
  --window-debug) run_window "-debug" ;;
  --typecheck) run_typecheck ;;
  *)
    echo "未知参数：$MODE（可用：--neko / --cpp / --window / --window-debug / --typecheck）" >&2
    exit 2
    ;;
esac
