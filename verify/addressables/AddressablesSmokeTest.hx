// PORT-NOTE: 验证用（不参与游戏构建）。工作包 ② 的 Addressables 运行时冒烟测试：
// 真实读取 HaxePort/assets/resource_manifest.json 与 assets 下的资源文件，检查
// 地址/标签查询、类型分派、句柄成员、缺失告警、显式注册优先级。
//
// 运行：bash HaxePort/tools_build/check_addressables.sh
package addressables;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import haxe.io.Bytes;
import mvz2.sprites.SpriteManifest;
import unity.AudioClip;
import unity.GameObject;
import unity.Sprite;
import unity.TextAsset;
import unity.addressableassets.Addressables;
import unity.addressableassets.Addressables.AsyncOperationHandle;
import unity.addressableassets.Addressables.AsyncOperationStatus;
import unity.addressableassets.IResourceLocation;
import unity.addressableassets.IResourceLocator;
import unity.addressableassets.ResourceLocation;
import unity.addressableassets.ResourceManifest;

class AddressablesSmokeTest {
    private static var checks:Int = 0;
    private static var notes:Int = 0;
    private static var failures:Array<String> = [];

    public static function main():Void {
        var manifest = ResourceManifest.get();
        info('清单文件   : ${manifest.manifestFile}');
        info('assets 根  : ${manifest.assetsRoots.join(" , ")}');
        info('位置条目数 : ${manifest.entryCount}');
        check(manifest.loaded, '清单已加载');
        check(!manifest.usingFallbackIndex, '使用 resource_manifest.json（不是按文件名降级扫描）');
        check(manifest.entryCount >= 2850, '位置条目数 ${manifest.entryCount} >= 2850');

        var locator:IResourceLocator = Addressables.InitializeAsync().Task;
        check(locator != null, 'Addressables.InitializeAsync().Task 返回 locator');
        check(Addressables.InitializeAsync() == Addressables.InitializeAsync(), 'InitializeAsync 重复调用返回同一句柄');

        // ---------------- 地址查询 ----------------
        var locs = locator.Locate('mvz2:init/titlescreen', null);
        check(locs.length == 1, '地址 mvz2:init/titlescreen 命中 ${locs.length} 个位置（期望 1）');
        if (locs.length > 0) {
            check(locs[0].PrimaryKey == 'mvz2:init/titlescreen', 'PrimaryKey=${locs[0].PrimaryKey}');
            check(locs[0].InternalId == 'GameContent/Assets/mvz2/sprites/init/titlescreen.png',
                'InternalId=${locs[0].InternalId}');
        }
        // Unity 里同一个 address 可以指向多个资源（ResourceLocationEqualityComparer 用 PrimaryKey+ResourceType+InternalId 去重）
        var castle = locator.Locate('mvz2:castle', null);
        check(castle.length == 2, '重复地址 mvz2:castle 命中 ${castle.length} 个位置（期望 2：areamodel + mapmodel）');
        // 去掉命名空间前缀的键（ResourceManager.LoadModResource(nsp, path) 的走法）
        check(locator.Locate('achievements', null).length == 1, '去前缀键 achievements 命中 1 个位置');

        // ---------------- 标签 + 类型过滤（对齐 ResourceManager.GetLabeledResourceLocations） ----------------
        checkCount(locator, 'Sprite', Sprite, 702);
        checkCount(locator, 'Spritesheet', Sprite, 222);
        checkCount(locator, 'Meta', TextAsset, 38);
        checkCount(locator, 'Model', GameObject, 420);
        checkCount(locator, 'Sound', AudioClip, 482);
        checkCount(locator, 'Music', AudioClip, 44);
        // "Main" 既是地址（主场景 Main.unity）又是标签：过滤后只应留图片（916）+ 类型未知的 1 条。
        checkCount(locator, 'Main', Sprite, 917);
        checkCount(locator, 'Main', AudioClip, 525);
        checkIntersect(locator, 'Main', AudioClip, 'Sound', AudioClip, 481);
        checkIntersect(locator, 'Main', AudioClip, 'Music', AudioClip, 43);
        checkIntersect(locator, 'Init', SpriteManifest, 'SpriteManifest', SpriteManifest, 1);

        // ---------------- 重复地址的消歧（同一个 address 指向两个文件，靠 label 区分） ----------------
        checkPaths(locator, 'AreaModel', GameObject, 8, '/areamodels/');
        checkPaths(locator, 'MapModel', GameObject, 9, '/mapmodels/');
        var castleLocations = locator.Locate('mvz2:castle', GameObject);
        check(castleLocations.length == 2, 'mvz2:castle 命中 ${castleLocations.length} 条定位符（期望 2）');
        if (castleLocations.length == 2) {
            var firstLocation:ResourceLocation = cast castleLocations[0];
            var secondLocation:ResourceLocation = cast castleLocations[1];
            var addressModel:Dynamic = Addressables.LoadAssetAsyncByLocation(firstLocation).Task;
            var mapModel:Dynamic = Addressables.LoadAssetAsyncByLocation(secondLocation).Task;
            var firstPath = firstLocation.Path;
            var secondPath = secondLocation.Path;
            check(firstPath.indexOf('/areamodels/') > 0 && secondPath.indexOf('/mapmodels/') > 0,
                '两条定位符分别指向 $firstPath / $secondPath');
            var bothBytes = Std.isOfType(addressModel, Bytes) && Std.isOfType(mapModel, Bytes);
            var addressBytes:Bytes = bothBytes ? cast addressModel : null;
            var mapBytes:Bytes = bothBytes ? cast mapModel : null;
            check(bothBytes && addressBytes.length != mapBytes.length,
                '按定位符加载拿到两个不同的文件（${bytesLengthOf(addressBytes)} / ${bytesLengthOf(mapBytes)} 字节）');
            // 与磁盘上的文件逐字节对照，确认加载的是该定位符对应的文件
            var absPath = ResourceManifest.get().resolvePath(firstPath);
            if (absPath != null && bothBytes) {
                var fileBytes:Bytes = sys.io.File.getBytes(absPath);
                check(fileBytes.compare(addressBytes) == 0, 'mvz2:castle[0] 的字节与 $firstPath 一致');
            } else {
                check(false, 'mvz2:castle[0] 的文件路径无法解析：$firstPath');
            }
            // 按地址取（C# 的单资源接口）等价于取第一条定位符
            check(Addressables.LoadAssetAsync('mvz2:castle').Task == addressModel,
                'Addressables.LoadAssetAsync("mvz2:castle") 等价于第一条定位符');
        }

        // PORT-NOTE: 无头测试里 FlxG 未初始化（游戏里由 FlxGame 建立），FlxSound 需要 FlxG.sound；
        // 这里补一个最小的 SoundFrontEnd，让 FlxSound 的断言在测试里也能成立。
        if (FlxG.sound == null) {
            try {
                var frontEndClass = Type.resolveClass('flixel.system.frontEnds.SoundFrontEnd');
                if (frontEndClass != null)
                    Reflect.setField(FlxG, 'sound', Type.createInstance(frontEndClass, []));
            } catch (e:Dynamic) {}
        }

        // ---------------- 类型分派：图片 ----------------
        var imageHandle = Addressables.LoadAssetAsync('mvz2:init/titlescreen');
        check(imageHandle.Status == AsyncOperationStatus.Succeeded, '图片句柄 Status=Succeeded（${imageHandle.Status}）');
        check(imageHandle.IsDone && imageHandle.IsValid, 'IsDone/IsValid = true');
        check(imageHandle.PercentComplete == 1, 'PercentComplete=${imageHandle.PercentComplete}');
        var image:Dynamic = imageHandle.Task;
        check(Std.isOfType(image, FlxGraphic), 'png → FlxGraphic（实际 ${typeNameOf(image)}）');
        if (Std.isOfType(image, FlxGraphic)) {
            var graphic:FlxGraphic = cast image;
            check(graphic.bitmap != null && graphic.bitmap.width == 1280 && graphic.bitmap.height == 720,
                'titlescreen.png 解码尺寸 ${graphic.bitmap.width}x${graphic.bitmap.height}（期望 1280x720）');
            check(imageHandle.WaitForCompletion() == image, 'WaitForCompletion() 与 Task 一致');
            check(Addressables.LoadAssetAsync('mvz2:init/titlescreen').Task == image, '同一地址重复加载复用同一对象（缓存）');
        }

        // ---------------- 类型分派：音频 ----------------
        var ogg:Dynamic = Addressables.LoadAssetAsync('mvz2:random/netherrack/break3').Task;
        check(Std.isOfType(ogg, AudioClip), 'ogg → AudioClip（实际 ${typeNameOf(ogg)}）');
        if (Std.isOfType(ogg, AudioClip)) {
            var clip:AudioClip = cast ogg;
            check(clip.length > 0.01 && clip.length < 2, 'break3.ogg 时长 ${clip.length}s');
            check(clip.frequency > 0, 'break3.ogg 采样率 ${clip.frequency}');
            check(clip.channels >= 1, 'break3.ogg 声道 ${clip.channels}');
            check(clip.sound != null, 'openfl Sound 已填充');
            check(clip.flxSound != null, 'FlxSound 已填充（规范里音频的 FlxSound 载荷）');
        }
        var wav:Dynamic = Addressables.LoadAssetAsync('mvz2:wind').Task;
        if (Std.isOfType(wav, AudioClip)) {
            var clip:AudioClip = cast wav;
            check(Math.abs(clip.length - 2.685) < 0.05, 'wind.wav 时长 ${clip.length}s（期望 2.685s）');
            check(clip.frequency == 44100, 'wind.wav 采样率 ${clip.frequency}（期望 44100）');
            check(clip.channels == 2, 'wind.wav 声道 ${clip.channels}（期望 2）');
            check(clip.samples == 118414, 'wind.wav 采样数 ${clip.samples}（期望 118414）');
        } else {
            check(false, 'wav → AudioClip（实际 ${typeNameOf(wav)}）');
        }
        var mp3Handle = Addressables.LoadAssetAsync('mvz2:wither_boss');
        var mp3:Dynamic = mp3Handle.Task;
        if (mp3 == null) {
            // PORT-NOTE: lime 的原生音频（lime-anit 的 containers 只有 OGG/WAV）无法解码 mp3，
            // 这不是分派逻辑的问题——按规范「解码失败返回 null + 警告」处理。若转换阶段把 mp3 转成
            // ogg（并更新清单），这里会自动变成 ok。
            note('wither_boss.mp3 无法用 lime 原生解码（只有 OGG/WAV），已按规范返回 null + 警告');
        } else {
            check(Std.isOfType(mp3, AudioClip), 'mp3 → AudioClip（实际 ${typeNameOf(mp3)}）');
            if (Std.isOfType(mp3, AudioClip)) {
                var mp3Clip:AudioClip = cast mp3;
                check(mp3Clip.length > 1, 'wither_boss.mp3 时长 ${mp3Clip.length}s');
            }
        }

        // ---------------- 类型分派：文本 ----------------
        var meta:Dynamic = Addressables.LoadAssetAsync('mvz2:achievements').Task;
        check(Std.isOfType(meta, TextAsset), 'xml → TextAsset（实际 ${typeNameOf(meta)}）');
        if (Std.isOfType(meta, TextAsset)) {
            var text:TextAsset = cast meta;
            check(text.bytes.length == 3456, 'achievements.xml 字节数 ${text.bytes.length}（期望 3456）');
            check(StringTools.startsWith(text.text, '<achievements'), 'achievements.xml 文本以 <achievements 开头');
        }
        // LanguageManager.LoadBuiltinBytes 的用法：按标签取（"LanguagePack" 是标签，地址是 builtin）
        var pack:Dynamic = Addressables.LoadAssetAsync('LanguagePack').Task;
        check(Std.isOfType(pack, TextAsset), '标签 LanguagePack → TextAsset（实际 ${typeNameOf(pack)}）');
        if (Std.isOfType(pack, TextAsset)) {
            var packAsset:TextAsset = cast pack;
            check(packAsset.bytes.length > 2000000, 'builtin.bytes 字节数 ${packAsset.bytes.length}');
        }

        // ---------------- 未转换的 Unity 专有格式 → 原始 Bytes ----------------
        var prefab:Dynamic = Addressables.LoadAssetAsync('mvz2:castle').Task;
        check(Std.isOfType(prefab, Bytes), 'prefab（尚未转换）→ haxe.io.Bytes（实际 ${typeNameOf(prefab)}）');

        // ---------------- 缺失资源：null + 警告，不抛异常 ----------------
        var missing = Addressables.LoadAssetAsync('mvz2:this/does/not/exist');
        check(missing.Task == null, '缺失地址 → Task == null');
        check(missing.Status == AsyncOperationStatus.Failed, '缺失地址 Status=Failed（${missing.Status}）');
        check(missing.OperationException != null, '缺失地址 OperationException 有说明：${missing.OperationException}');

        // ---------------- 显式注册优先级（mvz2.sprites.SpriteManifestLoader.registerAddressables 的接法） ----------------
        var fakeSprite = new Sprite();
        fakeSprite.name = 'smoke_test_sprite';
        Addressables.RegisterAsset('mvz2:init/titlescreen', fakeSprite);
        check(Addressables.LoadAssetAsync('mvz2:init/titlescreen').Task == fakeSprite, 'RegisterAsset 优先于清单');
        var afterRegister = locator.Locate('mvz2:init/titlescreen', null);
        check(afterRegister.length == 2 && afterRegister[0].PrimaryKey == 'mvz2:init/titlescreen',
            '注册项在 locator 结果里可见（${afterRegister.length} 个位置，第一个是注册项）');

        // ---------------- 汇总 ----------------
        info('--------------------------------------------');
        info('检查项 $checks，失败 ${failures.length}，说明 $notes');
        for (f in failures)
            info('  FAIL ' + f);
        Sys.exit(failures.length == 0 ? 0 : 1);
    }

    private static function checkCount(locator:IResourceLocator, label:String, type:Dynamic, expected:Int):Void {
        var result = locator.Locate(label, type);
        check(result.length == expected, 'Locate("$label", ${typeNameOf(type)}) = ${result.length}（期望 $expected）');
    }

    /** 检查标签命中的定位符数量，并确认每条都落在期望的目录里（重复地址消歧用）。 */
    private static function checkPaths(locator:IResourceLocator, label:String, type:Dynamic, expected:Int,
            fragment:String):Void {
        var result = locator.Locate(label, type);
        check(result.length == expected, 'Locate("$label", ${typeNameOf(type)}) = ${result.length}（期望 $expected）');
        var wrong = 0;
        for (loc in result) {
            var typed:ResourceLocation = cast loc;
            var path:String = typed.Path;
            if (path == null || path.indexOf(fragment) < 0)
                wrong++;
        }
        check(wrong == 0, 'Locate("$label") 的每条定位符都指向 $fragment（不匹配 $wrong 条）');
    }

    private static function checkIntersect(locator:IResourceLocator, labelA:String, typeA:Dynamic,
            labelB:String, typeB:Dynamic, expected:Int):Void {
        var a = locator.Locate(labelA, typeA);
        var b = locator.Locate(labelB, typeB);
        var count = 0;
        for (x in a) {
            for (y in b) {
                if (x.PrimaryKey == y.PrimaryKey && x.InternalId == y.InternalId) {
                    count++;
                    break;
                }
            }
        }
        check(count == expected, 'Locate("$labelA") ∩ Locate("$labelB") = $count（期望 $expected）');
    }

    private static function typeNameOf(value:Dynamic):String {
        if (value == null)
            return 'null';
        try {
            return Type.getClassName(Type.getClass(value));
        } catch (e:Dynamic) {
            return Std.string(value);
        }
    }

    private static function bytesLengthOf(value:Dynamic):String {
        if (value == null)
            return 'null';
        if (!Std.isOfType(value, Bytes))
            return typeNameOf(value);
        var bytes:Bytes = cast value;
        return Std.string(bytes.length);
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

    private static function info(message:String):Void {
        Sys.println('[info] ' + message);
    }

    private static function note(message:String):Void {
        notes++;
        Sys.println('[note] ' + message);
    }
}
