package mvz2.sprites;

import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import mvz2.io.PathHelper;
import mvz2.sprites.SpriteManifestData.SpriteDefinition;
import mvz2.sprites.SpriteManifestData.SpriteSheetDefinition;
import mvz2.sprites.SpriteManifestData.SpriteTextureDefinition;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import unity.Application;
import unity.Debug;
import unity.Rect;
import unity.Texture2D;

// PORT-NOTE: 移植层新增。原工程里 Sprite 的贴图由 Unity 直接持有（sprite.texture），
// 渲染由 SpriteRenderer 完成；移植层需要把 PNG 解码成 openfl BitmapData 再切片。
// 本类负责：assetPath -> unity.Texture2D 的懒加载缓存，以及 Unity 坐标系矩形 ->
// openfl 左上角坐标的换算（Unity rect 的 y 从贴图底部起算，BitmapData 从顶部起算），
// 并把 BitmapData 保存在 textureBitmaps 里供渲染层取用。
//
// 与 unity.Texture2D 的关系：unity.Texture2D 的 shim 不持有像素（见 source/unity/Texture2D.hx），
// 因此纹理像素通过本类的 textureBitmaps 表暴露：
//   var tex = SpriteManifestLoader.getUnityTexture(def);
//   var bitmap = SpriteTextureCache.getBitmapData(tex);
class SpriteTextureCache {
    /// unity.Texture2D -> 解码后的位图。
    public static var textureBitmaps:Map<Texture2D, BitmapData> = new Map();
    /// 按精灵/图集 id 切好的帧位图缓存（键为 "id@x,y,w,h"）。
    public static var frameBitmaps:Map<String, BitmapData> = new Map();
    /// assetPath -> unity.Texture2D。
    public static var texturesByPath:Map<String, Texture2D> = new Map();

    private function new() {}

    /// 取得（必要时解码）贴图对象。失败时返回 null 并记录错误。
    /// assetPath 为工作包 ① 的 resource_manifest.json 解析出的路径，缺省时用贴图自身的 assetPath。
    public static function getTexture(definition:SpriteTextureDefinition, ?assetPath:String):Texture2D {
        if (definition == null)
            return null;
        var path = assetPath != null ? assetPath : definition.assetPath;
        if (path == null)
            return null;
        var cached = texturesByPath.get(path);
        if (cached != null)
            return cached;
        // PORT-NOTE: 先建对象后解码，避免解码失败时重复尝试；尺寸取自 .meta 对应的 PNG 头。
        var texture = new Texture2D(definition.width, definition.height);
        texture.name = path;
        texture.assetPath = path;
        texturesByPath.set(path, texture);
        // PORT-NOTE: 解码统一走工作包 ① 的 assets/resource_manifest.json（按路径取，结果进
        // Flixel 的位图缓存），避免同一张 PNG 被本类与 ResourceManifest 各解一份。
        // 清单里没有该路径时 ResourceManifest 会按扩展名合成定位符，仍走同一条路径。
        var graphic:FlxGraphic = null;
        try {
            graphic = SpriteFrameFactory.getGraphic(texture);
        } catch (e:Dynamic) {
            graphic = null;
        }
        if (graphic != null && graphic.bitmap != null) {
            texture.graphic = graphic;
            textureBitmaps.set(texture, graphic.bitmap);
            texture.Reinitialize(graphic.bitmap.width, graphic.bitmap.height);
            return texture;
        }
        // TODO-PORT: 清单不可用（例如独立运行的自检程序没有 assets 根）时退回直接读盘。
        // 该兜底路径会与 ResourceManifest 各解一份位图，仅在清单缺失时触发。
        var bitmap = loadBitmapData(path);
        if (bitmap != null) {
            textureBitmaps.set(texture, bitmap);
            texture.Reinitialize(bitmap.width, bitmap.height);
            try {
                texture.graphic = FlxGraphic.fromBitmapData(bitmap, false, null, true);
            } catch (e:Dynamic) {}
        } else {
            Debug.LogError('SpriteTextureCache: 无法解码贴图 $path');
        }
        return texture;
    }

    /// 取得贴图对应的 BitmapData（渲染层用）。未缓存时返回 null。
    public static function getBitmapData(texture:Texture2D):BitmapData {
        return texture == null ? null : textureBitmaps.get(texture);
    }

    /// 按精灵定义取帧位图（已按 Unity 的 y 轴方向换算并裁切）。
    public static function getFrameBitmapData(sprite:SpriteDefinition):BitmapData {
        if (sprite == null)
            return null;
        var texture = getTexture(sprite.texture, sprite.assetPath);
        return getFrameBitmapDataFromTexture(texture, sprite.path, sprite.rect);
    }

    /// 按图集帧取帧位图。
    public static function getSliceBitmapData(sheet:SpriteSheetDefinition, sliceIndex:Int):BitmapData {
        if (sheet == null || sliceIndex < 0 || sliceIndex >= sheet.slices.length)
            return null;
        var slice = sheet.slices[sliceIndex];
        var texture = getTexture(sheet.texture, sheet.assetPath);
        return getFrameBitmapDataFromTexture(texture, '${sheet.path}[$sliceIndex]', slice.rect);
    }

    public static function getFrameBitmapDataFromTexture(texture:Texture2D, key:String, rect:Rect):BitmapData {
        if (texture == null || rect == null)
            return null;
        var cacheKey = '$key@${rect.x},${rect.y},${rect.width},${rect.height}';
        if (frameBitmaps.exists(cacheKey))
            return frameBitmaps.get(cacheKey);
        var source = getBitmapData(texture);
        if (source == null)
            return null;
        var frame = sliceBitmapData(source, rect);
        frameBitmaps.set(cacheKey, frame);
        return frame;
    }

    /// Unity 矩形（左下角原点，y 向上）-> 裁切后的 BitmapData。
    public static function sliceBitmapData(source:BitmapData, rect:Rect):BitmapData {
        var width = Std.int(rect.width);
        var height = Std.int(rect.height);
        if (width <= 0 || height <= 0)
            return null;
        // PORT-NOTE: Unity 的 rect.y 是距贴图底边的像素数，BitmapData 的 y 从顶边起算。
        var x = Std.int(Std.int(rect.x) + 0.5);
        var y = Std.int(source.height - rect.y - rect.height + 0.5);
        if (x < 0) x = 0;
        if (y < 0) y = 0;
        if (x + width > source.width) width = source.width - x;
        if (y + height > source.height) height = source.height - y;
        if (width <= 0 || height <= 0)
            return null;
        var result = new BitmapData(width, height, true, 0x00000000);
        // PORT-NOTE: C# 侧对应 Unity 的 Sprite 子矩形（由 SpriteRenderer 的 shader 完成），
        // 这里用 BitmapData.copyPixels 裁切（无缩放，矩形已在贴图范围内）。
        var sourceRect = new Rectangle(x, y, width, height);
        result.copyPixels(source, sourceRect, new Point(0, 0));
        return result;
    }

    public static function clear():Void {
        textureBitmaps.clear();
        frameBitmaps.clear();
        texturesByPath.clear();
    }

    private static function loadBitmapData(assetPath:String):BitmapData {
        // PORT-NOTE: 贴图路径由工作包 ① 的 resource_manifest.json 提供（见 SpriteManifestLoader），
        // 该清单的 path 与这里期望的形式一致（相对 HaxePort/assets/）。
        // 正常路径不会走到这里：getTexture 已优先经 ResourceManifest 取（同一份解码结果），
        // 本函数只在清单缺失（独立运行的自检程序）时兜底。
        // 优先走 openfl 资源清单（id 相对 Project.xml 的 <assets path="assets" />）。
        var candidates:Array<String> = [assetPath, "assets/" + assetPath];
        for (id in candidates) {
            try {
                if (openfl.utils.Assets.exists(id, openfl.utils.AssetType.IMAGE)) {
                    return openfl.utils.Assets.getBitmapData(id);
                }
            } catch (e:Dynamic) {}
        }
        #if sys
        // 开发期兜底：直接从磁盘读取（相对工作目录或仓库根）。
        var paths:Array<String> = [
            PathHelper.combine(Sys.getCwd(), assetPath),
            PathHelper.combine(Sys.getCwd(), "HaxePort", assetPath),
            PathHelper.combine(Application.dataPath, assetPath),
        ];
        for (path in paths) {
            if (sys.FileSystem.exists(path) && !sys.FileSystem.isDirectory(path)) {
                try {
                    return BitmapData.fromFile(path);
                } catch (e:Dynamic) {}
                try {
                    return BitmapData.fromImage(Image.fromFile(path));
                } catch (e:Dynamic) {}
            }
        }
        #end
        return null;
    }
}
