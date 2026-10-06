// PORT-NOTE: 移植层自检（无 C# 对应源码）。验证「贴图路径 → 解码 → FlxFrame → FlxSprite」
// 每一步的**实际像素尺寸**。必须用 cpp 目标跑：--interp 下 lime 不支持
// Image.fromBytes（"Image.fromBytes not supported on this target"），位图恒为 0x0，
// 结论会假阴性。
import haxe.Json;
import mvz2.sprites.SpriteFrameFactory;
import mvz2.sprites.SpriteManifestLoader;
import mvz2.sprites.SpriteTextureCache;
import unity.Sprite;
import unity.addressableassets.ResourceManifest;
import unity.addressableassets.Addressables;

class UiProbe {
    static function main():Void {
        var log = new StringBuf();
        function out(s:String):Void {
            log.add(s + "\n");
            trace(s);
        }
        out("=== UiProbe(cpp) 开始 ===");
        out('dataPath=${unity.Application.dataPath}');
        out('cwd=${Sys.getCwd()}');

        var loaded = SpriteManifestLoader.load();
        out('SpriteManifestLoader.load = $loaded');

        var rm = ResourceManifest.get();
        out('ResourceManifest.get() = ${rm != null}');

        var paths = [
            "GameContent/Assets/mvz2/sprites/init/logo.png",
            "GameContent/Assets/mvz2/sprites/init/form.png",
            "GameContent/Assets/mvz2/sprites/init/button.png",
        ];
        for (p in paths) {
            out('--- loadImageByPath($p)');
            var asset = rm != null ? rm.loadImageByPath(p) : null;
            out('    asset=${asset != null} class=${asset == null ? "null" : Type.getClassName(Type.getClass(asset))}');
            var bd = ResourceManifest.bitmapDataOf(asset);
            out('    bitmapData=${bd != null} size=${bd == null ? "-" : '${bd.width}x${bd.height}'}');
        }

        var def = SpriteManifestLoader.getSpriteDefinition("init/logo");
        if (def == null) {
            out("!! def init/logo = null");
        } else {
            out('def init/logo assetPath=${def.assetPath} rect=(${def.rect.x},${def.rect.y},${def.rect.width},${def.rect.height})');
            var sprite = SpriteManifestLoader.createSprite(def);
            out('sprite=${sprite != null}');
            if (sprite != null) {
                var graphic = SpriteFrameFactory.getGraphic(sprite.texture);
                out('graphic=${graphic != null} bitmap=${graphic != null && graphic.bitmap != null}');
                if (graphic != null && graphic.bitmap != null)
                    out('bitmap=${graphic.bitmap.width}x${graphic.bitmap.height}');
                var px = SpriteFrameFactory.getPixelSize(sprite.texture);
                out('pixelSize=${px.width}x${px.height}');
                var f = SpriteFrameFactory.getFrame(sprite);
                out('frame=${f != null}');
                if (f != null) {
                    out('frame.frame=(${f.frame.x},${f.frame.y},${f.frame.width},${f.frame.height})');
                    out('frame.sourceSize=(${f.sourceSize.x},${f.sourceSize.y})');
                }
                var ifr = SpriteFrameFactory.makeImageFrame(f);
                out('imageFrame=${ifr != null}');
                if (ifr != null && ifr.frames.length > 0) {
                    var f0 = ifr.frames[0];
                    out('imageFrame.frames[0]=(${f0.frame.x},${f0.frame.y},${f0.frame.width},${f0.frame.height})');
                }
            }
        }
        out('failureCount=${SpriteFrameFactory.failureCount} decodeCount=${SpriteFrameFactory.decodeCount}');
        if (SpriteFrameFactory.failureKeys.length > 0)
            out('failureKeys=${SpriteFrameFactory.failureKeys.slice(0, 8)}');
        out("=== UiProbe(cpp) 结束 ===");
        try {
            sys.io.File.saveContent(Sys.getCwd() + "/ui-probe.log", log.toString());
        } catch (e:Dynamic) {}
    }
}
