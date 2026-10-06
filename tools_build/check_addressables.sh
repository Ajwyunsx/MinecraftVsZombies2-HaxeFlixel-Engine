#!/usr/bin/env bash
# 工作包 ② 的运行时验证：编译并运行 Addressables 冒烟测试
# （真实读取 HaxePort/assets/resource_manifest.json 与 assets 下的资源文件）。
#
#   bash HaxePort/tools_build/check_addressables.sh            # 默认 cpp（与游戏同一目标）
#   bash HaxePort/tools_build/check_addressables.sh --neko     # 快速跑一遍（neko）
#
# 输出目录默认是系统临时目录（$TMPDIR/mvz2_addressables_smoke），不会污染仓库。
# 运行时 cwd 用 export/windows/bin（与游戏一致），assets 根由运行期向上搜索得到。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
OUT_DIR="${MVZ2_SMOKE_OUT:-${TMPDIR:-/tmp}/mvz2_addressables_smoke}"
TARGET="${1:---cpp}"
RUN_DIR="$PORT_DIR/export/windows/bin"

cd "$PORT_DIR" || exit 1
mkdir -p "$OUT_DIR"

HAXE_FLAGS=(
  -cp source -cp verify
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl
  -lib hscript -lib hxjsonast -lib json2object
  -main addressables.AddressablesSmokeTest
  -D lime_use_old_deltatime
  --macro "flixel.system.macros.FlxDefines.run()"
)

if [ "$TARGET" = "--neko" ]; then
  haxe "${HAXE_FLAGS[@]}" -neko "$OUT_DIR/AddressablesSmokeTest.n" || exit 1
  cd "$RUN_DIR" || exit 1
  neko "$OUT_DIR/AddressablesSmokeTest.n"
else
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
