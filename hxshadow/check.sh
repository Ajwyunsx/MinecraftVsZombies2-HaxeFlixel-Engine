#!/bin/bash
# check.sh ["pkg1 pkg2 ..."]  -- type-check domain F packages
cd "$(dirname "$0")/.."
PKGS="${1:-mvz2.metas mvz2.models mvz2.localization mvz2.saves mvz2.options mvz2.talk mvz2.talkdata}"
set --
for p in $PKGS; do set -- "$@" --macro "include('$p',true)"; done
haxe -cp source -cp hxshadow \
  -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
  -lib hscript -lib hxjsonast -lib json2object \
  -D lime_use_old_deltatime --macro "flixel.system.macros.FlxDefines.run()" \
  -main TypeCheckMain -neko /tmp/x.n --no-output "$@" 2>&1 | grep -v "Warning : "
