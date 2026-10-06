// PORT-NOTE: 验证用（不参与游戏构建）。精灵/贴图纸张接线到 Flixel 的运行期冒烟测试：
// 真实读取 HaxePort/assets/sprites_manifest.json + resource_manifest.json，真实解码 PNG，
// 并把 unity.Sprite 转成 FlxFrame / FlxImageFrame / FlxAtlasFrames，断言：
//   1. 贴图只解码一次（ResourceManifest 与 SpriteTextureCache 共用同一份 FlxGraphic）；
//   2. Unity 左下角 rect → Flixel 左上角帧矩形的换算（含 y 翻转、夹取）；
//   3. pivot → origin 的换算（含 alignment 推导出的 0/0.5/1 三种对齐）；
//   4. 单帧精灵 / 图集（entity/*、ui/*、level/*、characters/*）的帧尺寸与清单一致；
//   5. 帧像素内容与直接从 PNG 读出的像素一致（真实解码，非仅元数据）；
//   6. FlxSprite.frames 赋值后 frameWidth/frameHeight/origin 正确（渲染层可用的最小条件）。
//
// 运行：bash HaxePort/tools_build/check_sprites.sh            # 默认 cpp（与游戏同目标）
//       bash HaxePort/tools_build/check_sprites.sh --neko     # neko（部分依赖 mvz2 的检查会跳过）
package sprites;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxImageFrame;
import mvz2.models.ModelPrefabData.ModelPrefabAssetRef;
import mvz2.sprites.SpriteFrameFactory;
import mvz2.sprites.SpriteManifestData.SpriteDefinition;
import mvz2.sprites.SpriteManifestData.SpriteSheetDefinition;
import mvz2.sprites.SpriteManifestLoader;
import mvz2.sprites.SpriteTextureCache;
import openfl.display.BitmapData;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.addressableassets.ResourceManifest;

class SpriteFrameSmokeMain {
    private static var checks:Int = 0;
    private static var notes:Int = 0;
    private static var failures:Array<String> = [];

    /// 代表性精灵（覆盖 entity / ui / level / map / misc / shading / artifacts / products /
    /// icons / achievements / init，含 alignment 推导出的各种 pivot）。
    private static var SPRITE_PATHS:Array<String> = [
        "entity/armor/bedserker_helmet",    // alignment=7 (Bottom)，pivot=(0.5,0)
        "entity/armor/emperor_crown",
        "entity/boss/red_dragon",
        "entity/effects/nightmareaper_shadow",
        "entity/projectiles/arrow",
        "entity/boss/seija_bomb",
        "ui/level/final_wave",
        "ui/almanac/book",
        "ui/charge_bar_background",
        "ui/close",
        "ui/achievements/frame",
        "ui/combat",
        "level/castle/castle",              // 1400x1020 大图，alignment=6 (BottomLeft)
        "level/palace/palace",
        "level/grids/normal",
        "level/hp_bar",
        "level/light",
        "level/shadow",
        "misc/castle",
        "shading/circle",
        "artifacts/almanac",
        "map/castle/map",
        "products/cake",
        "icons/disabled",
        "achievements/bonebreaker",
        "init/titlescreen",
    ];

    /// 代表性图集（entity/*、characters/*、ui/*、level/*、misc/*）。
    private static var SHEET_PATHS:Array<String> = [
        "entity/armor/leather_cap",
        "entity/armor/iron_helmet",
        "entity/armor/cannon",
        "entity/boss/nightmareaper",
        "entity/boss/nightmareaper_head",
        "entity/boss/frankenstein",
        "characters/eirin",
        "characters/byakuren",
        "characters/doremy",
        "ui/almanac/attribute_tags",
        "level/grids/broken_tile",
        "level/hp_bar_icons",
        "misc/red_dragon_and_byakuren",
    ];

    public static function main():Void {
        Sys.println('dataPath=${unity.Application.dataPath}');
        Sys.println('cwd=${Sys.getCwd()}');

        // ---------------- 清单加载 ----------------
        check(SpriteManifestLoader.load(), 'sprites_manifest.json 已加载'
            + (SpriteManifestLoader.loadError != null ? '（${SpriteManifestLoader.loadError}）' : ''));
        var data = SpriteManifestLoader.data;
        if (data == null) {
            report();
            return;
        }
        check(Lambda.count(data.sprites) >= 700, '精灵条目 ${Lambda.count(data.sprites)} >= 700');
        check(Lambda.count(data.spriteSheets) >= 200, '图集条目 ${Lambda.count(data.spriteSheets)} >= 200');
        check(Lambda.count(data.textures) >= 980, '贴图条目 ${Lambda.count(data.textures)} >= 980');
        check(data.resourceManifestLoaded, '贴图路径已接到 resource_manifest.json（解析 '
            + '${data.resourceManifestResolved} 条，回退 ${data.resourceManifestFallbacks.length} 条）');
        check(data.resourceManifestFallbacks.length == 0,
            '没有回退到清单内 assetPath 的条目（回退样例 ${data.resourceManifestFallbacks.slice(0, 3)}）');
        check(data.resourceManifestMismatches.length == 0,
            '两条清单的贴图路径一致（不一致 ${data.resourceManifestMismatches.length} 条）');

        var manifest = ResourceManifest.get();
        check(manifest.loaded && !manifest.usingFallbackIndex,
            'resource_manifest.json 已加载（条目 ${manifest.entryCount}）');

        // ---------------- 安装渲染钩子 ----------------
        SpriteFrameFactory.install();
        check(SpriteRenderer.spriteApplier != null, 'SpriteFrameFactory.install() 已装好 SpriteRenderer 钩子');

        // ---------------- 单帧精灵 ----------------
        var loadedSprites = 0;
        for (path in SPRITE_PATHS) {
            var def = SpriteManifestLoader.getSpriteDefinition(path);
            if (def == null) {
                note('清单里没有精灵 $path（跳过）');
                continue;
            }
            loadedSprites++;
            checkSprite(path, def);
        }
        check(loadedSprites >= 20, '实际检查了 $loadedSprites 个单帧精灵（>= 20）');

        // ---------------- 图集 ----------------
        var loadedSheets = 0;
        for (path in SHEET_PATHS) {
            var sheet = SpriteManifestLoader.getSpriteSheetDefinition(path);
            if (sheet == null) {
                note('清单里没有图集 $path（跳过）');
                continue;
            }
            loadedSheets++;
            checkSheet(path, sheet);
        }
        check(loadedSheets >= 8, '实际检查了 $loadedSheets 个图集（>= 8）');

        // ---------------- 贴图只解码一次 ----------------
        checkSingleDecode();

        // ---------------- 帧内容（真实像素） ----------------
        checkFramePixels();

        // ---------------- FlxSprite 接线 ----------------
        checkRendererWiring();

        // ---------------- 坐标系换算（纯函数） ----------------
        checkCoordinateMath();

        // ---------------- prefab 资产引用（guid[:fileID]）→ 精灵 ----------------
        checkAssetRefResolution();

        // ---------------- 游戏真实加载路径（ResourceManager.LoadSpriteManifest 的输入） ----------------
        checkSpriteManifestPipeline();

        // ---------------- 汇总 ----------------
        if (SpriteFrameFactory.failureCount > 0)
            note('SpriteFrameFactory 失败 ${SpriteFrameFactory.failureCount} 次，样例 ${SpriteFrameFactory.failureKeys.slice(0, 5)}');
        report();
    }

    // ------------------------------------------------------------------ 单帧精灵

    private static function checkSprite(path:String, def:SpriteDefinition):Void {
        var frame = SpriteFrameFactory.getFrameOfDefinition(def);
        if (frame == null) {
            check(false, '$path: 生成了 FlxFrame');
            return;
        }
        // 帧尺寸必须与清单的 rect 一致（rect 的 y 是 Unity 的左下角坐标）。
        check(Std.int(frame.frame.width) == Std.int(def.rect.width)
            && Std.int(frame.frame.height) == Std.int(def.rect.height),
            '$path: 帧尺寸 ${Std.int(frame.frame.width)}x${Std.int(frame.frame.height)} == 清单 '
            + '${Std.int(def.rect.width)}x${Std.int(def.rect.height)}');

        // Unity rect（左下角原点）→ Flixel（左上角原点）的 y 换算。
        var size = SpriteFrameFactory.getPixelSize(def.texture == null ? null
            : SpriteManifestLoader.getUnityTexture(def.texture, def.assetPath));
        var expectedY = Std.int(size.height - def.rect.y - def.rect.height + 0.5);
        check(Std.int(frame.frame.y) == expectedY,
            '$path: 帧 y=${Std.int(frame.frame.y)} == ${expectedY}（贴图高 ${size.height}，Unity y=${def.rect.y}）');

        // 帧必须落在贴图范围内。
        check(frame.frame.x >= 0 && frame.frame.y >= 0
            && frame.frame.right <= size.width && frame.frame.bottom <= size.height,
            '$path: 帧 ${frame.frame} 在贴图 ${size.width}x${size.height} 范围内');

        // 贴图像素尺寸与清单声明一致。
        if (def.texture != null) {
            check(size.width == def.texture.width && size.height == def.texture.height,
                '$path: 解码尺寸 ${size.width}x${size.height} == 清单 ${def.texture.width}x${def.texture.height}');
        }

        // pivot → origin。
        var origin = SpriteFrameFactory.toOrigin(def.pivot,
            Std.int(frame.frame.width), Std.int(frame.frame.height));
        check(Math.abs(origin.x - def.pivot.x * frame.frame.width) < 0.01
            && Math.abs(origin.y - (1 - def.pivot.y) * frame.frame.height) < 0.01,
            '$path: origin=(${origin.x},${origin.y}) 与 pivot=(${def.pivot.x},${def.pivot.y}) 一致');

        // FlxImageFrame 可用（可直接赋给 FlxSprite.frames）。
        var imageFrame = SpriteFrameFactory.getImageFrameOfDefinition(def);
        check(imageFrame != null && imageFrame.frames.length == 1 && imageFrame.frame == frame,
            '$path: 单帧集合可用（frames=${imageFrame == null ? -1 : imageFrame.frames.length}）');
    }

    // ------------------------------------------------------------------ 图集

    private static function checkSheet(path:String, sheet:SpriteSheetDefinition):Void {
        var atlas = SpriteFrameFactory.getAtlasFrames(sheet);
        if (atlas == null) {
            check(false, '$path: 生成了 FlxAtlasFrames');
            return;
        }
        check(atlas.frames.length == sheet.slices.length,
            '$path: 帧数 ${atlas.frames.length} == slices ${sheet.slices.length}');

        var size = SpriteFrameFactory.getPixelSize(
            SpriteManifestLoader.getUnityTexture(sheet.texture, sheet.assetPath));
        var mismatched = 0;
        var wrongY = 0;
        var outOfBounds = 0;
        for (i in 0...sheet.slices.length) {
            var slice = sheet.slices[i];
            var frame = atlas.frames[i];
            if (Std.int(frame.frame.width) != Std.int(slice.rect.width)
                || Std.int(frame.frame.height) != Std.int(slice.rect.height))
                mismatched++;
            var expectedY = Std.int(size.height - slice.rect.y - slice.rect.height + 0.5);
            if (Std.int(frame.frame.y) != expectedY)
                wrongY++;
            if (frame.frame.x < 0 || frame.frame.y < 0
                || frame.frame.right > size.width || frame.frame.bottom > size.height)
                outOfBounds++;
        }
        check(mismatched == 0, '$path: 全部 ${sheet.slices.length} 帧尺寸与清单一致（不一致 $mismatched）');
        check(wrongY == 0, '$path: 全部帧的 y 换算正确（错误 $wrongY）');
        check(outOfBounds == 0, '$path: 全部帧在贴图范围内（越界 $outOfBounds）');

        // 名字表可用（animation.addByPrefix 依赖它）。
        var named = 0;
        for (i in 0...sheet.slices.length) {
            var slice = sheet.slices[i];
            if (slice.name != null && atlas.exists(slice.name))
                named++;
        }
        check(named == sheet.slices.length, '$path: 全部帧可按名取用（$named/${sheet.slices.length}）');

        // 按名取到的帧与按下标取到的帧是同一帧。
        if (sheet.slices.length > 0 && sheet.slices[0].name != null) {
            check(atlas.getByName(sheet.slices[0].name) == atlas.frames[0],
                '$path: getByName("${sheet.slices[0].name}") == frames[0]');
        }

        // 单帧 FlxSprite 可用。
        var flx = SpriteFrameFactory.createSheetFlxSprite(sheet, 0);
        check(flx != null && flx.frameWidth == Std.int(sheet.slices[0].rect.width)
            && flx.frameHeight == Std.int(sheet.slices[0].rect.height),
            '$path: createSheetFlxSprite(0) 的 frameWidth/Height = '
            + '${flx == null ? "null" : '${flx.frameWidth}x${flx.frameHeight}'}');
    }

    // ------------------------------------------------------- 贴图只解码一次

    private static function checkSingleDecode():Void {
        var path = "ui/level/final_wave";
        var def = SpriteManifestLoader.getSpriteDefinition(path);
        if (def == null) {
            note('跳过单次解码检查（$path 不在清单里）');
            return;
        }
        // 1) 先让 ResourceManifest 解一遍。
        var graphic = ResourceManifest.get().loadImageByPath(def.assetPath);
        check(Std.isOfType(graphic, FlxGraphic), '$path: ResourceManifest.loadImageByPath → FlxGraphic');
        var first:FlxGraphic = cast graphic;
        check(first != null && first.bitmap != null
            && first.bitmap.width == def.texture.width && first.bitmap.height == def.texture.height,
            '$path: 解码尺寸 ${first == null ? "null" : '${first.bitmap.width}x${first.bitmap.height}'}');

        // 2) 再走 SpriteTextureCache —— 必须复用同一个 FlxGraphic 的位图（不再解一遍）。
        var texture = SpriteManifestLoader.getUnityTexture(def.texture, def.assetPath);
        check(texture != null, '$path: SpriteTextureCache.getTexture 返回贴图');
        check(texture != null && texture.graphic == first,
            '$path: 贴图复用 ResourceManifest 的 FlxGraphic（同一实例）');
        var bitmap = SpriteTextureCache.getBitmapData(texture);
        check(bitmap == first.bitmap, '$path: BitmapData 与 FlxGraphic.bitmap 是同一实例（未重复解码）');

        // 3) 反向：先走 SpriteTextureCache 的另一张图，再走 ResourceManifest，也必须同一实例。
        var other = SpriteManifestLoader.getSpriteDefinition("level/hp_bar");
        if (other != null) {
            var t2 = SpriteManifestLoader.getUnityTexture(other.texture, other.assetPath);
            var g2 = ResourceManifest.get().loadImageByPath(other.assetPath);
            check(t2 != null && t2.graphic == g2, 'level/hp_bar: 两条路径拿到同一个 FlxGraphic');
        }

        // 4) 反复取值不产生新解码。
        var before = SpriteFrameFactory.decodeCount;
        for (i in 0...20) {
            SpriteManifestLoader.getUnityTexture(def.texture, def.assetPath);
            ResourceManifest.get().loadImageByPath(def.assetPath);
        }
        check(SpriteFrameFactory.decodeCount == before,
            '$path: 重复取值 20 次未新增解码（decodeCount ${before} → ${SpriteFrameFactory.decodeCount}）');
    }

    // ----------------------------------------------------- 帧内容（真实像素）

    private static function checkFramePixels():Void {
        // 单帧精灵：整图 → 帧矩形等于整图，帧像素应等于 FlxGraphic 位图本身。
        var def = SpriteManifestLoader.getSpriteDefinition("ui/close");
        if (def != null) {
            var texture = SpriteManifestLoader.getUnityTexture(def.texture, def.assetPath);
            var graphic = SpriteFrameFactory.getGraphic(texture);
            var frame = SpriteFrameFactory.getFrameOfDefinition(def);
            if (graphic != null && frame != null) {
                var painted = frame.paint();
                check(painted != null && painted.width == graphic.bitmap.width
                    && painted.height == graphic.bitmap.height,
                    'ui/close: frame.paint() 尺寸 ${painted == null ? "null" : '${painted.width}x${painted.height}'}'
                    + ' == 贴图 ${graphic.bitmap.width}x${graphic.bitmap.height}');
                // 逐像素抽样对比：帧内容必须与位图对应区域一致（证明 y 换算没有翻转错）。
                check(samePixels(painted, graphic.bitmap, 0, 0),
                    'ui/close: 帧像素与贴图像素一致（左上角对齐）');
            }
        } else {
            note('跳过 ui/close 的像素检查（不在清单里）');
        }

        // 图集切片：帧像素应等于位图对应区域（含 Unity y 翻转）。
        var sheet = SpriteManifestLoader.getSpriteSheetDefinition("entity/armor/leather_cap");
        if (sheet != null && sheet.slices.length > 0) {
            var slice = sheet.slices[0];
            var texture = SpriteManifestLoader.getUnityTexture(sheet.texture, sheet.assetPath);
            var graphic = SpriteFrameFactory.getGraphic(texture);
            var frame = SpriteFrameFactory.getSheetFrame(sheet, 0);
            if (graphic != null && frame != null) {
                var painted = frame.paint();
                check(painted != null && painted.width == Std.int(slice.rect.width)
                    && painted.height == Std.int(slice.rect.height),
                    'entity/armor/leather_cap[0]: paint() 尺寸 ${painted == null ? "null" : '${painted.width}x${painted.height}'}');
                var expectedX = Std.int(slice.rect.x + 0.5);
                var expectedY = Std.int(graphic.bitmap.height - slice.rect.y - slice.rect.height + 0.5);
                check(samePixels(painted, graphic.bitmap, expectedX, expectedY),
                    'entity/armor/leather_cap[0]: 帧像素 == 位图 ($expectedX,$expectedY) 起的区域（y 翻转正确）');
            }
        } else {
            note('跳过 leather_cap 的像素检查');
        }
    }

    /// 对比 src 从 (x,y) 起的矩形与 dst 是否逐像素相同（抽样：每个像素都看，位图不大）。
    private static function samePixels(src:BitmapData, dst:BitmapData, x:Int, y:Int):Bool {
        if (src == null || dst == null)
            return false;
        if (x < 0 || y < 0 || x + src.width > dst.width || y + src.height > dst.height)
            return false;
        for (iy in 0...src.height) {
            for (ix in 0...src.width) {
                if (src.getPixel32(ix, iy) != dst.getPixel32(x + ix, y + iy))
                    return false;
            }
        }
        return true;
    }

    // -------------------------------------------------------- FlxSprite 接线

    private static function checkRendererWiring():Void {
        var def = SpriteManifestLoader.getSpriteDefinition("level/castle/castle");
        if (def == null) {
            note('跳过渲染器接线检查（level/castle/castle 不在清单里）');
            return;
        }
        var sprite:Sprite = SpriteManifestLoader.createSprite(def);
        var renderer = new SpriteRenderer();
        renderer.sprite = sprite;
        check(renderer.renderSprite != null, 'level/castle/castle: 赋值 unity.Sprite 后生成了 renderSprite');
        if (renderer.renderSprite != null) {
            check(renderer.renderSprite.frameWidth == Std.int(def.rect.width)
                && renderer.renderSprite.frameHeight == Std.int(def.rect.height),
                'level/castle/castle: renderSprite 帧尺寸 '
                + '${renderer.renderSprite.frameWidth}x${renderer.renderSprite.frameHeight}');
            // alignment=6 (BottomLeft) → pivot (0,0) → Flixel origin (0, height)。
            check(Math.abs(renderer.renderSprite.origin.x - def.pivot.x * def.rect.width) < 0.01
                && Math.abs(renderer.renderSprite.origin.y - (1 - def.pivot.y) * def.rect.height) < 0.01,
                'level/castle/castle: origin=(${renderer.renderSprite.origin.x},${renderer.renderSprite.origin.y})'
                + ' 与 pivot=(${def.pivot.x},${def.pivot.y}) 一致');
            check(renderer.renderSprite.graphic != null, 'level/castle/castle: renderSprite 有 graphic');
        }

        // 换精灵：同一个渲染器连续赋两个不同的 unity.Sprite，帧必须跟着变。
        var def2 = SpriteManifestLoader.getSpriteDefinition("level/palace/palace");
        if (def2 != null && renderer.renderSprite != null) {
            renderer.sprite = SpriteManifestLoader.createSprite(def2);
            check(renderer.renderSprite.frameWidth == Std.int(def2.rect.width),
                'level/palace/palace: 换精灵后帧宽变为 ${renderer.renderSprite.frameWidth}');
        }

        // FlxSprite 直接写入 sprite 字段（ModelPrefabAssets 的既有用法）必须保持可用。
        var flx = new FlxSprite();
        var renderer2 = new SpriteRenderer(flx);
        check(renderer2.renderSprite == flx, 'new SpriteRenderer(flxSprite) 的 renderSprite 就是它本身');
        check(renderer2.sprite == flx, 'new SpriteRenderer(flxSprite).sprite == flxSprite');

        // createFlxSprite 便捷入口。
        var created = SpriteFrameFactory.createFlxSprite(sprite);
        check(created != null && created.frameWidth == Std.int(def.rect.width),
            'createFlxSprite 直接得到可用 FlxSprite');

        // 未赋精灵时不应崩溃。
        var renderer3 = new SpriteRenderer();
        renderer3.sprite = null;
        check(true, '赋 null 精灵不抛异常');
        renderer3.flipX = true;
        renderer3.alpha = 0.5;
        renderer3.color = new unity.Color(1, 0, 0, 1);
        check(true, '未接线时读写 flipX/alpha/color 不抛异常');
    }

    // -------------------------------------------------------- 坐标系换算

    private static function checkCoordinateMath():Void {
        // Unity rect (0,0,10,20) 在 100 高的贴图里 → Flixel (0, 80, 10, 20)。
        var rect = SpriteFrameFactory.toFlixelRect(new unity.Rect(0, 0, 10, 20), 100, 100);
        check(rect != null && rect.x == 0 && rect.y == 80 && rect.width == 10 && rect.height == 20,
            'toFlixelRect((0,0,10,20), h=100) = $rect');

        // 贴图顶部的矩形：Unity y=80,h=20 → Flixel y=0。
        var top = SpriteFrameFactory.toFlixelRect(new unity.Rect(5, 80, 10, 20), 100, 100);
        check(top != null && top.x == 5 && top.y == 0, 'toFlixelRect((5,80,10,20), h=100) = $top');

        // 越界矩形被夹取（不能超出贴图）。
        var clamped = SpriteFrameFactory.toFlixelRect(new unity.Rect(95, 0, 20, 20), 100, 100);
        check(clamped != null && clamped.x == 95 && clamped.width == 5,
            'toFlixelRect 越界被夹取：$clamped');

        // 空矩形返回 null。
        check(SpriteFrameFactory.toFlixelRect(new unity.Rect(0, 0, 0, 0), 100, 100) == null,
            'toFlixelRect(0 尺寸) == null');

        // pivot → origin：三种对齐。
        var center = SpriteFrameFactory.toOrigin(new unity.Vector2(0.5, 0.5), 40, 20);
        check(center.x == 20 && center.y == 10, 'origin(0.5,0.5, 40x20) = (${center.x},${center.y})');
        var bottomLeft = SpriteFrameFactory.toOrigin(new unity.Vector2(0, 0), 40, 20);
        check(bottomLeft.x == 0 && bottomLeft.y == 20, 'origin(0,0, 40x20) = (${bottomLeft.x},${bottomLeft.y})');
        var topRight = SpriteFrameFactory.toOrigin(new unity.Vector2(1, 1), 40, 20);
        check(topRight.x == 40 && topRight.y == 0, 'origin(1,1, 40x20) = (${topRight.x},${topRight.y})');
    }

    // ------------------------------------------- prefab 资产引用 → 精灵

    /// 复刻 `Assets/GameContent/Assets/mvz2/models/armor/leather_cap.prefab` 里的
    /// `m_Sprite: {fileID: -528585260921630623, guid: 03832b8b573fa884993ba7232246622f}`
    /// —— 图集里的第 0 帧（内部 id 与 spriteSheets[].slices[0].internalID 一致）。
    private static function checkAssetRefResolution():Void {
        var sheet = SpriteManifestLoader.getSpriteSheetDefinition("entity/armor/leather_cap");
        if (sheet == null || sheet.slices.length == 0) {
            note('跳过 prefab 资产引用检查（entity/armor/leather_cap 不在清单里）');
            return;
        }
        var slice = sheet.slices[0];
        var definition = SpriteManifestLoader.getSpriteDefinitionByAssetRef(sheet.textureGuid, slice.internalIDString);
        check(definition != null, 'guid+fileID 解析到单帧精灵（guid=${sheet.textureGuid} fileID=${slice.internalIDString}）');
        if (definition != null) {
            check(definition.rect.width == slice.rect.width && definition.rect.height == slice.rect.height
                && definition.rect.y == slice.rect.y,
                '解析出的单帧矩形与切片一致（${definition.rect.width}x${definition.rect.height} @y=${definition.rect.y}）');
            var frame = SpriteFrameFactory.getFrameOfDefinition(definition);
            check(frame != null && Std.int(frame.frame.width) == Std.int(slice.rect.width),
                '按资产引用解析出的精灵能生成帧（${frame == null ? "null" : '${Std.int(frame.frame.width)}x${Std.int(frame.frame.height)}'}）');
        }

        // 主资产 fileID（21300000）→ 整图单帧。
        var whole = SpriteManifestLoader.getSpriteDefinitionByAssetRef(sheet.textureGuid, "21300000");
        check(whole != null && Std.int(whole.rect.width) == sheet.texture.width,
            'fileID=21300000 解析为整图单帧（${whole == null ? "null" : '${Std.int(whole.rect.width)}x${Std.int(whole.rect.height)}'}）');

        // 单帧精灵的 guid（无 fileID）→ 该精灵本身。
        var def = SpriteManifestLoader.getSpriteDefinition("ui/close");
        if (def != null) {
            var byGuid = SpriteManifestLoader.getSpriteDefinitionByAssetRef(def.textureGuid, null);
            check(byGuid != null && byGuid.textureGuid == def.textureGuid,
                'ui/close 的贴图 guid 解析到对应单帧精灵（${byGuid == null ? "null" : byGuid.path}）');
        }

        // 未知 guid → null，不抛异常。
        check(SpriteManifestLoader.getSpriteDefinitionByAssetRef("ffffffffffffffffffffffffffffffff", "1") == null,
            '未知 guid 返回 null');
        check(SpriteManifestLoader.getSpriteDefinitionByAssetRef(null, null) == null, 'null guid 返回 null');

        // ModelPrefabAssets 的解析路径（prefab 里 image 引用 → unity.Sprite）。
        var ref:ModelPrefabAssetRef = {
            guid: sheet.textureGuid,
            fileID: slice.internalIDString,
            path: sheet.assetPath,
            address: sheet.id,
            kind: "Image"
        };
        var resolved = mvz2.models.ModelPrefabAssets.Resolve(ref);
        check(Std.isOfType(resolved, Sprite),
            'ModelPrefabAssets.Resolve(image 引用) → unity.Sprite（实际 ${resolved == null ? "null" : Type.getClassName(Type.getClass(resolved))}）');
        if (Std.isOfType(resolved, Sprite)) {
            var renderer = new SpriteRenderer();
            renderer.sprite = resolved;
            check(renderer.renderSprite != null && renderer.renderSprite.frameWidth == Std.int(slice.rect.width),
                '把解析结果交给 SpriteRenderer 后帧宽 = ${renderer.renderSprite == null ? "null" : Std.string(renderer.renderSprite.frameWidth)}（期望 ${Std.int(slice.rect.width)}）');
        }
    }

    // --------------------------- 游戏真实加载路径（createSpriteManifests） ---------------------------

    /// `ResourceManager.LoadInitSpriteManifests` / `LoadMainSpriteManifests` 通过
    /// `SpriteManifestLoader.createSpriteManifests(labels)` 拿到等价的 SpriteManifest 资产，
    /// 再逐个 `createSprite` 填进 `ModResource.Sprites`。这里校验这条真实链路产出的
    /// unity.Sprite 能正常取帧（否则游戏里拿到的 Sprites 表是「有对象但画不出来」）。
    private static function checkSpriteManifestPipeline():Void {
        var manifests = SpriteManifestLoader.createSpriteManifests(["Main", "SpriteManifest"]);
        check(manifests.length >= 1, 'createSpriteManifests(["Main","SpriteManifest"]) 产出 ${manifests.length} 个 manifest');
        if (manifests.length == 0) {
            report();
            return;
        }
        var manifest = manifests[0];
        // PORT-NOTE: "Main"+"SpriteManifest" 这个清单本身有 692 条单帧精灵（其余 17 条带
        // "Init" 标签，走 LoadInitSpriteManifests 那条路），合计 709。
        check(manifest.spriteEntries.length >= 690,
            'manifest 里的单帧精灵条目 ${manifest.spriteEntries.length} >= 690');
        check(manifest.spritesheetEntries.length >= 200,
            'manifest 里的图集条目 ${manifest.spritesheetEntries.length} >= 200');

        var initManifests = SpriteManifestLoader.createSpriteManifests(["Init", "SpriteManifest"]);
        var initSprites = initManifests.length == 0 ? 0 : initManifests[0].spriteEntries.length;
        check(initSprites >= 10, '["Init","SpriteManifest"] 清单的单帧精灵条目 $initSprites >= 10');
        check(manifest.spriteEntries.length + initSprites >= 700,
            '两条清单合计单帧精灵 ${manifest.spriteEntries.length + initSprites} >= 700（== 清单总数）');

        // 随机抽样 30 个条目：每个都要能取到帧，且帧尺寸等于该精灵的 rect。
        var sampleCount = 0;
        var bad = 0;
        var step = Std.int(manifest.spriteEntries.length / 30);
        if (step < 1) step = 1;
        var i = 0;
        while (i < manifest.spriteEntries.length && sampleCount < 30) {
            var entry = manifest.spriteEntries[i];
            sampleCount++;
            if (entry.sprite == null || SpriteFrameFactory.getFrame(entry.sprite) == null) {
                bad++;
                if (bad <= 5)
                    note('manifest 条目取帧失败：${entry.name}');
            } else {
                var frame = SpriteFrameFactory.getFrame(entry.sprite);
                if (Std.int(frame.frame.width) != Std.int(entry.sprite.rect.width))
                    bad++;
            }
            i += step;
        }
        check(bad == 0, '抽样 $sampleCount 个 manifest 单帧条目全部可取帧（失败 $bad）');

        // 图集条目：每个条目是 Sprite[]，逐帧可查。
        var sheetEntries = 0;
        var sheetBad = 0;
        for (entry in manifest.spritesheetEntries) {
            sheetEntries++;
            if (entry.spritesheet == null || entry.spritesheet.length == 0) {
                sheetBad++;
                continue;
            }
            for (sprite in entry.spritesheet) {
                if (SpriteFrameFactory.getFrame(sprite) == null)
                    sheetBad++;
            }
        }
        check(sheetBad == 0, '全部 $sheetEntries 个图集条目的每一帧都可取帧（失败 $sheetBad）');
    }

    // ------------------------------------------------------------------ 汇总

    private static function report():Void {
        Sys.println('--------------------------------------------');
        Sys.println('检查项 $checks，失败 ${failures.length}，说明 $notes');
        for (f in failures)
            Sys.println('  FAIL ' + f);
        if (failures.length == 0)
            Sys.println('[sprites] 全部通过');
        Sys.exit(failures.length == 0 ? 0 : 1);
    }

    private static function check(condition:Bool, message:String):Void {
        checks++;
        if (condition) {
            Sys.println('[ ok ] ' + message);
        } else {
            Sys.println('[FAIL] ' + message);
            failures.push(message);
        }
    }

    private static function note(message:String):Void {
        notes++;
        Sys.println('[note] ' + message);
    }
}
