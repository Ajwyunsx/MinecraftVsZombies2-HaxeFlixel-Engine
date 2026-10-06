#!/usr/bin/env bash
# 字体探针工程的资源准备：只拷字体相关的 15MB（4 个 otf + 导出的图集 PNG）。
#
# 为什么不 <assets path="../../assets" />：lime 会把整个 943MB 拷进工程目录，且会与
# 其它并行 agent 的构建抢 IO。为什么不建成指回 HaxePort/assets 的目录联接：那样 lime 依然
# 会去拷贝联接目标下的全部内容。
#
# 目录名必须是 `assets`（与主工程 Project.xml 的 <assets path="assets" /> 一致），
# 这样运行期的资产 id（`assets/Fonts/unifont.otf`）才与真实游戏相同，探针结论才可迁移。
set -e
here="$(cd "$(dirname "$0")" && pwd)"
src="$here/../../assets"
dst="$here/assets"

rm -rf "$dst"
mkdir -p "$dst/Fonts/mojangles" "$dst/Fonts/atlas"
cp "$src/Fonts/unifont.otf" "$dst/Fonts/"
cp "$src/Fonts/mojangles/minecraft_font.otf" "$dst/Fonts/mojangles/"
cp "$src/Fonts/mojangles/accented.otf" "$dst/Fonts/mojangles/"
cp "$src/Fonts/mojangles/nonlatin_european.otf" "$dst/Fonts/mojangles/"
if ls "$src/Fonts/atlas/"*.png >/dev/null 2>&1; then
	cp "$src/Fonts/atlas/"*.png "$dst/Fonts/atlas/"
fi
du -sh "$dst"
find "$dst" -type f | sed "s|$here/||"
