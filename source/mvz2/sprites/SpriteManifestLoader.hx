package mvz2.sprites;

import haxe.Json;
import mvz2.io.PathHelper;
import mvz2.sprites.SpriteManifest.SpriteEntry;
import mvz2.sprites.SpriteManifest.SpriteSheetEntry;
import mvz2.sprites.SpriteManifestData;
import mvz2.sprites.SpriteManifestData.SpriteAtlasDefinition;
import mvz2.sprites.SpriteManifestData.SpriteDefinition;
import mvz2.sprites.SpriteManifestData.SpriteSheetDefinition;
import mvz2.sprites.SpriteManifestData.SpriteSliceDefinition;
import mvz2.sprites.SpriteManifestData.SpriteTextureDefinition;
import unity.Application;
import unity.Debug;
import unity.Rect;
import unity.Sprite;
import unity.Texture2D;
import unity.Vector2;

// PORT-NOTE: 移植层新增。原工程里精灵来自 Unity Addressables：
//   - ResourceManager_Sprites.LoadInitSpriteManifests / LoadMainSpriteManifests 按 "Init"/"Main"
//     + "SpriteManifest" 标签加载 SpriteManifest 资产（name -> Sprite / Sprite[]）；
//   - LoadSpriteSheets / LoadSprites 按 "Spritesheet"/"Sprite" 标签加载整张贴图。
// 移植层没有 AssetBundle/Addressables 与 Unity 的纹理导入，因此由
// tools_build/convert_sprites.py 在构建期把 *.png.meta 的 sprite 定义、
// spritemanifests/*.asset 的引用关系、spriteatlasv2 的图集成员关系导出成
// assets/sprites_manifest.json，本类负责在运行期把它还原成等价的 SpriteManifest 数据。
//
// 取得帧矩形：
//   SpriteManifestLoader.load();
//   var def = SpriteManifestLoader.getSprite("level/palace/palace");   // rect / pivot / pixelsPerUnit
//   var sheet = SpriteManifestLoader.getSpriteSheet("characters/eirin"); // slices[i].rect
class SpriteManifestLoader {
    /// 由 Project.xml 的 <assets path="assets" /> 决定，id 相对 assets/ 目录。
    public static inline var MANIFEST_FILE_NAME:String = "sprites_manifest.json";
    public static inline var MANIFEST_FILE_PATH:String = "assets/sprites_manifest.json";
    /// 工作包 ① 生成的资产清单（地址 → 路径/类型/标签）。
    public static inline var RESOURCE_MANIFEST_FILE_NAME:String = "resource_manifest.json";
    public static inline var RESOURCE_MANIFEST_FILE_PATH:String = "assets/resource_manifest.json";

    public static var isLoaded(default, null):Bool = false;
    public static var loadError(default, null):String = null;
    public static var data(default, null):SpriteManifestData = null;

    private static var loadAttempted:Bool = false;

    private function new() {}

    /// 解析清单。幂等：重复调用不会重新读取文件。返回是否成功。
    /// jsonText / resourceJsonText 用于测试时直接注入文本。
    public static function load(?jsonText:String, ?resourceJsonText:String):Bool {
        if (isLoaded)
            return true;
        if (jsonText == null && loadAttempted && !isLoaded)
            return false;
        loadAttempted = true;
        var text = jsonText != null ? jsonText : readAssetText(MANIFEST_FILE_NAME, MANIFEST_FILE_PATH);
        if (text == null) {
            loadError = 'SpriteManifestLoader: 无法读取 $MANIFEST_FILE_PATH';
            Debug.LogError(loadError);
            return false;
        }
        try {
            data = parse(text);
            applyResourceManifest(data, resourceJsonText);
        } catch (e:Dynamic) {
            data = null;
            loadError = 'SpriteManifestLoader: 解析 $MANIFEST_FILE_PATH 失败：$e';
            Debug.LogError(loadError);
            return false;
        }
        isLoaded = true;
        loadError = null;
        Debug.Log('SpriteManifestLoader: 已载入 ${Lambda.count(data.sprites)} 个精灵、'
            + '${Lambda.count(data.spriteSheets)} 个精灵图集、${Lambda.count(data.textures)} 张贴图；'
            + '其中 ${data.resourceManifestResolved} 条的贴图路径取自 $RESOURCE_MANIFEST_FILE_NAME。');
        return true;
    }

    public static function reset():Void {
        isLoaded = false;
        loadAttempted = false;
        loadError = null;
        data = null;
        _guidIndex = null;
    }

    // ---------------------------------------------- 与 ① 的资产清单衔接

    /// PORT-NOTE: 移植层的「地址 → 资产路径」解析只保留一份，即工作包 ① 的
    /// assets/resource_manifest.json（生成器 tools_build/build_manifest.py）；
    /// 本类只负责「地址 → 帧矩形/pivot/像素比」。因此这里按精灵地址（如 mvz2:init/button）
    /// 到 ① 的清单里查贴图路径，查不到时才回退到本清单里由 *.png.meta 同目录推导的 assetPath。
    private static function applyResourceManifest(result:SpriteManifestData, ?jsonText:String):Void {
        var text = jsonText != null ? jsonText : readAssetText(RESOURCE_MANIFEST_FILE_NAME, RESOURCE_MANIFEST_FILE_PATH);
        if (text == null) {
            Debug.LogWarning('SpriteManifestLoader: 未找到 $RESOURCE_MANIFEST_FILE_PATH，贴图路径回退为 '
                + '$MANIFEST_FILE_NAME 内的 assetPath。');
            fallbackAssetPaths(result);
            return;
        }
        var root:Dynamic = Json.parse(text);
        var paths = new Map<String, String>();
        var addresses = Reflect.field(root, "addresses");
        if (addresses != null) {
            for (key in Reflect.fields(addresses)) {
                var info = Reflect.field(addresses, key);
                var p = info == null ? null : Reflect.field(info, "path");
                if (p != null)
                    paths.set(key, Std.string(p));
            }
        }
        if (Lambda.count(paths) == 0) {
            // 兼容 ① 清单的其它写法：entries 数组，或顶层 address -> path 平表。
            var entries = Reflect.field(root, "entries");
            if (entries != null && Std.isOfType(entries, Array)) {
                for (e in (cast entries : Array<Dynamic>)) {
                    var a = Reflect.field(e, "address");
                    var p = Reflect.field(e, "path");
                    if (a != null && p != null)
                        paths.set(Std.string(a), Std.string(p));
                }
            } else {
                for (key in Reflect.fields(root)) {
                    var v = Reflect.field(root, key);
                    if (Std.isOfType(v, String))
                        paths.set(key, v);
                }
            }
        }
        result.resourceManifestLoaded = Lambda.count(paths) > 0;
        for (s in result.sprites)
            s.assetPath = resolveAssetPath(result, paths, s.id, s.texture);
        for (sheet in result.spriteSheets)
            sheet.assetPath = resolveAssetPath(result, paths, sheet.id, sheet.texture);
    }

    private static function resolveAssetPath(result:SpriteManifestData, paths:Map<String, String>, id:String,
            texture:SpriteTextureDefinition):String {
        var resolved = paths.get(id);
        if (resolved != null) {
            result.resourceManifestResolved++;
            if (texture != null && texture.assetPath != null && texture.assetPath != resolved)
                result.resourceManifestMismatches.push(id);
            return resolved;
        }
        result.resourceManifestFallbacks.push(id);
        return texture == null ? null : texture.assetPath;
    }

    private static function fallbackAssetPaths(result:SpriteManifestData):Void {
        for (s in result.sprites)
            s.assetPath = s.texture == null ? null : s.texture.assetPath;
        for (sheet in result.spriteSheets)
            sheet.assetPath = sheet.texture == null ? null : sheet.texture.assetPath;
    }

    /// 读取 assets/ 下的文本资源：优先走 lime/openfl 的 assets 清单（打包进可执行文件），失败则读磁盘。
    private static function readAssetText(fileName:String, filePath:String):String {
        // PORT-NOTE: <assets path="assets" /> 下资源 id 相对 assets/（见 Project.xml），
        // 但不同 lime 版本可能带上目录前缀，故逐个候选尝试。
        for (id in [fileName, filePath]) {
            var text = tryAssetText(id);
            if (text != null)
                return text;
        }
        #if sys
        // 开发期直接运行时的兜底：相对当前工作目录 / 可执行文件目录查找 assets/。
        var candidates:Array<String> = [
            PathHelper.combine(Sys.getCwd(), filePath),
            PathHelper.combine(Application.dataPath, fileName),
            PathHelper.combine(Sys.getCwd(), "HaxePort", filePath),
        ];
        for (path in candidates) {
            if (sys.FileSystem.exists(path) && !sys.FileSystem.isDirectory(path)) {
                try {
                    return sys.io.File.getContent(path);
                } catch (e:Dynamic) {}
            }
        }
        #end
        return null;
    }

    private static function tryAssetText(id:String):String {
        try {
            if (openfl.utils.Assets.exists(id, openfl.utils.AssetType.TEXT)) {
                return openfl.utils.Assets.getText(id);
            }
        } catch (e:Dynamic) {}
        return null;
    }

    // ------------------------------------------------------------------ 解析

    private static function parse(text:String):SpriteManifestData {
        var root:Dynamic = Json.parse(text);
        var result = new SpriteManifestData();
        result.formatVersion = intField(root, "formatVersion", 1);
        result.generatedAt = strField(root, "generatedAt");
        result.sourceProject = strField(root, "sourceProject");
        result.assetRoot = strField(root, "assetRoot");
        result.namespace = strField(root, "namespace");

        var textures = field(root, "textures");
        if (textures != null) {
            for (guid in Reflect.fields(textures)) {
                var o = Reflect.field(textures, guid);
                var t = new SpriteTextureDefinition();
                t.guid = guid;
                t.unityPath = strField(o, "unityPath");
                t.assetPath = strField(o, "assetPath");
                t.width = intField(o, "width", 0);
                t.height = intField(o, "height", 0);
                t.spriteMode = intField(o, "spriteMode", 1);
                t.pixelsPerUnit = floatField(o, "pixelsPerUnit", 100);
                t.alignment = intField(o, "alignment", 0);
                t.pivot = vectorField(o, "pivot");
                t.pivotRaw = vectorField(o, "pivotRaw", t.pivot);
                var slices = field(o, "slices");
                if (slices != null) {
                    for (s in (cast slices : Array<Dynamic>)) {
                        t.slices.push(readSlice(s, t.pixelsPerUnit));
                    }
                }
                result.textures.set(guid, t);
            }
        }

        var sprites = field(root, "sprites");
        if (sprites != null) {
            for (id in Reflect.fields(sprites)) {
                var o = Reflect.field(sprites, id);
                var s = new SpriteDefinition();
                s.id = strField(o, "id");
                s.namespace = strField(o, "namespace");
                s.path = strField(o, "path");
                s.name = strField(o, "name");
                s.textureGuid = strField(o, "texture");
                s.alignment = intField(o, "alignment", 0);
                s.pixelsPerUnit = floatField(o, "pixelsPerUnit", 100);
                s.rect = rectField(o, "rect");
                s.pivot = vectorField(o, "pivot");
                s.pivotRaw = vectorField(o, "pivotRaw", s.pivot);
                s.group = strField(o, "group");
                s.labels = strArrayField(o, "labels");
                s.manifest = strField(o, "manifest");
                s.manifestLabels = strArrayField(o, "manifestLabels");
                s.atlases = strArrayField(o, "atlases");
                s.sources = strArrayField(o, "sources");
                s.texture = result.textures.get(s.textureGuid);
                result.sprites.set(s.path, s);
            }
        }

        var sheets = field(root, "spriteSheets");
        if (sheets != null) {
            for (id in Reflect.fields(sheets)) {
                var o = Reflect.field(sheets, id);
                var sh = new SpriteSheetDefinition();
                sh.id = strField(o, "id");
                sh.namespace = strField(o, "namespace");
                sh.path = strField(o, "path");
                sh.name = strField(o, "name");
                sh.textureGuid = strField(o, "texture");
                sh.group = strField(o, "group");
                sh.labels = strArrayField(o, "labels");
                sh.manifest = strField(o, "manifest");
                sh.manifestLabels = strArrayField(o, "manifestLabels");
                sh.atlases = strArrayField(o, "atlases");
                sh.sources = strArrayField(o, "sources");
                sh.texturePivot = vectorField(o, "texturePivot");
                sh.textureAlignment = intField(o, "textureAlignment", 0);
                sh.sliceOrder = strField(o, "sliceOrder");
                sh.texture = result.textures.get(sh.textureGuid);
                var ppu = sh.texture != null ? sh.texture.pixelsPerUnit : 100;
                var slices = field(o, "slices");
                if (slices != null) {
                    for (s in (cast slices : Array<Dynamic>)) {
                        sh.slices.push(readSlice(s, ppu));
                    }
                }
                result.spriteSheets.set(sh.path, sh);
            }
        }

        var atlases = field(root, "atlases");
        if (atlases != null) {
            for (name in Reflect.fields(atlases)) {
                var o = Reflect.field(atlases, name);
                var a = new SpriteAtlasDefinition();
                a.name = name;
                a.assetPath = strField(o, "assetPath");
                a.packableFolders = strArrayField(o, "packableFolders");
                a.sprites = strArrayField(o, "sprites");
                a.spriteSheets = strArrayField(o, "spriteSheets");
                a.unresolvedPackables = strArrayField(o, "unresolvedPackables");
                result.atlases.set(name, a);
            }
        }

        result.warnings = strArrayField(root, "warnings");
        return result;
    }

    private static function readSlice(o:Dynamic, defaultPPU:Float):SpriteSliceDefinition {
        var s = new SpriteSliceDefinition();
        s.name = strField(o, "name");
        s.rect = rectField(o, "rect");
        s.pivot = vectorField(o, "pivot");
        s.pivotRaw = vectorField(o, "pivotRaw", s.pivot);
        s.alignment = intField(o, "alignment", 0);
        s.pixelsPerUnit = floatField(o, "pixelsPerUnit", defaultPPU);
        s.spriteID = strField(o, "spriteID");
        s.internalIDString = strField(o, "internalIDString");
        if (s.internalIDString == null) {
            // 兼容没有字符串字段的旧清单。
            var raw = field(o, "internalID");
            s.internalIDString = raw == null ? null : Std.string(raw);
        }
        return s;
    }

    private static inline function field(o:Dynamic, name:String):Dynamic {
        return o == null ? null : Reflect.field(o, name);
    }
    private static function strField(o:Dynamic, name:String):String {
        var v = field(o, name);
        return v == null ? null : Std.string(v);
    }
    private static function intField(o:Dynamic, name:String, def:Int):Int {
        var v = field(o, name);
        if (v == null)
            return def;
        return Std.int(v);
    }
    private static function floatField(o:Dynamic, name:String, def:Float):Float {
        var v = field(o, name);
        if (v == null)
            return def;
        return (cast v : Float);
    }
    private static function strArrayField(o:Dynamic, name:String):Array<String> {
        var v = field(o, name);
        if (v == null)
            return [];
        return [for (x in (cast v : Array<Dynamic>)) Std.string(x)];
    }
    private static function rectField(o:Dynamic, name:String):Rect {
        var v = field(o, name);
        if (v == null)
            return new Rect();
        return new Rect(
            floatField(v, "x", 0), floatField(v, "y", 0),
            floatField(v, "width", 0), floatField(v, "height", 0));
    }
    private static function vectorField(o:Dynamic, name:String, ?def:Vector2):Vector2 {
        var v = field(o, name);
        if (v == null)
            return def != null ? new Vector2(def.x, def.y) : new Vector2(0.5, 0.5);
        return new Vector2(floatField(v, "x", 0.5), floatField(v, "y", 0.5));
    }

    // ------------------------------------------------------------------ 查询

    /// 按 NamespaceID.Path 查询单帧精灵（与 ModResource.Sprites 的键一致）。
    public static function getSpriteDefinition(path:String):SpriteDefinition {
        return data == null ? null : data.sprites.get(path);
    }
    /// 按完整 ID（mvz2:xxx）查询单帧精灵。
    public static function getSpriteDefinitionByID(id:String):SpriteDefinition {
        var index = id == null ? -1 : id.indexOf(":");
        return getSpriteDefinition(index < 0 ? id : id.substr(index + 1));
    }
    public static function getSpriteSheetDefinition(path:String):SpriteSheetDefinition {
        return data == null ? null : data.spriteSheets.get(path);
    }
    public static function getTextureDefinition(guid:String):SpriteTextureDefinition {
        return data == null ? null : data.textures.get(guid);
    }
    public static function getAtlasDefinition(name:String):SpriteAtlasDefinition {
        return data == null ? null : data.atlases.get(name);
    }
    public static function getSpriteDefinitions():Array<SpriteDefinition> {
        return data == null ? [] : [for (s in data.sprites) s];
    }
    public static function getSpriteSheetDefinitions():Array<SpriteSheetDefinition> {
        return data == null ? [] : [for (s in data.spriteSheets) s];
    }
    /// 找出所有含指定 Addressables 标签的精灵。
    public static function findSpritesByLabel(label:String):Array<SpriteDefinition> {
        return Lambda.filter(getSpriteDefinitions(), s -> s.labels.indexOf(label) >= 0);
    }
    /// 找出所有含指定标签的精灵图集。
    public static function findSpriteSheetsByLabel(label:String):Array<SpriteSheetDefinition> {
        return Lambda.filter(getSpriteSheetDefinitions(), s -> s.labels.indexOf(label) >= 0);
    }

    /// 该精灵是否属于给定标签的 SpriteManifest（等价于 C# 的标签交集筛选）。
    public static function belongsToManifest(manifestLabels:Array<String>, labels:Array<String>):Bool {
        for (label in labels) {
            if (manifestLabels.indexOf(label) < 0)
                return false;
        }
        return true;
    }

    // ------------------------------------- Unity 资产引用（guid[:fileID]）→ 精灵

    /// PORT-NOTE: 移植层新增。prefab（模型/场景）里的 `m_Sprite: {fileID, guid}` 引用在
    /// Unity 里由资产系统直接解析成 Sprite 子资源；移植层没有这套系统，本函数按
    /// `guid`（贴图 guid）与 `fileID`（贴图 .meta 里的 sprite internalID）反查清单：
    ///   * fileID 为 21300000（Unity 的 "主资产" fileID）或空 → 整张贴图对应的单帧精灵；
    ///   * 其它 fileID → spriteMode=2 贴图里的某个切片（即图集的某一帧）。
    /// 找不到返回 null（调用点按「无法还原 = 无匹配资源」处理，见 ResourceManager）。
    public static function getSpriteDefinitionByAssetRef(guid:String, ?fileID:String):SpriteDefinition {
        if (guid == null || guid == "")
            return null;
        var index = guidIndex();
        if (index == null)
            return null;
        // fileID 缺省/主资产 → 单帧精灵（一个 guid 可能对应多条，取第一条）。
        if (fileID == null || fileID == "" || fileID == "21300000") {
            var list = index.single.get(guid);
            if (list != null && list.length > 0)
                return list[0];
            // 只有图集的贴图时，退回该贴图的第一帧（语义等价于 Unity 里贴图的主 Sprite）。
            var sheet = index.sheet.get(guid);
            if (sheet != null && sheet.slices.length > 0)
                return sheetAsSingleSprite(sheet, 0);
            return null;
        }
        var pair = index.slice.get(guid + ":" + fileID);
        if (pair != null) {
            var sheet = getSpriteSheetDefinition(pair.sheetPath);
            if (sheet != null && pair.index >= 0 && pair.index < sheet.slices.length)
                return sheetAsSingleSprite(sheet, pair.index);
        }
        var single = index.single.get(guid);
        return (single != null && single.length > 0) ? single[0] : null;
    }

    /// 把图集的某一帧当作单帧精灵返回（等价于 Unity 里该 Sprite 子资源）。
    public static function sheetAsSingleSprite(sheet:SpriteSheetDefinition, index:Int):SpriteDefinition {
        if (sheet == null || index < 0 || index >= sheet.slices.length)
            return null;
        var slice = sheet.slices[index];
        var sprite = new SpriteDefinition();
        sprite.id = sheet.id;
        sprite.namespace = sheet.namespace;
        // PORT-NOTE: Unity 里图集子资源的引用名是 `<贴图名>_<下标>`；这里用切片名，
        // 与 spriteSheets[].slices[].name 一致，便于诊断。
        sprite.path = slice.name != null ? slice.name : '${sheet.path}[$index]';
        sprite.name = slice.name;
        sprite.textureGuid = sheet.textureGuid;
        sprite.rect = slice.rect;
        sprite.pivot = slice.pivot;
        sprite.pivotRaw = slice.pivotRaw;
        sprite.alignment = slice.alignment;
        sprite.pixelsPerUnit = slice.pixelsPerUnit;
        sprite.group = sheet.group;
        sprite.labels = sheet.labels;
        sprite.manifest = sheet.manifest;
        sprite.manifestLabels = sheet.manifestLabels;
        sprite.atlases = sheet.atlases;
        sprite.sources = sheet.sources;
        sprite.texture = sheet.texture;
        sprite.assetPath = sheet.assetPath;
        return sprite;
    }

    // PORT-NOTE: guid 索引（懒建，一次性遍历清单）。
    private static var _guidIndex:{single:Map<String, Array<SpriteDefinition>>, sheet:Map<String, SpriteSheetDefinition>, slice:Map<String, {sheetPath:String, index:Int}>} = null;

    private static function guidIndex() {
        if (_guidIndex != null)
            return _guidIndex;
        if (data == null)
            return null;
        var single = new Map<String, Array<SpriteDefinition>>();
        for (s in data.sprites) {
            if (s.textureGuid == null)
                continue;
            var list = single.get(s.textureGuid);
            if (list == null) {
                list = [];
                single.set(s.textureGuid, list);
            }
            list.push(s);
        }
        var sheets = new Map<String, SpriteSheetDefinition>();
        var slices = new Map<String, {sheetPath:String, index:Int}>();
        for (sheet in data.spriteSheets) {
            if (sheet.textureGuid != null && !sheets.exists(sheet.textureGuid))
                sheets.set(sheet.textureGuid, sheet);
            for (i in 0...sheet.slices.length) {
                var slice = sheet.slices[i];
                if (sheet.textureGuid == null || slice.internalIDString == null)
                    continue;
                slices.set(sheet.textureGuid + ":" + slice.internalIDString, {sheetPath: sheet.path, index: i});
            }
        }
        _guidIndex = {single: single, sheet: sheets, slice: slices};
        return _guidIndex;
    }

    // ------------------------------------------------- 与原 SpriteManifest 资产等价

    /// 重建标签匹配的 SpriteManifest 资产内容，可直接交给
    /// ResourceManager.LoadSpriteManifest 使用（等价于 C# 用标签加载 SpriteManifest）。
    public static function createSpriteManifests(labels:Array<String>):Array<SpriteManifest> {
        if (!isLoaded && !load())
            return [];
        var result:Array<SpriteManifest> = [];
        var manifest = new SpriteManifest();
        manifest.name = labels.join("-");
        manifest.spriteEntries = [];
        manifest.spritesheetEntries = [];
        for (s in data.sprites) {
            if (!belongsToManifest(s.manifestLabels, labels))
                continue;
            manifest.spriteEntries.push(spriteEntry(s));
        }
        for (sheet in data.spriteSheets) {
            if (!belongsToManifest(sheet.manifestLabels, labels))
                continue;
            manifest.spritesheetEntries.push(spriteSheetEntry(sheet));
        }
        result.push(manifest);
        return result;
    }
    private static function spriteEntry(s:SpriteDefinition):SpriteEntry {
        return {name: s.path, sprite: createSprite(s)};
    }
    private static function spriteSheetEntry(sheet:SpriteSheetDefinition):SpriteSheetEntry {
        return {name: sheet.path, spritesheet: createSpriteSheet(sheet)};
    }

    // ------------------------------------------------------------- 精灵对象创建

    /// 按定义创建 unity.Sprite（贴图懒加载并缓存）。
    public static function createSprite(s:SpriteDefinition):Sprite {
        var sprite = Sprite.Create(getUnityTexture(s.texture, s.assetPath), s.rect, s.pivot);
        sprite.name = s.name != null ? s.name : s.path;
        sprite.pixelsPerUnit = s.pixelsPerUnit;
        return sprite;
    }

    /// 按定义创建多帧精灵数组，顺序与 SpriteManifest 中的引用顺序一致。
    public static function createSpriteSheet(sheet:SpriteSheetDefinition):Array<Sprite> {
        var texture = getUnityTexture(sheet.texture, sheet.assetPath);
        var result:Array<Sprite> = [];
        for (slice in sheet.slices) {
            var sprite = Sprite.Create(texture, slice.rect, slice.pivot);
            sprite.name = slice.name != null ? slice.name : sheet.path;
            sprite.pixelsPerUnit = slice.pixelsPerUnit;
            result.push(sprite);
        }
        return result;
    }

    /// 懒加载贴图（实际解码由 SpriteTextureCache 完成）。
    /// assetPath 为 ① 的 resource_manifest.json 解析出的路径，缺省时用贴图自身的 assetPath。
    public static function getUnityTexture(definition:SpriteTextureDefinition, ?assetPath:String):Texture2D {
        if (definition == null)
            return null;
        return SpriteTextureCache.getTexture(definition, assetPath);
    }

    /// PORT-NOTE: 移植层新增。把一张**已有**的 unity.Texture2D 包成整图 Sprite
    /// （Unity 的 `Sprite.Create(texture, rect, pivot)` 等价物，rect 取整张贴图）。
    /// 用途：`unity.ui.RawImage` 的 texture 字段只给出贴图，没有精灵子矩形信息，
    /// 渲染层需要一个 unity.Sprite 才能走 `SpriteFrameFactory.getFrame`。
    /// 尺寸取自贴图解码后的实际像素（清单里的 width/height 可能与 PNG 不一致）。
    public static function createSpriteForTexture(texture:Texture2D):Sprite {
        if (texture == null)
            return null;
        if (spriteForTexture.exists(texture))
            return spriteForTexture.get(texture);
        var size = SpriteFrameFactory.getPixelSize(texture);
        var w = size.width > 0 ? size.width : texture.width;
        var h = size.height > 0 ? size.height : texture.height;
        var sprite = Sprite.Create(texture, new Rect(0, 0, w, h), new Vector2(0.5, 0.5));
        sprite.name = texture.name;
        spriteForTexture.set(texture, sprite);
        return sprite;
    }
    private static var spriteForTexture:Map<Texture2D, Sprite> = new Map();

    /**
     * PORT-NOTE: 移植层新增。按 (贴图 guid, 子精灵 fileID) 反查清单里的精灵定义并建出 unity.Sprite。
     *
     * Unity 的 prefab 用 `{guid, fileID}` 引用精灵：`fileID == 21300000` 表示"整张贴图
     * 当一张精灵"（spriteMode=1），其它值表示图集里的某个子精灵（fileID 就是
     * `Sprite.m_SpriteID`/`internalID`）。移植层的 `sprites_manifest.json` 里，
     * 精灵记录的 `rect` 取自贴图 `.meta`（spriteMode=1）或图集 slices（多帧），
     * 后者带 `internalIDString`，正是这个 fileID。因此按 (guid, fileID) 能精确定位：
     *   * 先按 internalIDString 命中图集切片；
     *   * 命中不到再退回"该 guid 下唯一的精灵"（spriteMode=1 的整图精灵）。
     */
    public static function findSpriteByFileID(guid:String, fileID:String):Sprite {
        if (guid == null)
            return null;
        if (!isLoaded && !load())
            return null;
        var normalized = normalizeFileID(fileID);
        if (normalized != null) {
            for (sheet in data.spriteSheets) {
                if (sheet.textureGuid != guid)
                    continue;
                for (slice in sheet.slices) {
                    if (slice.internalIDString != null && normalizeFileID(slice.internalIDString) == normalized) {
                        return Sprite.Create(getUnityTexture(sheet.texture, sheet.assetPath), slice.rect, slice.pivot);
                    }
                }
            }
        }
        // 退回：该 guid 下唯一的精灵（整图精灵，Unity 的 fileID 21300000）。
        var found:SpriteDefinition = null;
        for (s in data.sprites) {
            if (s.textureGuid != guid)
                continue;
            if (found != null)
                return null; // 多个候选时无法确定，交给调用方的兜底路径
            found = s;
        }
        if (found != null)
            return createSprite(found);
        return null;
    }

    /** Unity 的 fileID 序列化成十进制字符串；"0" 与空值表示"未指定"。 */
    private static function normalizeFileID(raw:String):String {
        if (raw == null || raw == "" || raw == "0")
            return null;
        return raw;
    }
}
