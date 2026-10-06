#!/usr/bin/env bash
# 工作包 A 的运行时验证：编译并运行 system.xml 语义 / 元数据解析冒烟测试。
# （真实读取 HaxePort/assets 下的 Meta XML，并复刻 ResourceManager.LoadSingleMetaList 的链路）
#
#   bash HaxePort/tools_build/check_xml.sh            # 默认 neko（快，约 40 秒）
#   bash HaxePort/tools_build/check_xml.sh --cpp      # 与游戏同一目标（慢）
#
# 输出目录默认是系统临时目录（$TMPDIR/mvz2_xml_smoke），不会污染仓库。
# 运行时 cwd 用 export/windows/bin（与游戏一致），assets 根由运行期向上搜索得到。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_SMOKE_OUT:-${TMPDIR:-/tmp}/mvz2_xml_smoke}"
TARGET="${1:---neko}"
RUN_DIR="$PORT_DIR/export/windows/bin"

cd "$PORT_DIR" || exit 1
mkdir -p "$OUT_DIR"

HAXE_FLAGS=(
  -cp source -cp verify
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl
  -lib hscript -lib hxjsonast -lib json2object
  -main xmlsmoke.XmlSmokeTest
  -D lime_use_old_deltatime
  --macro "flixel.system.macros.FlxDefines.run()"
)

if [ "$TARGET" = "--neko" ]; then
  haxe "${HAXE_FLAGS[@]}" -neko "$OUT_DIR/XmlSmokeTest.n" || exit 1
  cd "$RUN_DIR" || exit 1
  neko "$OUT_DIR/XmlSmokeTest.n"
else
  # PORT-NOTE: cpp 目标当前还有几个「类型检查看不出来、hxcpp 生成期才报」的问题（见
  # tools_build/make_cpp_overlay.py 的说明）。verify_build/Project.xml 用覆盖层目录兜住它们；
  # 这里同样把覆盖层排在 source 之后（Haxe 后出现的 -cp 对重复模块优先）。
  OVERLAY="${TEMP:-/tmp}/mvz2_cppfix"
  if [ -d "$OVERLAY" ]; then
    HAXE_FLAGS+=(-cp "$OVERLAY")
    echo "使用 cpp 覆盖层：$OVERLAY"
  fi
  haxe "${HAXE_FLAGS[@]}" -cpp "$OUT_DIR/cpp" || exit 1
  EXE="$(ls "$OUT_DIR/cpp/"*.exe 2>/dev/null | head -1)"
  if [ -z "$EXE" ]; then
    echo "找不到生成的 exe（$OUT_DIR/cpp）" >&2
    exit 1
  fi
  cp -f "$RUN_DIR/lime.ndll" "$OUT_DIR/cpp/" 2>/dev/null || true
  cd "$RUN_DIR" || exit 1
  "$EXE"
fi
