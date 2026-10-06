#!/usr/bin/env bash
# 建 export/windows/bin/assets 目录联接指回 HaxePort/assets（本验证工程不拷贝 943MB 资源）。
set -e
here="$(cd "$(dirname "$0")" && pwd)"
bin="$here/export/windows/bin"
mkdir -p "$bin"
link="$bin/assets"
if [ -e "$link" ] || [ -L "$link" ]; then
	echo "assets 已存在，跳过：$link"
else
	cmd //c mklink //J "$(cygpath -w "$link")" "$(cygpath -w "$here/../../assets")"
fi
ls -la "$link" | head -5
