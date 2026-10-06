// PORT-NOTE: 验证用（不参与游戏构建）。**全量**取帧检查：把 sprites_manifest.json 里的
// 全部 709 个单帧精灵与 222 个图集（1222 帧）都真正取一遍帧，只统计不逐条打印。
// 用于确认「每一张能取到帧、图集帧数与清单一致、贴图解码次数 == 唯一贴图数（没有重复解码）」。
//
// 运行：bash HaxePort/tools_build/check_sprites.sh --all      # 全量（cpp）
//       bash HaxePort/tools_build/check_sprites.sh --all --neko
package sprites;

import mvz2.sprites.SpriteFrameFactory;
import mvz2.sprites.SpriteManifestLoader;

class AllSheetsSmoke {
    public static function main():Void {
        SpriteManifestLoader.load();
        SpriteFrameFactory.install();

        var total = 0;
        var frameFail = 0;
        for (s in SpriteManifestLoader.getSpriteDefinitions()) {
            total++;
            if (SpriteFrameFactory.getFrameOfDefinition(s) == null) {
                frameFail++;
                if (frameFail <= 10)
                    Sys.println('[FAIL] 精灵取帧失败：${s.path}（${s.assetPath}）');
            }
        }
        Sys.println('sprites: $total 取帧失败 $frameFail');

        var sheets = 0;
        var sheetFrames = 0;
        var sheetFail = 0;
        for (sh in SpriteManifestLoader.getSpriteSheetDefinitions()) {
            sheets++;
            var frames = SpriteFrameFactory.getSheetFrames(sh);
            if (frames.length != sh.slices.length) {
                sheetFail++;
                if (sheetFail <= 10)
                    Sys.println('[FAIL] 图集帧数不符：${sh.path} ${frames.length}/${sh.slices.length}');
            }
            sheetFrames += frames.length;
        }
        Sys.println('sheets: $sheets 帧总数 $sheetFrames 失败 $sheetFail');
        Sys.println('decodeCount=${SpriteFrameFactory.decodeCount}'
            + ' frameCacheMiss=${SpriteFrameFactory.missCount}'
            + ' frameCacheHit=${SpriteFrameFactory.hitCount}'
            + ' failure=${SpriteFrameFactory.failureCount}');
        if (SpriteFrameFactory.failureCount > 0)
            Sys.println('失败样例：${SpriteFrameFactory.failureKeys.slice(0, 10)}');

        var ok = frameFail == 0 && sheetFail == 0;
        Sys.println(ok ? '[sprites-all] 全部通过' : '[sprites-all] 有失败项');
        Sys.exit(ok ? 0 : 1);
    }
}
