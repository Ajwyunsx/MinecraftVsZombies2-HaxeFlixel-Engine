package mvz2.sprites;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxImageFrame;
import flixel.math.FlxRect;
import mvz2.sprites.SpriteManifestData.SpriteDefinition;
import mvz2.sprites.SpriteManifestData.SpriteSheetDefinition;
import openfl.display.BitmapData;
import unity.Debug;
import unity.Rect;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.Texture2D;
import unity.Vector2;
import unity.addressableassets.ResourceManifest;

// PORT-NOTE: 移植层新增（无 C# 对应源码）。本文件是「精灵 → Flixel 渲染」的接线点。
//
// C# 侧 UnityEngine.SpriteRenderer 直接持有 UnityEngine.Sprite（texture + rect + pivot +
// pixelsPerUnit），渲染由 Unity 的 GPU 管线按子矩形采样完成。移植层没有这套管线，必须把
// 「贴图 + 子矩形」显式表达成 Flixel 的帧：
//   * FlxGraphic —— 贴图像素（唯一解码来源，见 ResourceManifest.loadByPath / loadImageByPath）
//   * FlxFrame   —— 贴图内的一块矩形（Unity rect → Flixel 左上角坐标系）
//   * FlxFramesCollection（FlxImageFrame / FlxAtlasFrames）—— 可直接赋给 FlxSprite.frames
//
// 典型用法：
//   var sprite = Main.ResourceManager.GetSpriteFromReference(sprRef);   // unity.Sprite
//   renderer.sprite = sprite;                                           // 逻辑层照旧
//   SpriteFrameFactory.ApplyToRenderer(renderer);                       // 渲染层接线
// 或者一步到位：
//   var flx = SpriteFrameFactory.createFlxSprite(sprite);               // 直接拿 FlxSprite
//
// 坐标系（与 SpriteManifestData 的约定一致）：
//   Unity rect  —— 原点在贴图**左下角**，y 向上，单位为像素；
//   Flixel rect —— 原点在贴图**左上角**，y 向下。
//   换算：flixelY = textureHeight - unityY - unityHeight（贴图高度取解码后的实际像素）。
//   pivot  —— Unity 是 0..1 归一化值（0,0 = 左下角），Flixel 的 origin 是像素且 FlxSprite 的
//   位置表示帧左上角，故 origin = (pivot.x * w, (1 - pivot.y) * h)
//   （对齐方式 6 = BottomLeft 恰好得到 origin=(0, h)，与 Unity 的 SpriteRenderer 位置语义一致）。
class SpriteFrameFactory {
    /// (贴图, Unity 矩形) → FlxFrame 的缓存（键为 "贴图路径@x,y,w,h"）。
    private static var frameCache:Map<String, FlxFrame> = new Map();
    /// 每个 FlxGraphic 上自建的唯一帧集合（放全部精灵子矩形帧）。
    private static var framesByGraphic:Map<FlxGraphic, FlxAtlasFrames> = new Map();
    /// 精灵图集定义 → FlxAtlasFrames（帧顺序与清单 slices 一致）。
    private static var sheetCache:Map<String, FlxAtlasFrames> = new Map();
    /// (FlxGraphic, 矩形) → FlxImageFrame（见 makeImageFrame 的说明）。
    private static var imageFrameCache:Map<String, FlxImageFrame> = new Map();

    /** 诊断统计：帧缓存命中/未命中、实际解码次数、失败次数与样例。 */
    public static var hitCount:Int = 0;
    public static var missCount:Int = 0;
    public static var decodeCount:Int = 0;
    public static var failureCount:Int = 0;
    public static var failureKeys:Array<String> = [];

    private function new() {}

    // ------------------------------------------------------------ 贴图 → FlxGraphic

    /// 取贴图对应的 FlxGraphic（像素的唯一来源）。
    /// 顺序：texture.graphic（已解出）→ ResourceManifest.loadImageByPath(texture.assetPath)
    /// → SpriteTextureCache 已解好的 BitmapData（旧路径兜底）。结果一律回填 texture.graphic，
    /// 保证同一张贴图在进程里只解码一次（修掉「ResourceManifest 解一遍、SpriteTextureCache 又解一遍」）。
    public static function getGraphic(texture:Texture2D):FlxGraphic {
        if (texture == null)
            return null;
        if (texture.graphic != null && !texture.graphic.isDestroyed)
            return texture.graphic;
        // PORT-NOTE: 贴图路径优先用 texture.assetPath（SpriteTextureCache.getTexture 写入），
        // 缺省时退回 texture.name（SpriteManifestLoader 也把路径写在那里）。
        var path = texture.assetPath != null ? texture.assetPath : texture.name;
        if (path != null && path != "") {
            var graphic = toGraphic(ResourceManifest.get().loadImageByPath(path));
            if (graphic != null) {
                texture.graphic = graphic;
                decodeCount++;
                return graphic;
            }
        }
        // PORT-NOTE: 兜底——SpriteTextureCache 已按旧路径解过这张图，复用它的 BitmapData，
        // 不再解第二次；同时登记进 Flixel 的位图缓存，后续统一走 texture.graphic。
        var bitmap = SpriteTextureCache.getBitmapData(texture);
        if (bitmap != null) {
            var graphic = toGraphic(bitmap);
            if (graphic != null) {
                texture.graphic = graphic;
                return graphic;
            }
        }
        return null;
    }

    private static function toGraphic(asset:Dynamic):FlxGraphic {
        if (asset == null)
            return null;
        if (Std.isOfType(asset, FlxGraphic))
            return cast asset;
        if (Std.isOfType(asset, BitmapData)) {
            // PORT-NOTE: 键交给 Flixel 的位图缓存按位图对象自身去重（Key 传 null），
            // 这样同一个 BitmapData 不会在缓存里出现两份 FlxGraphic。
            var graphic = FlxGraphic.fromBitmapData(cast asset, false, null, true);
            // PORT-NOTE: 同 ResourceManifest.decodeImage——移植层把这些 FlxGraphic 当常驻资源，
            // 关掉「useCount 归零即销毁」，否则换帧/销毁渲染对象会把位图一起销毁。
            if (graphic != null)
                graphic.destroyOnNoUse = false;
            return graphic;
        }
        return null;
    }

    /// 贴图解码后的实际像素尺寸（Unity rect 的 y 轴换算需要它）。
    /// 清单里的 width/height 与实际 PNG 曾出现不一致，因此以解码结果为准。
    public static function getPixelSize(texture:Texture2D):{width:Int, height:Int} {
        if (texture == null)
            return {width: 0, height: 0};
        var graphic = getGraphic(texture);
        if (graphic != null && graphic.bitmap != null)
            return {width: graphic.bitmap.width, height: graphic.bitmap.height};
        return {width: texture.width, height: texture.height};
    }

    // ------------------------------------------------------- unity.Rect → Flixel 矩形

    /// Unity 矩形（左下角原点，y 向上）→ Flixel 矩形（左上角原点，y 向下），并夹取到贴图范围内。
    /// 与 SpriteTextureCache.sliceBitmapData 的换算保持一致（那边裁位图，这边给帧）。
    public static function toFlixelRect(rect:Rect, textureHeight:Int, ?textureWidth:Int):FlxRect {
        if (rect == null)
            return null;
        var width = Std.int(rect.width + 0.5);
        var height = Std.int(rect.height + 0.5);
        if (width <= 0 || height <= 0)
            return null;
        var x = Std.int(rect.x + 0.5);
        var y = Std.int(textureHeight - rect.y - rect.height + 0.5);
        if (x < 0)
            x = 0;
        if (y < 0)
            y = 0;
        if (textureWidth != null && textureWidth > 0 && x + width > textureWidth)
            width = textureWidth - x;
        if (textureHeight > 0 && y + height > textureHeight)
            height = textureHeight - y;
        if (width <= 0 || height <= 0)
            return null;
        // PORT-NOTE: 这里用 FlxRect.get（对象池）而不是 new FlxRect()：调用方
        // （addSpriteSheetFrame / FlxImageFrame.fromEmptyFrame）都会把矩形 copy 一份后放回池子。
        return FlxRect.get(x, y, width, height);
    }

    /// Unity 的归一化 pivot → Flixel 的 origin（像素，左上角原点）。
    public static function toOrigin(pivot:Vector2, width:Int, height:Int):{x:Float, y:Float} {
        if (pivot == null)
            return {x: width * 0.5, y: height * 0.5};
        return {x: pivot.x * width, y: (1 - pivot.y) * height};
    }

    // ------------------------------------------------------------------- 取帧

    /// 取 unity.Sprite 对应的 FlxFrame（贴图内矩形，带正确坐标系）。
    public static function getFrame(sprite:Sprite):FlxFrame {
        if (sprite == null)
            return null;
        return getFrameFrom(sprite.texture, sprite.rect);
    }

    /// 取 (贴图, Unity 矩形) 对应的 FlxFrame。同一 (贴图, 矩形) 只构造一次。
    public static function getFrameFrom(texture:Texture2D, unityRect:Rect):FlxFrame {
        if (texture == null || unityRect == null)
            return null;
        var cacheKey = frameKey(texture, unityRect);
        var cached = frameCache.get(cacheKey);
        if (cached != null) {
            hitCount++;
            return cached;
        }
        var size = getPixelSize(texture);
        var graphic = getGraphic(texture);
        if (graphic == null) {
            fail(cacheKey);
            return null;
        }
        var rect = toFlixelRect(unityRect, size.height, size.width);
        if (rect == null) {
            fail(cacheKey);
            return null;
        }
        // PORT-NOTE: addSpriteSheetFrame 内部会 pushFrame（此处 name 为 null，不写名字表），
        // 并完成 sourceSize/offset 赋值与 cacheFrameMatrix()，故不再重复设置。
        var frame = framesOf(graphic).addSpriteSheetFrame(rect);
        frameCache.set(cacheKey, frame);
        missCount++;
        return frame;
    }

    /// 取 (贴图, Unity 矩形) 对应的**具名**帧（写进该 FlxGraphic 的名字表，可按名取用）。
    public static function getNamedFrameFrom(texture:Texture2D, unityRect:Rect, name:String):FlxFrame {
        var frame = getFrameFrom(texture, unityRect);
        if (frame == null || name == null)
            return frame;
        var frames = framesOf(frame.parent);
        if (frames.exists(name))
            return frames.getByName(name);
        frame.name = name;
        frames.pushFrame(frame, false);
        return frame;
    }

    /// 取 unity.Sprite 对应的单帧集合（可直接赋给 FlxSprite.frames）。
    /// PORT-NOTE: 用 FlxGraphic 自带的 imageFrame（flixel 维护整图帧的缓存），不要用
    /// FlxImageFrame.fromRectangle —— 后者按 (graphic, region) 命中帧集合缓存，
    /// 会把「整图帧」与「精灵子矩形帧」混在一起。
    public static function getImageFrame(sprite:Sprite):FlxImageFrame {
        if (sprite == null)
            return null;
        return getWholeImageFrame(sprite.texture);
    }

    /// 取整张贴图的单帧集合（贴图当一帧用，对应 Unity 里 spriteMode=1 的贴图）。
    public static function getWholeImageFrame(texture:Texture2D):FlxImageFrame {
        if (texture == null)
            return null;
        var graphic = getGraphic(texture);
        if (graphic == null) {
            fail('imageFrame:${keyOf(texture)}');
            return null;
        }
        return graphic.imageFrame;
    }

    /// 为某个矩形单独建一个单帧集合（不污染 FlxGraphic 的整图帧缓存）。
    /// PORT-NOTE: **不能**用 `FlxImageFrame.fromFrame`：它把 `source.frame` 直接交给
    /// `FlxImageFrame.findFrame`，而 findFrame 内部 `FlxRect.equals` 会对传入矩形调用
    /// `putWeak()`（Flixel 的对象池回收），于是帧自己的矩形被回收、下一次 `FlxRect.get()`
    /// 就把它拿走改成别的值（实测表现为第二个精灵的帧矩形错乱）。
    /// 这里改用 `fromEmptyFrame`（不碰传入矩形）建集合，再把 frames[0] 换成真实帧；
    /// 同一 (graphic, rect) 的结果按帧缓存复用。
    public static function makeImageFrame(frame:FlxFrame):FlxImageFrame {
        if (frame == null || frame.parent == null)
            return null;
        var key = 'img:${frame.parent.key}@${frame.frame.x},${frame.frame.y},${frame.frame.width},${frame.frame.height}';
        var cached = imageFrameCache.get(key);
        if (cached != null && cached.frames.length > 0 && cached.frames[0] == frame)
            return cached;
        var rect = FlxRect.get(frame.frame.x, frame.frame.y, frame.frame.width, frame.frame.height);
        var collection = FlxImageFrame.fromEmptyFrame(frame.parent, rect);
        rect.put();
        if (collection == null)
            return null;
        // PORT-NOTE: 用真实帧替换占位空帧（frames 是 FlxFramesCollection 的公开数组）。
        collection.frames[0] = frame;
        imageFrameCache.set(key, collection);
        return collection;
    }

    // ------------------------------------------------------------------- 图集

    /// 取精灵图集（SpriteSheetDefinition）对应的 FlxAtlasFrames，帧顺序与清单 slices 一致。
    /// FlxSprite.animation.addByPrefix / addByIndices 都按这个顺序取帧。
    public static function getAtlasFrames(sheet:SpriteSheetDefinition):FlxAtlasFrames {
        if (sheet == null || sheet.texture == null)
            return null;
        var key = sheet.path != null ? sheet.path : sheet.id;
        var cached = sheetCache.get(key);
        if (cached != null)
            return cached;
        var texture = SpriteManifestLoader.getUnityTexture(sheet.texture, sheet.assetPath);
        if (texture == null) {
            fail('atlas:$key');
            return null;
        }
        var graphic = getGraphic(texture);
        if (graphic == null) {
            fail('atlas:$key');
            return null;
        }
        var atlas = new FlxAtlasFrames(graphic);
        for (slice in sheet.slices) {
            var frame = getFrameFrom(texture, slice.rect);
            if (frame == null)
                continue;
            // PORT-NOTE: 图集里必须带名字，animation.addByPrefix / getByName 才可用；
            // 名字用清单里 Unity 的 Sprite 子资源名（如 leather_cap_0）。
            var name = slice.name != null ? slice.name : '$key[${atlas.frames.length}]';
            if (!atlas.exists(name))
                frame.name = name;
            atlas.pushFrame(frame, false);
        }
        sheetCache.set(key, atlas);
        return atlas;
    }

    /// 取精灵图集的所有帧（顺序与 slices 一致）。
    public static function getSheetFrames(sheet:SpriteSheetDefinition):Array<FlxFrame> {
        var atlas = getAtlasFrames(sheet);
        return atlas == null ? [] : atlas.frames;
    }

    /// 取精灵图集第 index 帧。
    public static function getSheetFrame(sheet:SpriteSheetDefinition, index:Int):FlxFrame {
        var frames = getSheetFrames(sheet);
        if (index < 0 || index >= frames.length)
            return null;
        return frames[index];
    }

    /// 图集第 index 帧的单帧集合（可用于 FlxSprite.frames）。
    public static function getSheetImageFrame(sheet:SpriteSheetDefinition, index:Int):FlxImageFrame {
        return makeImageFrame(getSheetFrame(sheet, index));
    }

    // --------------------------------------------------- 渲染器接线（unity.SpriteRenderer）

    /// 安装到 unity.SpriteRenderer 的精灵转换钩子（shim 层不反向依赖本包，用钩子接线）。
    /// 幂等：可在任意初始化点重复调用。
    public static function install():Void {
        SpriteRenderer.spriteApplier = ApplyToRenderer;
    }

    /// 把 unity.SpriteRenderer 的 sprite（unity.Sprite）落到它实际渲染用的 FlxSprite 上。
    /// 返回是否成功写入了帧。sprite 已经是 flixel.FlxSprite 时视为已接线，直接返回 true。
    public static function ApplyToRenderer(renderer:SpriteRenderer):Bool {
        if (renderer == null)
            return false;
        var sprite:Dynamic = renderer.sprite;
        if (sprite == null) {
            var target = renderer.renderSprite;
            if (target != null)
                target.visible = false;
            return false;
        }
        if (Std.isOfType(sprite, FlxSprite)) {
            // PORT-NOTE: prefab 里直接把 FlxSprite 写进 sprite 字段的情况（见 ModelPrefabAssets），
            // 此时它就是渲染对象本身。
            renderer.renderSprite = cast sprite;
            return true;
        }
        if (!Std.isOfType(sprite, Sprite))
            return false;
        return applyUnitySprite(cast sprite, renderer);
    }

    private static function applyUnitySprite(sprite:Sprite, renderer:SpriteRenderer):Bool {
        var frame = getFrame(sprite);
        if (frame == null)
            return false;
        var target = renderer.renderSprite;
        if (target == null) {
            target = new FlxSprite();
            renderer.renderSprite = target;
        }
        // PORT-NOTE: 每次换帧都重建单帧集合：FlxImageFrame 的「整图」语义决定了同一个集合
        // 不能承载两个不同矩形（flixel 会按 (graphic, region) 去重，导致互相覆盖）。
        target.frames = makeImageFrame(frame);
        target.frame = frame;
        var origin = toOrigin(sprite.pivot, Std.int(frame.frame.width), Std.int(frame.frame.height));
        target.origin.set(origin.x, origin.y);
        target.resetSizeFromFrame();
        target.resetSize();
        target.visible = true;
        // PORT-NOTE: Unity 的 SpriteRenderer.flipX/flipY 与 Flixel 的 flipX/flipY 语义一致，
        // 这里同步一次，保证「先设 sprite 再设 flip」与「先设 flip 再设 sprite」结果相同。
        target.flipX = renderer.flipX;
        target.flipY = renderer.flipY;
        target.alpha = renderer.alpha;
        target.color = flixel.util.FlxColor.fromRGBFloat(renderer.color.r, renderer.color.g, renderer.color.b, 1);
        target.visible = renderer.enabled;
        return true;
    }

    /// 按 unity.Sprite 建一个新的 FlxSprite（独立渲染对象，供需要自己的显示对象的场合）。
    public static function createFlxSprite(sprite:Sprite):FlxSprite {
        if (sprite == null)
            return null;
        var frame = getFrame(sprite);
        if (frame == null)
            return null;
        var result = new FlxSprite();
        result.frames = makeImageFrame(frame);
        result.frame = frame;
        var origin = toOrigin(sprite.pivot, Std.int(frame.frame.width), Std.int(frame.frame.height));
        result.origin.set(origin.x, origin.y);
        result.resetSizeFromFrame();
        result.resetSize();
        return result;
    }

    /// 按精灵图集第 index 帧建一个 FlxSprite。
    public static function createSheetFlxSprite(sheet:SpriteSheetDefinition, index:Int):FlxSprite {
        var frame = getSheetFrame(sheet, index);
        if (frame == null)
            return null;
        var result = new FlxSprite();
        result.frames = makeImageFrame(frame);
        result.frame = frame;
        var slice = sheet.slices[index];
        var origin = toOrigin(slice.pivot, Std.int(frame.frame.width), Std.int(frame.frame.height));
        result.origin.set(origin.x, origin.y);
        result.resetSizeFromFrame();
        result.resetSize();
        return result;
    }

    // ------------------------------------------------------------------ 便捷入口

    /// 按精灵定义取帧（走定义里的 texture/rect，不新建 unity.Sprite）。
    public static function getFrameOfDefinition(definition:SpriteDefinition):FlxFrame {
        if (definition == null)
            return null;
        var texture = SpriteManifestLoader.getUnityTexture(definition.texture, definition.assetPath);
        return getFrameFrom(texture, definition.rect);
    }

    /// 按精灵定义取单帧集合。
    public static function getImageFrameOfDefinition(definition:SpriteDefinition):FlxImageFrame {
        return makeImageFrame(getFrameOfDefinition(definition));
    }

    /// 按精灵路径（NamespaceID.Path，如 `entity/armor/leather_cap`）取帧。
    public static function getFrameByPath(path:String):FlxFrame {
        return getFrameOfDefinition(SpriteManifestLoader.getSpriteDefinition(path));
    }

    public static function clear():Void {
        frameCache.clear();
        framesByGraphic.clear();
        sheetCache.clear();
        imageFrameCache.clear();
        hitCount = 0;
        missCount = 0;
        decodeCount = 0;
        failureCount = 0;
        failureKeys = [];
    }

    // -------------------------------------------------------------------- 内部

    private static function framesOf(graphic:FlxGraphic):FlxAtlasFrames {
        var existing = framesByGraphic.get(graphic);
        if (existing != null)
            return existing;
        // PORT-NOTE: FlxFramesCollection 的构造函数会把自己挂到 parent.addFrameCollection，
        // 因此「每个 FlxGraphic 只建一个自建帧集合」既避免重复挂载告警，也保证帧下标稳定。
        var frames = new FlxAtlasFrames(graphic);
        framesByGraphic.set(graphic, frames);
        return frames;
    }

    private static function frameKey(texture:Texture2D, rect:Rect):String {
        return '${keyOf(texture)}@${rect.x},${rect.y},${rect.width},${rect.height}';
    }

    private static function keyOf(texture:Texture2D):String {
        if (texture == null)
            return "null";
        if (texture.assetPath != null)
            return texture.assetPath;
        return texture.name != null ? texture.name : Std.string(texture);
    }

    private static function fail(key:String):Void {
        failureCount++;
        if (failureKeys.length < 100)
            failureKeys.push(key);
        Debug.LogWarning('SpriteFrameFactory: 无法为 $key 生成帧（贴图未解码或矩形为空）。');
    }
}
