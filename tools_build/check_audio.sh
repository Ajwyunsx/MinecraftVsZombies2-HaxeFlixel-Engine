#!/usr/bin/env bash
# 工作包 ④ 的运行时验证：编译并运行音频管线冒烟测试
# （真实读取 HaxePort/assets/audio_manifest.json，并真实解码/播放 assets 下的音频文件）。
#
#   bash HaxePort/tools_build/check_audio.sh            # neko（默认，最快，约 30 秒）
#   bash HaxePort/tools_build/check_audio.sh --cpp      # 与游戏同一目标（需要 hxcpp 覆盖层，见下）
#
# 输出目录默认是系统临时目录（${TMPDIR:-/tmp}/mvz2_audio_smoke），不会污染仓库。
#
# PORT-NOTE: 运行时 cwd 用**仓库根目录**（不是 export/windows/bin）：
#   1) 运行期按 cwd 向上搜索 assets 根（unity.addressableassets.ResourceManifest.findAssetRoots）。
#      从仓库根出发，第一个命中的根其实是 Unity 工程自己的 `Assets/`（Windows 大小写不敏感，
#      `Assets/` 里有 GameContent 目录所以被判定为 assets 根）——音频文件两边是同一份拷贝，
#      只有转换产物（如 mp3→ogg）只存在于镜像里，会落到第二个根 HaxePort/assets 上，结果相同。
#   2) export/windows/bin/assets 是某次未完成的 lime 构建留下的**部分拷贝**（时间戳更早），
#      以它为 cwd 会优先读到这份旧快照。需要按部署形态验证时用 MVZ2_AUDIO_RUN_DIR=export/windows/bin
#      覆盖（前提是该目录下的 assets 是最新的，或者至少包含本次验证需要的资源）。
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT_DIR="$(cd "$HERE/.." && pwd)"
REPO_DIR="$(cd "$PORT_DIR/.." && pwd)"
OUT_DIR="${MVZ2_AUDIO_SMOKE_OUT:-${TMPDIR:-/tmp}/mvz2_audio_smoke}"
CPP_FIX="${MVZ2_CPP_FIX:-${TMPDIR:-/tmp}/mvz2_cppfix}"
TARGET="${1:---neko}"
RUN_DIR="${MVZ2_AUDIO_RUN_DIR:-$REPO_DIR}"
case "$RUN_DIR" in
  /*|?:/*|?:\\*) ;;                      # 绝对路径（含 Windows 盘符）直接用
  *) RUN_DIR="$PORT_DIR/$RUN_DIR" ;;     # 否则视为相对 HaxePort/ 的路径
esac

cd "$PORT_DIR" || exit 1
mkdir -p "$OUT_DIR"

HAXE_FLAGS=(
  -cp source -cp verify
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl
  -lib hscript -lib hxjsonast -lib json2object
  -main audio.AudioPipelineSmokeTest
  -D lime_use_old_deltatime
  --macro "flixel.system.macros.FlxDefines.run()"
)

# PORT-NOTE: cpp 目标会遇到其它工作包尚未修完的 `Null<Bool>` 静态平台错误
# （见 tools_build/README 与 export/windows 下的构建记录），工作包 ② 在
# ${TMPDIR}/mvz2_cppfix 放了一份「临时修补覆盖层」。本脚本沿用同一覆盖层；
# 若该目录不存在则自动退回 neko。
if [ "$TARGET" = "--cpp" ]; then
  if [ ! -d "$CPP_FIX" ]; then
    echo "警告：找不到 hxcpp 覆盖层 $CPP_FIX，改用 neko 目标" >&2
    TARGET="--neko"
  else
    HAXE_FLAGS+=( -cp "$CPP_FIX" )
  fi
fi

if [ "$TARGET" = "--neko" ]; then
  haxe "${HAXE_FLAGS[@]}" -neko "$OUT_DIR/AudioPipelineSmokeTest.n" || exit 1
  cd "$RUN_DIR" || exit 1
  exec neko "$OUT_DIR/AudioPipelineSmokeTest.n"
fi

haxe "${HAXE_FLAGS[@]}" -cpp "$OUT_DIR/cpp" || exit 1
EXE="$(ls "$OUT_DIR/cpp/"*.exe 2>/dev/null | head -1)"
if [ -z "$EXE" ]; then
  echo "找不到生成的 exe（$OUT_DIR/cpp）" >&2
  exit 1
fi
cp -f "$RUN_DIR/lime.ndll" "$OUT_DIR/cpp/" 2>/dev/null || true
cd "$RUN_DIR" || exit 1
exec "$EXE"
