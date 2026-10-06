// Ported from: UnityEngine.AddressableAssets.Addressables（运行期资源目录的实现部分）
package unity.addressableassets;

import haxe.Json;
import haxe.io.Bytes;
import haxe.io.Path;
import lime.media.AudioBuffer;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;
import unity.AudioClip;
import unity.Debug;
import unity.TextAsset;

/**
 * 移植层的「Addressables 目录」。
 *
 * C# 侧 `Addressables.LoadAssetAsync<T>(address)` 由 Unity 的 catalog（AssetGroups → content catalog）
 * 解析地址；移植层没有 catalog，改为在首次使用时惰性读取资源转换阶段生成的清单
 * `HaxePort/assets/resource_manifest.json`（生成器：HaxePort/tools_build/build_manifest.py）：
 *
 *   { "version":1,
 *     "resourceRoot":"HaxePort/assets",          // 每条 path 相对于它
 *     "entries": [ { "address":"mvz2:init/titlescreen",
 *                    "path":"GameContent/Assets/mvz2/sprites/init/titlescreen.png",
 *                    "source":"Assets/GameContent/...", "labels":["Init","Sprite"],
 *                    "group":"init", "guid":"...", "kind":"Image", "exists":true }, ... ],
 *     "addresses": { "<address>": { path, type, kind, guid, group, labels } },
 *     "labelIndex": { "<label>": [[address, path, type], ...] },
 *     "folders": {...}, "groups": {...}, "missing":[...], "stats":{...} }
 *
 * 解析时先吃 `entries`（完整的位置表：Unity 里同一个 address 可以指向多个资源，例如
 * `mvz2:castle` 同时是 areamodel 与 mapmodel 的 prefab；这类重复只能靠 entries 的逐条 path 还原），
 * 再吃 `addresses` 补齐。为了兼容同样语义的其它写法，还接受：
 *   * `"entries": { "<address>": "<path>" | { path|file|output, labels, type|kind } }`
 *   * 顶层直接是 `{ "<address>": "<path>" }` 的平表
 *
 * 加载分派（对应 C# 的 `LoadAssetAsync<T>` 返回的 T）：
 *   Image  (png/jpg/...)  → flixel.graphics.FlxGraphic（BitmapData.fromBytes 解码）
 *   Audio  (ogg/wav/mp3)  → unity.AudioClip（内含 FlxSound / openfl Sound 与真实时长；mp3 见下）
 *   Text   (xml/json/txt/bytes/...) → unity.TextAsset（.text 即字符串，.bytes 为原始字节）
 *   Model  (prefab/fbx/...) → haxe.io.Bytes（Unity 专有格式尚未转换，属转换阶段的遗留）
 *   Font / 其它            → haxe.io.Bytes
 * 资源缺失或解码失败时返回 null 并 Debug.LogWarning，不抛异常。
 *
 * PORT-NOTE: 规范里「xml/json/txt → String」与「音频 → FlxSound」两处按 C# 消费代码收紧为
 * TextAsset / AudioClip：ResourceManager.LoadSingleMetaList 读 `resource.bytes`（TextAsset），
 * LanguageManager.LoadBuiltinBytes 读 `textAsset.bytes`，MusicManager 读 `mainTrackSource.clip.length`
 * （AudioClip）。FlxSound / openfl Sound 仍可从 `clip.flxSound` / `clip.sound` 取到。
 *
 * TODO-PORT: lime 的原生音频解码（lime-anit 的 media/containers 只有 OGG/WAV）不支持 mp3，
 * 工程里的 6 个 .mp3 音乐（mvz2:dream_level / minigame / nightmare_map / palace_boss / seija /
 * wither_boss）解码会失败并按规范返回 null + 警告。
 */
class ResourceManifest {
    // C#: Addressables.InitializeAsync() 之后由 catalog 提供的能力，移植层用清单文件替代。
    public static inline var MANIFEST_FILE:String = "resource_manifest.json";

    // ---------------- kind 常量与扩展名表 ----------------
    public static inline var KIND_IMAGE:String = "Image";
    public static inline var KIND_AUDIO:String = "Audio";
    public static inline var KIND_TEXT:String = "Text";
    public static inline var KIND_MODEL:String = "Model";
    public static inline var KIND_FONT:String = "Font";
    public static inline var KIND_OTHER:String = "Other";
    // 被 Addressables.RegisterAsset 显式注册过的地址（加载时由 Addressables 直接命中注册表）。
    public static inline var KIND_OVERRIDE:String = "Override";

    private static var IMAGE_TOKENS:Array<String> = ["image", "sprite", "spritesheet", "texture2d", "texture", "png", "jpg", "jpeg", "bmp", "gif", "tga", "psd", "tif", "tiff", "exr"];
    private static var AUDIO_TOKENS:Array<String> = ["audio", "audioclip", "sound", "music", "flxsound", "ogg", "wav", "mp3", "aiff", "aif", "m4a", "aac", "flac"];
    private static var TEXT_TOKENS:Array<String> = ["text", "textasset", "string", "xml", "json", "txt", "csv", "bytes", "po", "pot", "mo", "yml", "yaml"];
    private static var MODEL_TOKENS:Array<String> = ["model", "gameobject", "prefab", "fbx", "obj", "unity", "dae"];
    private static var FONT_TOKENS:Array<String> = ["font", "ttf", "otf"];

    // ---------------- 单例 ----------------
    private static var _instance:ResourceManifest;

    /** 惰性取得清单（首次调用时读取并建立索引）。 */
    public static function get():ResourceManifest {
        if (_instance == null) {
            _instance = new ResourceManifest();
            _instance.init();
        }
        return _instance;
    }

    /** 允许测试/工具指定 assets 根目录（不设时按 cwd / 可执行文件位置向上搜索）。 */
    public static var assetsRootOverride:String = null;

    // ---------------- 状态 ----------------
    public var loaded(default, null):Bool = false;
    public var manifestFile(default, null):String = null;
    public var assetsRoots(default, null):Array<String> = [];
    /** 清单里的 resourceRoot 字段（仓库相对路径，仅作记录/日志用）。 */
    public var resourceRoot(default, null):String = null;
    public var entryCount(default, null):Int = 0;
    public var skippedFolderCount(default, null):Int = 0;
    /** 清单缺失或解析失败时是否退化为扫描 assets 目录（会在日志里明确告警）。 */
    public var usingFallbackIndex(default, null):Bool = false;

    // 地址 → 位置列表。Unity 里一个 address 可以对应多条 IResourceLocation（见 addEntry 的说明）。
    private var addressIndex:Map<String, Array<ResourceLocation>> = new Map();
    private var labelIndex:Map<String, Array<ResourceLocation>> = new Map();
    // PORT-NOTE: 移植层新增。assets 相对路径 → 位置。精灵/图集清单只给出贴图的 assetPath
    //（`GameContent/Assets/.../x.png`），需要按路径直接取同一份解码结果（见 loadByPath），
    // 否则 SpriteTextureCache 会自己再解一遍，同一张 PNG 在内存里有两份 BitmapData。
    private var pathIndex:Map<String, ResourceLocation> = new Map();
    private var pathCache:Map<String, String> = new Map();
    private var loadedAssets:Map<String, Dynamic> = new Map();
    private var failedAssets:Map<String, Bool> = new Map();
    private var warnedKeys:Map<String, Bool> = new Map();
    private var fallbackPaths:Map<String, String> = null;
    private var fallbackNames:Map<String, String> = null;
    private var locator:ManifestResourceLocator = null;

    private function new() {}

    // #region 初始化
    private function init():Void {
        assetsRoots = findAssetRoots();
        manifestFile = findManifestFile(assetsRoots);
        if (manifestFile != null) {
            var ok = false;
            try {
                var text = File.getContent(manifestFile);
                var data:Dynamic = Json.parse(text);
                ingest(data);
                ok = true;
            } catch (e:Dynamic) {
                Debug.LogError('资源清单解析失败：$manifestFile（$e）');
            }
            if (!ok) buildFallbackIndex();
        } else {
            Debug.LogWarning('未找到资源清单 $MANIFEST_FILE（搜索根：${assetsRoots.join(", ")}），'
                + '退化为按文件名扫描 assets 目录：按地址加载仍可用，按标签（Label）加载不可用。');
            buildFallbackIndex();
        }
        if (usingFallbackIndex) {
            Debug.LogWarning('资源清单不可用，当前地址条目数=$entryCount（fallback 索引），标签索引用法将失效。');
        } else {
            Debug.Log('资源清单已加载：$manifestFile（条目=$entryCount，assets 根=${assetsRoots.join(", ")}）');
        }
        // PORT-NOTE: catalog 就绪后 Addressables.InitializeAsync() 返回的 locator。
        locator = new ManifestResourceLocator(this);
        loaded = true;
    }

    /** C#: Addressables.InitializeAsync().Task → IResourceLocator */
    public function getLocator():IResourceLocator {
        return locator;
    }
    // #endregion

    // #region 清单解析
    private function ingest(data:Dynamic):Void {
        if (data == null)
            return;
        resourceRoot = Reflect.field(data, "resourceRoot");
        // 先吃 entries（完整列表，保留同一地址指向不同文件的重复条目），再吃 addresses（按地址索引的表）。
        var entries:Dynamic = Reflect.field(data, "entries");
        if (entries != null && Std.isOfType(entries, Array)) {
            ingestEntryArray(cast entries);
        } else if (entries != null && Reflect.isObject(entries)) {
            ingestAddressMap(entries);
        }
        var addresses:Dynamic = Reflect.field(data, "addresses");
        if (addresses != null && Reflect.isObject(addresses)) {
            ingestAddressMap(addresses);
        }
        if (entryCount == 0) {
            if (Reflect.isObject(data) && Reflect.field(data, "version") == null && Reflect.field(data, "stats") == null) {
                // 顶层直接就是「地址 → 路径」的平表
                ingestAddressMap(data);
            } else {
                Debug.LogWarning('资源清单里没有 addresses/entries 字段，忽略。');
            }
        }
        var folders:Dynamic = Reflect.field(data, "folders");
        if (folders != null && Reflect.isObject(folders)) {
            for (f in Reflect.fields(folders))
                skippedFolderCount++;
        }
    }

    private function ingestAddressMap(map:Dynamic):Void {
        for (address in Reflect.fields(map)) {
            var value:Dynamic = Reflect.field(map, address);
            if (value == null)
                continue;
            if (Std.isOfType(value, String)) {
                addEntry(address, cast value, null, null, null, null, null, true);
            } else if (Reflect.isObject(value)) {
                addEntry(
                    address,
                    firstString(value, ["path", "file", "output", "assetPath", "target"]),
                    stringArray(Reflect.field(value, "labels")),
                    firstString(value, ["kind"]),
                    firstString(value, ["type"]),
                    firstString(value, ["group"]),
                    firstString(value, ["guid"]),
                    existsField(value)
                );
            }
        }
    }

    private function ingestEntryArray(entries:Array<Dynamic>):Void {
        for (e in entries) {
            if (e == null)
                continue;
            var address:String = firstString(e, ["address", "key", "name"]);
            if (address == null)
                continue;
            addEntry(
                address,
                firstString(e, ["path", "file", "output", "assetPath", "target"]),
                stringArray(Reflect.field(e, "labels")),
                firstString(e, ["kind"]),
                firstString(e, ["type"]),
                firstString(e, ["group"]),
                firstString(e, ["guid"]),
                existsField(e)
            );
        }
    }

    private function addEntry(address:String, path:String, labels:Array<String>, kind:String, type:String,
            group:String, guid:String, exists:Null<Bool>):Void {
        if (address == null || address == "")
            return;
        // PORT-NOTE: Unity 里同一个 address 可以指向多个资源（例如 mvz2:castle 同时是 areamodel 与
        // mapmodel；mvz2:day 同时是音乐与 areamodel），catalog 会为它保留多条 IResourceLocation，
        // 由标签查询区分。这里按「address + 路径」建位置，重复的地址因此保留多条位置。
        var list = addressIndex.get(address);
        if (list == null) {
            list = [];
            addressIndex.set(address, list);
        }
        var loc = findLocation(list, path);
        var newLabels:Array<String> = null;
        if (loc != null) {
            if (labels != null && labels.length > 0) {
                newLabels = [];
                for (l in labels) {
                    if (loc.Labels.indexOf(l) < 0) {
                        loc.Labels.push(l);
                        newLabels.push(l);
                    }
                }
            }
            if (loc.Kind == KIND_OTHER) {
                var better = normalizeKind(kind != null ? kind : type, path == null ? null : extensionOf(path));
                if (better != KIND_OTHER) {
                    loc.Kind = better;
                    loc.ResourceTypeName = unityTypeNameOf(better);
                    loc.ResourceType = loc.ResourceTypeName;
                }
            }
            if (!loc.Exists && exists == true)
                loc.Exists = true;
        } else {
            var ext = path == null ? null : extensionOf(path);
            var resolvedKind = normalizeKind(kind != null ? kind : type, ext);
            var typeName = unityTypeNameOf(resolvedKind);
            loc = new ResourceLocation(address, path, type != null ? type : ext, resolvedKind, typeName);
            loc.Labels = labels == null ? [] : labels.copy();
            loc.Group = group;
            loc.Guid = guid;
            loc.Exists = exists == null ? true : exists;
            list.push(loc);
            newLabels = loc.Labels;
            entryCount++;
            // PORT-NOTE: 按 assets 相对路径建立索引（同一路径只留第一条，用于 loadByPath）。
            if (path != null) {
                var norm = normalize(path);
                if (!pathIndex.exists(norm))
                    pathIndex.set(norm, loc);
            }
        }
        if (newLabels != null) {
            for (l in newLabels) {
                var labelList = labelIndex.get(l);
                if (labelList == null) {
                    labelList = [];
                    labelIndex.set(l, labelList);
                }
                labelList.push(loc);
            }
        }
        // PORT-NOTE: C# 的 mod 目录（IResourceLocator.Locate(path, t)）用的是去掉命名空间的资源路径
        // （ResourceManager.LoadModResource(nsp, path) → LoadAddressableResource(locator, path)），
        // 这里为 `namespace:path` 形式的地址补一个去掉前缀的查询键。
        var colon = address.indexOf(":");
        if (colon > 0 && colon < address.length - 1) {
            var stripped = address.substr(colon + 1);
            if (stripped != address) {
                var alias = addressIndex.get(stripped);
                if (alias == null) {
                    alias = [];
                    addressIndex.set(stripped, alias);
                }
                if (findLocation(alias, path) == null)
                    alias.push(loc);
            }
        }
    }

    private static function findLocation(list:Array<ResourceLocation>, path:String):ResourceLocation {
        // 没有路径信息（清单只给了地址）时按地址唯一处理。
        for (loc in list) {
            if (loc.Path == null || path == null) {
                if (loc.Path == path)
                    return loc;
            } else if (loc.Path == path) {
                return loc;
            }
        }
        return null;
    }

    /** 把清单里的 type/kind 归一化为加载分派用的 kind。 */
    private static function normalizeKind(token:String, fallbackToken:String):String {
        var kind = kindOfToken(token);
        if (kind == null)
            kind = kindOfToken(fallbackToken);
        return kind == null ? KIND_OTHER : kind;
    }

    private static function kindOfToken(token:String):String {
        if (token == null)
            return null;
        var t = token.toLowerCase();
        if (IMAGE_TOKENS.indexOf(t) >= 0) return KIND_IMAGE;
        if (AUDIO_TOKENS.indexOf(t) >= 0) return KIND_AUDIO;
        if (TEXT_TOKENS.indexOf(t) >= 0) return KIND_TEXT;
        if (MODEL_TOKENS.indexOf(t) >= 0) return KIND_MODEL;
        if (FONT_TOKENS.indexOf(t) >= 0) return KIND_FONT;
        return null;
    }

    private static function unityTypeNameOf(kind:String):String {
        return switch (kind) {
            case KIND_IMAGE: "UnityEngine.Sprite";
            case KIND_AUDIO: "UnityEngine.AudioClip";
            case KIND_TEXT: "UnityEngine.TextAsset";
            case KIND_MODEL: "UnityEngine.GameObject";
            case KIND_FONT: "UnityEngine.Font";
            default: "System.Object";
        }
    }
    // #endregion

    // #region 查询（IResourceLocator 的实现）
    /** C#: IResourceLocator.Locate(key, type, out locations) → 命中的位置列表（空表表示未命中）。 */
    public function locate(key:String, type:Dynamic):Array<IResourceLocation> {
        var result:Array<IResourceLocation> = [];
        if (key == null)
            return result;
        // PORT-NOTE: Unity 的 ContentCatalogData 把「地址」与「标签」放在同一张位置表里，同一个 key
        // 可能两者都命中（例如 "Main" 既是主场景的地址，又是 Main 组的标签），命中结果要合并。
        var direct = addressIndex.get(key);
        if (direct != null) {
            for (loc in direct)
                result.push(loc);
        }
        var byLabel = labelIndex.get(key);
        if (byLabel != null) {
            for (l in byLabel) {
                var duplicated = false;
                for (r in result) {
                    if (r == l) {
                        duplicated = true;
                        break;
                    }
                }
                if (!duplicated)
                    result.push(l);
            }
        }
        if (result.length == 0 && usingFallbackIndex) {
            var fb = locateFallback(key);
            if (fb != null)
                result.push(fb);
        }
        if (result.length == 0)
            return result;
        // C# 的 Locate(key, type) 会按类型过滤（Locate("Main", typeof(Sprite))）；
        // 清单里类型未知（Kind=Other）的条目不过滤，避免误杀尚未转换的资源。
        var category = kindOfRequestedType(type);
        if (category == null)
            return result;
        var filtered:Array<IResourceLocation> = [];
        for (loc in result) {
            var kind = cast(loc, ResourceLocation).Kind;
            if (kind == null || kind == KIND_OTHER || kind == KIND_OVERRIDE || kind == category)
                filtered.push(loc);
        }
        if (filtered.length == 0) {
            warnOnce('locate:' + key + ':' + category,
                '按类型（$category）过滤后没有命中 $key，退回未过滤的结果（清单里的类型可能不准确）。');
            return result;
        }
        return filtered;
    }

    /** 取单个位置（对应 C# 的 `Locate(key, type, out locs) → locs.FirstOrDefault()`）。 */
    public function locateFirst(key:String, ?type:Dynamic):ResourceLocation {
        var locs = locate(key, type);
        if (locs.length == 0)
            return null;
        return cast locs[0];
    }

    private static function kindOfRequestedType(type:Dynamic):String {
        if (type == null)
            return null;
        var name:String = null;
        try {
            name = Type.getClassName(cast type);
        } catch (e:Dynamic) {
            name = null;
        }
        if (name == null)
            return null;
        var short = name.split(".").pop();
        return switch (short) {
            case "Sprite", "Texture2D", "Texture", "BitmapData", "FlxGraphic", "SpriteRenderer", "SpriteSheet": KIND_IMAGE;
            case "AudioClip", "FlxSound", "Sound", "AudioBuffer", "AudioSource": KIND_AUDIO;
            case "TextAsset", "Xml", "XmlDocument": KIND_TEXT;
            case "GameObject", "Model", "MapModel", "AreaModel": KIND_MODEL;
            default: null;
        }
    }

    /** 显式注册（Addressables.RegisterAsset）的地址在目录里也要可见，且优先于清单条目。 */
    public function registerOverride(key:String):Void {
        if (key == null)
            return;
        var list = addressIndex.get(key);
        if (list == null) {
            list = [];
            addressIndex.set(key, list);
        }
        for (loc in list) {
            if (loc.Kind == KIND_OVERRIDE)
                return;
        }
        list.unshift(new ResourceLocation(key, null, null, KIND_OVERRIDE, "System.Object"));
    }

    public function addKeysTo(target:Array<Dynamic>):Void {
        for (key in addressIndex.keys())
            target.push(key);
    }
    // #endregion

    // #region 加载
    /** 按定位符加载资源；结果按资源路径缓存（等价于 Unity 的句柄缓存）。失败返回 null。 */
    public function load(loc:ResourceLocation):Dynamic {
        if (loc == null)
            return null;
        // PORT-NOTE: 同一个地址可能对应多条位置（不同文件），缓存必须按文件而不是按地址。
        var key = loc.Path != null ? loc.Path : loc.PrimaryKey;
        if (loadedAssets.exists(key))
            return loadedAssets.get(key);
        if (failedAssets.exists(key))
            return null;
        var asset = doLoad(loc);
        if (asset == null) {
            // 失败结果不再重复反序列化/读盘。
            failedAssets.set(key, true);
            return null;
        }
        loadedAssets.set(key, asset);
        return asset;
    }

    private function doLoad(loc:ResourceLocation):Dynamic {
        if (loc.Kind == KIND_OVERRIDE) {
            // 显式注册的资源（Addressables.RegisterAsset）由注册表提供。
            // PORT-NOTE: 正常路径不会走到这里（Addressables.LoadAssetAsync 先查注册表），
            // 这里是为了让直接调用 ResourceManifest.load 的代码也有同样的语义。
            return Addressables.assets.get(loc.PrimaryKey);
        }
        if (!loc.Exists && loc.Path == null) {
            Debug.LogWarning('资源缺失：地址 ${loc.PrimaryKey}（清单里标记为缺失）。');
            return null;
        }
        var bytes = readBytes(loc);
        if (bytes == null) {
            Debug.LogWarning('资源缺失：地址 ${loc.PrimaryKey} → 路径 ${loc.Path}（未在磁盘上找到）。');
            return null;
        }
        return switch (loc.Kind) {
            case KIND_IMAGE: decodeImage(loc, bytes);
            case KIND_AUDIO: decodeAudio(loc, bytes);
            case KIND_TEXT: decodeText(loc, bytes);
            default: bytes;
        }
    }

    // PORT-NOTE: 移植层新增。按 assets 相对路径取资源（复用同一份 loadedAssets 缓存）。
    // 用途：sprites_manifest.json 里的贴图只有 assetPath（`GameContent/Assets/.../x.png`），
    // 没有 Addressables 地址；统一从这里取值可以避免「同一个 PNG 既被 ResourceManifest 解成
    // FlxGraphic、又被 SpriteTextureCache 解成 BitmapData」的重复解码（工作包 ③ 的遗留问题）。
    // 清单里没有该路径时按扩展名合成一个 Image 定位符（仍走同一个缓存）。
    public function loadByPath(path:String):Dynamic {
        if (path == null || path == "")
            return null;
        var norm = normalize(path);
        var loc = pathIndex.get(norm);
        if (loc == null && StringTools.startsWith(norm, "assets/"))
            loc = pathIndex.get(norm.substr(7));
        if (loc == null) {
            var rel = norm;
            if (StringTools.startsWith(rel, "assets/"))
                rel = rel.substr(7);
            var ext = extensionOf(rel);
            var kind = normalizeKind(ext, ext);
            loc = new ResourceLocation(rel, rel, ext, kind, unityTypeNameOf(kind));
            loc.Labels = [];
            loc.Exists = true;
            pathIndex.set(norm, loc);
            pathIndex.set(rel, loc);
        }
        return load(loc);
    }

    /** 按 assets 相对路径取已解码的图片（Image 类别 → FlxGraphic）。 */
    public function loadImageByPath(path:String):Dynamic {
        return loadByPath(path);
    }

    /** 已解码图片的 BitmapData（FlxGraphic.bitmap 或 BitmapData 本身）；未加载/失败返回 null。 */
    public static function bitmapDataOf(asset:Dynamic):BitmapData {
        if (asset == null)
            return null;
        if (Std.isOfType(asset, FlxGraphic))
            return (cast asset:FlxGraphic).bitmap;
        if (Std.isOfType(asset, BitmapData))
            return cast asset;
        return null;
    }

    private function readBytes(loc:ResourceLocation):Bytes {
        var path = resolvePath(loc.Path);
        if (path != null) {
            try {
                return File.getBytes(path);
            } catch (e:Dynamic) {
                Debug.LogWarning('读取资源失败：$path（$e）');
            }
        }
        // PORT-NOTE: 若资源被打进 lime 资源库（Project.xml 的 <assets path="assets"/>），
        // 这里再按 lime 的资源 id 取一次。
        for (id in [loc.Path, "assets/" + loc.Path]) {
            if (id == null)
                continue;
            try {
                if (openfl.utils.Assets.exists(id))
                    return openfl.utils.Assets.getBytes(id);
            } catch (e:Dynamic) {}
        }
        return null;
    }

    private function decodeImage(loc:ResourceLocation, bytes:Bytes):Dynamic {
        var bitmap:BitmapData = null;
        try {
            bitmap = BitmapData.fromBytes(bytes);
        } catch (e:Dynamic) {
            Debug.LogWarning('图片解码失败：${loc.Path}（$e）');
            return null;
        }
        if (bitmap == null) {
            Debug.LogWarning('图片解码失败：${loc.Path}');
            return null;
        }
        // PORT-NOTE: C# 的 Sprite/Texture2D 在移植层由 flixel 的 FlxGraphic 承载像素
        // （FlxGraphic 进 flixel 的全局缓存；精灵的 rect/pivot 等元数据由
        // 精灵清单 assets/sprites_manifest.json 提供）。FlxGraphic 不可用时退回 BitmapData。
        // 缓存键用资源路径而不是地址：同一个地址可能对应多个文件（见 addEntry）。
        try {
            var key = loc.Path != null ? loc.Path : loc.PrimaryKey;
            var graphic = FlxGraphic.fromBitmapData(bitmap, false, key, true);
            // PORT-NOTE: FlxGraphic 默认 destroyOnNoUse=true：一旦 useCount 归零
            //（FlxSprite.frames 被换掉 / 渲染对象被销毁），flixel 会把它从位图缓存里移除并
            // destroy()，位图与帧集合随之失效。移植层把它当「常驻资源」用（与 Unity 的
            // 资产引用语义一致，且 SpriteFrameFactory 会长期缓存帧），因此显式关掉自动销毁。
            if (graphic != null)
                graphic.destroyOnNoUse = false;
            return graphic;
        } catch (e:Dynamic) {
            Debug.LogWarning('FlxGraphic 构造失败，退回 BitmapData：${loc.Path}（$e）');
            return bitmap;
        }
    }

    private function decodeAudio(loc:ResourceLocation, bytes:Bytes):Dynamic {
        var buffer:AudioBuffer = null;
        try {
            buffer = AudioBuffer.fromBytes(bytes);
        } catch (e:Dynamic) {
            Debug.LogWarning('音频解码失败：${loc.Path}（$e）');
            return null;
        }
        if (buffer == null) {
            Debug.LogWarning('音频解码失败：${loc.Path}');
            return null;
        }
        var sound = Sound.fromAudioBuffer(buffer);
        var clip = new AudioClip(loc.PrimaryKey);
        // PORT-NOTE: 移植层扩展字段（见 unity/AudioClip.hx）：Unity 的 AudioClip 由原生音频系统持有时长，
        // 这里把解码结果挂在 AudioClip 上，MusicManager 读的 clip.length 与源文件真实时长一致。
        clip.sound = sound;
        clip.length = sound.length / 1000; // openfl 的 Sound.length 单位是毫秒，Unity 的 AudioClip.length 是秒
        clip.frequency = buffer.sampleRate;
        clip.channels = buffer.channels;
        // PORT-NOTE: lime.media.AudioBuffer 没有 samples 字段，按 openfl Sound.get_length() 同样的算法
        // 由原始字节数换算每声道采样数（压缩格式的 data 为 null 时为 0）。
        clip.samples = (buffer.data != null && buffer.channels > 0 && buffer.bitsPerSample > 0)
            ? Std.int((buffer.data.length * 8) / (buffer.channels * buffer.bitsPerSample)) : 0;
        try {
            clip.flxSound = new FlxSound().loadEmbedded(sound);
        } catch (e:Dynamic) {
            Debug.LogWarning('FlxSound 构造失败（${loc.Path}）：$e，仅提供 openfl Sound。');
        }
        return clip;
    }

    private function decodeText(loc:ResourceLocation, bytes:Bytes):Dynamic {
        // C# 里这些文件的资源类型就是 UnityEngine.TextAsset（.xml 元数据 / .bytes 语言包）。
        return new TextAsset(bytes, loc.PrimaryKey);
    }
    // #endregion

    // #region 路径解析
    /** 把清单里的相对路径解析成磁盘绝对路径（找不到返回 null，结果会缓存）。 */
    public function resolvePath(relative:String):String {
        if (relative == null || relative == "")
            return null;
        var norm = normalize(relative);
        if (pathCache.exists(norm)) {
            var cached = pathCache.get(norm);
            return cached == "" ? null : cached;
        }
        var found = findPath(norm);
        pathCache.set(norm, found == null ? "" : found);
        return found;
    }

    private function findPath(norm:String):String {
        if (Path.isAbsolute(norm) && isFile(norm))
            return norm;
        var candidates:Array<String> = [];
        candidates.push(norm);
        if (StringTools.startsWith(norm, "Assets/"))
            candidates.push(norm.substr(7));
        var lower = norm.toLowerCase();
        if (StringTools.startsWith(lower, "assets/"))
            candidates.push(norm.substr(7));
        for (root in assetsRoots) {
            for (c in candidates) {
                var p = joinPath(root, c);
                if (isFile(p))
                    return p;
            }
        }
        return null;
    }

    private static function isFile(p:String):Bool {
        try {
            return FileSystem.exists(p) && !FileSystem.isDirectory(p);
        } catch (e:Dynamic) {
            return false;
        }
    }

    private static function normalize(p:String):String {
        return StringTools.replace(p, "\\", "/");
    }

    private static function joinPath(root:String, rel:String):String {
        if (root == null || root == "")
            return rel;
        var last = root.charAt(root.length - 1);
        if (last == "/" || last == "\\")
            return root + rel;
        return root + "/" + rel;
    }

    /** 按 cwd 与可执行文件位置向上搜索 assets 根（含 HaxePort/assets、<exe>/assets 等部署形态）。 */
    private static function findAssetRoots():Array<String> {
        var result:Array<String> = [];
        // 显式指定的 assets 根优先（测试/工具用）。
        if (assetsRootOverride != null) {
            var explicit = normalize(Path.normalize(assetsRootOverride));
            if (isAssetRoot(explicit))
                addRoot(result, explicit);
            else
                addRoot(result, explicit + "/assets");
        }
        var bases:Array<String> = [];
        try {
            bases.push(Sys.getCwd());
        } catch (e:Dynamic) {}
        try {
            var program = Sys.programPath();
            if (program != null)
                bases.push(Path.directory(program));
        } catch (e:Dynamic) {}
        for (base in bases) {
            if (base == null)
                continue;
            var dir = base;
            for (_ in 0...12) {
                if (dir == null || dir == "")
                    break;
                addRoot(result, dir);
                addRoot(result, dir + "/assets");
                addRoot(result, dir + "/HaxePort/assets");
                var parent = Path.directory(dir);
                if (parent == null || parent == dir)
                    break;
                dir = parent;
            }
        }
        return result;
    }

    private static function addRoot(list:Array<String>, dir:String):Void {
        var norm = normalize(Path.normalize(dir));
        if (list.indexOf(norm) >= 0)
            return;
        if (!isAssetRoot(norm))
            return;
        list.push(norm);
    }

    private static function isAssetRoot(dir:String):Bool {
        try {
            if (!FileSystem.isDirectory(dir))
                return false;
            return FileSystem.exists(joinPath(dir, MANIFEST_FILE)) || FileSystem.isDirectory(dir + "/GameContent");
        } catch (e:Dynamic) {
            return false;
        }
    }

    private static function findManifestFile(roots:Array<String>):String {
        for (root in roots) {
            var p = root + "/" + MANIFEST_FILE;
            if (isFile(p))
                return p;
        }
        return null;
    }
    // #endregion

    // #region 无清单时的降级索引
    // TODO-PORT: 清单缺失时只能按文件名近似解析地址（拿不到 Addressables 标签），
    // 仅用于清单生成失败时仍能启动；正常流程以 resource_manifest.json 为准。
    private function buildFallbackIndex():Void {
        usingFallbackIndex = true;
        fallbackPaths = new Map();
        fallbackNames = new Map();
        for (root in assetsRoots) {
            scanFallback(root, "");
            if (entryCount > 0)
                break;
        }
    }

    private function scanFallback(root:String, sub:String):Void {
        var dir = sub == "" ? root : joinPath(root, sub);
        var items:Array<String> = null;
        try {
            items = FileSystem.readDirectory(dir);
        } catch (e:Dynamic) {
            return;
        }
        for (name in items) {
            var rel = sub == "" ? name : sub + "/" + name;
            var full = joinPath(root, rel);
            if (isFile(full)) {
                var key = rel.toLowerCase();
                fallbackPaths.set(key, rel);
                var base = name;
                var dot = base.lastIndexOf(".");
                if (dot > 0)
                    base = base.substr(0, dot);
                var baseKey = base.toLowerCase();
                if (!fallbackNames.exists(baseKey))
                    fallbackNames.set(baseKey, rel);
                entryCount++;
            } else if (FileSystem.isDirectory(full)) {
                scanFallback(root, rel);
            }
        }
    }

    private function locateFallback(key:String):ResourceLocation {
        if (fallbackPaths == null)
            return null;
        var norm = normalize(key);
        var rel = fallbackPaths.get(norm.toLowerCase());
        if (rel == null && StringTools.startsWith(norm, "Assets/"))
            rel = fallbackPaths.get(norm.substr(7).toLowerCase());
        if (rel == null) {
            var tail = norm;
            var colon = tail.lastIndexOf(":");
            if (colon >= 0)
                tail = tail.substr(colon + 1);
            var slash = tail.lastIndexOf("/");
            if (slash >= 0)
                tail = tail.substr(slash + 1);
            var dot = tail.lastIndexOf(".");
            if (dot > 0)
                tail = tail.substr(0, dot);
            rel = fallbackNames.get(tail.toLowerCase());
        }
        if (rel == null)
            return null;
        var ext = extensionOf(rel);
        var kind = normalizeKind(ext, ext);
        var loc = new ResourceLocation(key, rel, ext, kind, unityTypeNameOf(kind));
        loc.Labels = [];
        return loc;
    }
    // #endregion

    // #region 工具
    private function warnOnce(id:String, message:String):Void {
        if (warnedKeys.exists(id))
            return;
        warnedKeys.set(id, true);
        Debug.LogWarning(message);
    }

    private static function extensionOf(path:String):String {
        var slash = path.lastIndexOf("/");
        var name = slash >= 0 ? path.substr(slash + 1) : path;
        var dot = name.lastIndexOf(".");
        if (dot <= 0)
            return "";
        return name.substr(dot + 1).toLowerCase();
    }

    private static function firstString(obj:Dynamic, fields:Array<String>):String {
        for (f in fields) {
            var v:Dynamic = Reflect.field(obj, f);
            if (v != null && Std.isOfType(v, String) && (v:String) != "")
                return cast v;
        }
        return null;
    }

    private static function existsField(obj:Dynamic):Null<Bool> {
        var v:Dynamic = Reflect.field(obj, "exists");
        if (v == null)
            return null;
        if (Std.isOfType(v, Bool))
            return cast v;
        return null;
    }

    private static function stringArray(value:Dynamic):Array<String> {
        if (value == null)
            return null;
        if (!Std.isOfType(value, Array))
            return null;
        var result:Array<String> = [];
        for (item in (value:Array<Dynamic>)) {
            if (item != null)
                result.push(Std.string(item));
        }
        return result;
    }
    // #endregion
}
