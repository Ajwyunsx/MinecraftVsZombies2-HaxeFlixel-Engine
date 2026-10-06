// Ported from: Assets/Scripts/MVZ2/Localization/LanguageManager.cs
// Ported from: Assets/Scripts/MVZ2/Localization/LanguageManager_Pack.cs (partial class 合并)
package mvz2.localization;
import mvz2.localization.LanguagePack.LanguagePackMetadata;  // IMPORTAUTO
import mvz2.localization.LocalizedSpriteManifest.LocalizedSprite;  // IMPORTAUTO
import mvz2.localization.LocalizedSpriteManifest.LocalizedSpriteSheet;  // IMPORTAUTO

import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.io.Bytes;
import mvz2.io.FileHelper;
import mvz2.io.ZipArchiveHelper;
import mvz2.managers.MainManager;
import mvz2.options.OptionsManager;
import mvz2logic.Global;
import mvz2logic.games.IGlobalLocalization;
import mvz2logic.localization.LogicStrings;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.LogicOptionExt;
import mvz2logic.resources.SpriteReference;
import newtonsoft.json.JsonConvert;
import ngettext.Catalog;
import pvzengine.NamespaceID;
import system.globalization.CultureInfo;
import system.globalization.CultureNotFoundException;
import system.io.Directory;
import system.io.File;
import system.io.FileMode;
import system.io.MemoryStream;
import system.io.Path;
import system.io.SearchOption;
import system.io.SeekOrigin;
import system.io.Stream;
import system.io.compression.ZipArchive;
import system.io.compression.ZipArchiveMode;
import system.io.compression.ZipFileExtensions;
import system.text.Encoding;
import tools.ObjectExtensions;
import unity.Application;
import unity.Debug;
import unity.Rect;
import unity.Sprite;
import unity.TextAsset;
import unity.Vector2;
import unity.addressableassets.Addressables;
using mvz2logic.options.LogicOptionExt;  // EXTUSING
using mvz2.io.FileHelper;  // EXTUSING
using mvz2.io.ZipArchiveHelper;  // EXTUSING
using mvz2.sprites.SpriteHelper;  // EXTUSING
using mvz2logic.artifacts.LogicArtifactProps;  // EXTUSING
using mvz2logic.serialization.SerializeHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING
using system.io.compression.ZipFileExtensions;  // EXTUSING

// PORT-NOTE: 原 C# 使用 async/await（Task）；Haxe 侧统一同步化，去掉 async 包装。
class LanguageManager extends unity.MonoBehaviour implements IGlobalLocalization {
    public function new() {
        super();
    }

    public function _(text:String, ?args:Array<Dynamic>):String {
        return GetLocalizedString(text, GetCurrentLanguage(), args);
    }
    public function _p(context:String, text:String, ?args:Array<Dynamic>):String {
        return GetLocalizedStringParticular(context, text, GetCurrentLanguage(), args);
    }
    // PORT-NOTE: C# 存在重载 _n(text, textPlural, n, args) 与 _n(text, n, args)；
    // Haxe 不支持重载，这里按第二个参数是否为数字进行分派。
    public function _n(text:String, a:Dynamic, ?b:Dynamic, ?c:Dynamic):String {
        if (isNumeric(a)) {
            return GetLocalizedStringPlural(text, text, toLong(a), GetCurrentLanguage(), asArgs(b));
        }
        return GetLocalizedStringPlural(text, Std.string(a), toLong(b), GetCurrentLanguage(), asArgs(c));
    }
    // PORT-NOTE: 同上，合并 _pn(context, text, textPlural, n, args) 与 _pn(context, text, n, args)。
    public function _pn(context:String, text:String, a:Dynamic, ?b:Dynamic, ?c:Dynamic, ?d:Dynamic):String {
        if (isNumeric(a)) {
            return GetLocalizedStringParticularPlural(context, text, text, toLong(a), GetCurrentLanguage(), asArgs(b));
        }
        return GetLocalizedStringParticularPlural(context, text, Std.string(a), toLong(b), GetCurrentLanguage(), asArgs(c));
    }
    public function GetLocalizedString(text:String, language:String, ?args:Array<Dynamic>):String {
        if (text == null || text.length == 0)
            return "";
        var str = TryGetLocalizedString(text, language, args);
        if (str != null)
            return str;
        return format(text, args);
    }
    public function TryGetLocalizedString(text:String, language:String, ?args:Array<Dynamic>):String {
        for (languagePack in loadedLanguagePacks) {
            if (languagePack == null)
                continue;
            var result = languagePack.TryGetString(language, text, args);
            if (result != null) {
                return result;
            }
        }
        return null;
    }
    public function GetLocalizedStringParticular(context:String, text:String, language:String, ?args:Array<Dynamic>):String {
        if (text == null || text.length == 0)
            return "";
        var str = TryGetLocalizedStringParticular(context, text, language, args);
        if (str != null)
            return str;
        return format(text, args);
    }
    public function TryGetLocalizedStringParticular(context:String, text:String, language:String, ?args:Array<Dynamic>):String {
        for (languagePack in loadedLanguagePacks) {
            if (languagePack == null)
                continue;
            var result = languagePack.TryGetStringParticular(language, context, text, args);
            if (result != null) {
                return result;
            }
        }
        return null;
    }
    public function GetLocalizedStringPlural(text:String, textPlural:String, n:haxe.Int64, language:String, ?args:Array<Dynamic>):String {
        if (text == null || text.length == 0)
            return "";
        var str = TryGetLocalizedStringPlural(text, textPlural, n, language, args);
        if (str != null)
            return str;
        return format(haxe.Int64.toInt(n) > 1 ? text : textPlural, args);
    }
    public function TryGetLocalizedStringPlural(text:String, textPlural:String, n:haxe.Int64, language:String, ?args:Array<Dynamic>):String {
        for (languagePack in loadedLanguagePacks) {
            if (languagePack == null)
                continue;
            var result = languagePack.TryGetStringPlural(language, text, textPlural, n, args);
            if (result != null) {
                return result;
            }
        }
        return null;
    }
    public function GetLocalizedStringParticularPlural(context:String, text:String, textPlural:String, n:haxe.Int64, language:String, ?args:Array<Dynamic>):String {
        if (text == null || text.length == 0)
            return "";
        var str = TryGetLocalizedStringParticularPlural(context, text, textPlural, n, language, args);
        if (str != null)
            return str;
        return format(haxe.Int64.toInt(n) > 1 ? text : textPlural, args);
    }
    public function TryGetLocalizedStringParticularPlural(context:String, text:String, textPlural:String, n:haxe.Int64, language:String, ?args:Array<Dynamic>):String {
        for (languagePack in loadedLanguagePacks) {
            if (languagePack == null)
                continue;
            var result = languagePack.TryGetStringParticularPlural(language, context, text, textPlural, n, args);
            if (result != null) {
                return result;
            }
        }
        return null;
    }
    public function GetLanguageName(language:String):String {
        try {
            var name = TryGetLocalizedStringParticular(LogicStrings.CONTEXT_LANGUAGE_NAME, CURRENT_LANGUAGE_NAME, language, null);
            if (name != null) {
                return name;
            }
            var cultureInfo = CultureInfo.GetCultureInfo(language);
            return '${cultureInfo.NativeName}(${language})';
        } catch (e:CultureNotFoundException) {
            return language;
        }
    }
    // PORT-NOTE: C# 有 GetCurrentLanguageSprite(Sprite) 与 (SpriteReference) 两个重载，
    // Haxe 不支持重载，按参数类型分派。
    public function GetCurrentLanguageSprite(sprite:Dynamic):Dynamic {
        return GetLocalizedSprite(sprite, GetCurrentLanguage());
    }
    // PORT-NOTE: 合并 C# 的 GetLocalizedSprite(Sprite, string)、GetLocalizedSprite(SpriteReference, string)
    // 与 GetLocalizedSprite(NamespaceID, string) 三个重载。
    public function GetLocalizedSprite(sprite:Dynamic, language:String):Dynamic {
        if (Std.isOfType(sprite, SpriteReference)) {
            var spriteRef:SpriteReference = cast sprite;
            if (spriteRef.IsSheet) {
                var sheet = GetLocalizedSpriteSheet(spriteRef.ID, language);
                if (sheet == null || spriteRef.Index < 0 || spriteRef.Index >= sheet.length)
                    return null;
                return sheet[spriteRef.Index];
            }
            return GetLocalizedSpriteByID(spriteRef.ID, language);
        }
        // PORT-NOTE: C# 重载 GetLocalizedSprite(NamespaceID, string)：Haxe 中 NamespaceID 是 abstract(String)，
        // 运行期无独立值，无法 Std.isOfType(x, NamespaceID)，故按底层 String 分派（值即 "nsp:path"）。
        if (Std.isOfType(sprite, String)) {
            return GetLocalizedSpriteByID(cast sprite, language);
        }
        var spr:Sprite = cast sprite;
        var spriteID = main.ResourceManager.GetSpriteReference(spr);
        if (!SpriteReference.IsValid(spriteID))
            return spr;
        var localized = GetLocalizedSprite(spriteID, language);
        return localized != null ? localized : spr;
    }
    public function GetLocalizedSpriteByID(spriteID:NamespaceID, language:String):Sprite {
        for (languagePack in loadedLanguagePacks) {
            if (languagePack == null)
                continue;
            var localizedSpr = languagePack.TryGetSprite(language, spriteID);
            if (localizedSpr != null)
                return localizedSpr;
        }
        return null;
    }
    public function GetLocalizedSpriteSheet(spriteID:NamespaceID, language:String):Array<Sprite> {
        for (languagePack in loadedLanguagePacks) {
            if (languagePack == null)
                continue;
            var localizedSpr = languagePack.TryGetSpriteSheet(language, spriteID);
            if (localizedSpr != null)
                return localizedSpr;
        }
        return null;
    }
    public function GetCurrentLanguage():String {
        return currentLanguage;
    }
    public function CallLanguageChanged(lang:String):Void {
        OnLanguageChanged.dispatch(lang);
    }
    public function GetAllLanguageCodes():Array<String> {
        return allLanguages.copy();
    }
    public function ValidateCurrentLanguage():Void {
        if (allLanguages.contains(GetCurrentLanguage()))
            return;
        Main.OptionsManager.SetLanguage(Lambda.find(allLanguages, l -> true));
    }
    private function Awake():Void {
        OptionsManager.OnOptionChangedString.add(OnOptionChangedStringCallback);
    }
    private function OnOptionChangedStringCallback(id:NamespaceID, value:String):Void {
        if (id == LogicOptionItemID.language) {
            if (value == null || value.length == 0) {
                value = GetEnvironmentLanguage();
            }
            currentLanguage = value;
            Main.LanguageManager.CallLanguageChanged(value);
        }
    }
    private static function GetEnvironmentLanguage():String {
        var culture = CultureInfo.CurrentCulture;
        var allLanguages = Global.Localization.GetAllLanguageCodes();
        for (language in allLanguages) {
            if (culture.Name == language)
                return language;
            var langCulture = new CultureInfo(language);
            if (culture.Parent == langCulture.Parent)
                return language;
        }
        return CN;
    }
    public function GetText(textKey:String, ?args:Array<Dynamic>):String {
        return _(textKey, args);
    }
    public function GetTextParticular(textKey:String, context:String, ?args:Array<Dynamic>):String {
        return _p(context, textKey, args);
    }
    public function GetTextPlural(textKey:String, textPlural:String, n:haxe.Int64, ?args:Array<Dynamic>):String {
        return _n(textKey, textPlural, n, args);
    }
    public function GetTextPluralParticular(textKey:String, textPlural:String, n:haxe.Int64, context:String, ?args:Array<Dynamic>):String {
        return _pn(context, textKey, textPlural, n, args);
    }

    public var OnLanguageChanged:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();
    public var Main(get, never):MainManager;
    function get_Main():MainManager return main;
    public static inline var CN:String = "zh-Hans";
    public static inline var EN:String = "en-US";
    public static inline var SOURCE_LANGUAGE:String = CN;

    // [TranslateMsg("当前语言名称", LogicStrings.CONTEXT_LANGUAGE_NAME)]
    public static inline var CURRENT_LANGUAGE_NAME:String = "中文";

    private var allLanguages:Array<String> = [SOURCE_LANGUAGE];
    private var currentLanguage:String = CN;
    private var main:MainManager = null;

    // ============================== LanguageManager_Pack.cs ==============================

    public function InitLanguagePacks():Void {
        // 加载所有语言包引用。
        var references = EvaluateAllLanguagePackReferences();
        for (reference in references) {
            LoadLanguagePackMetadata(reference);
        }

        // 加载启用的语言包列表。
        LoadEnabledLanguagePackList();
        SaveEnabledLanguagePackList();

        // 加载启用的语言包内容。
        LoadLanguagePacks();

        ValidateCurrentLanguage();
    }
    /// <summary>
    /// 刷新语言包引用列表。
    /// 获取所有外部语言包引用，去掉不存在的，加入新添加的。
    /// 然后再次检测
    /// </summary>
    /// <returns>语言包列表是否有变动。</returns>
    public function RefreshLanguagePackReferences():Bool {
        var references = EvaluateAllLanguagePackReferences();
        var removed = languagePackKeys().filter(k -> !references.map(r -> r.GetKey()).contains(k));
        var added = references.filter(r -> !languagePackMetadatas.exists(r.GetKey()));
        var changed = false;
        if (removed.length > 0) {
            for (remove in removed) {
                var reference = findLanguagePackReference(remove);
                if (reference != null) RemoveLanguagePackMetadata(reference);
            }
            changed = true;
        }
        if (added.length > 0) {
            for (add in added) {
                LoadLanguagePackMetadata(add);
            }
            changed = true;
        }
        return changed;
    }
    public function ReloadLanguagePacks(enabled:Array<LanguagePackReference>):Void {
        enabledLanguagePacks = [];
        for (r in enabled) {
            if (languagePackMetadatas.exists(r.GetKey())) enabledLanguagePacks.push(r);
        }
        SaveEnabledLanguagePackList();
        UnloadLanguagePacks();
        LoadLanguagePacks();
        ValidateCurrentLanguage();
    }

    // #region 导入
    public function GetImportKey(sourcePath:String):String {
        if (!File.Exists(sourcePath))
            return null;
        var fileName = Path.GetFileName(sourcePath);
        fileName = Path.ChangeExtension(fileName, ".zip");
        return fileName;
    }
    public function ImportLanguagePack(sourcePath:String):Void {
        if (!File.Exists(sourcePath))
            return;
        var fileName = Path.GetFileName(sourcePath);
        fileName = Path.ChangeExtension(fileName, ".zip");
        var destPath = Path.Combine(GetExternalLanguagePackDirectory(), fileName);
        FileHelper.ValidateDirectory(destPath);
        File.Copy(sourcePath, destPath);
    }
    public function ValidateLanguagePack(sourcePath:String):Bool {
        if (!File.Exists(sourcePath))
            return false;
        try {
            var reference = new ExternalLanguagePackReference(sourcePath, false);
            var metadata = reference.LoadMetadata(this);
            return metadata != null;
        } catch (e:Dynamic) {
            return false;
        }
    }
    // #endregion

    // #region 导出
    public function ExportLanguagePack(reference:LanguagePackReference, destPath:String):Bool {
        if (Std.isOfType(reference, BuiltinLanguagePackReference)) {
            var bytes = LoadBuiltinBytes();
            File.WriteAllBytes(destPath, bytes);
            return true;
        } else if (Std.isOfType(reference, ExternalLanguagePackReference)) {
            var external:ExternalLanguagePackReference = cast reference;
            var sourcePath = external.path;
            if (external.isDirectory) {
                CompressLanguagePack(sourcePath, destPath);
            } else {
                File.Copy(sourcePath, destPath, true);
            }
            return true;
        }
        return false;
    }
    // #endregion

    // #region 删除
    public function DeleteLanguagePack(reference:LanguagePackReference):Bool {
        if (!Std.isOfType(reference, ExternalLanguagePackReference))
            return false;
        var external:ExternalLanguagePackReference = cast reference;
        var sourcePath = external.path;
        if (external.isDirectory) {
            if (Directory.Exists(sourcePath)) {
                Directory.Delete(sourcePath, true);
                return true;
            }
        } else {
            if (File.Exists(sourcePath)) {
                File.Delete(sourcePath);
                return true;
            }
        }
        return false;
    }
    // #endregion

    // #region 语言包引用/元数据
    public function GetLanguagePackMetadata(reference:LanguagePackReference):LanguagePackMetadata {
        if (languagePackMetadatas.exists(reference.GetKey())) {
            return languagePackMetadatas.get(reference.GetKey());
        }
        return null;
    }
    public function GetAllLanguagePackReferences():Array<LanguagePackReference> {
        return languagePackReferences.copy();
    }
    private function EvaluateAllLanguagePackReferences():Array<LanguagePackReference> {
        var results:Array<LanguagePackReference> = [];
        results.push(builtinLanguagePackRef);

        // 外部引用。
        var dir = GetExternalLanguagePackDirectory();
        if (Directory.Exists(dir)) {
            // Zip语言包
            for (zip in Directory.EnumerateFiles(dir, "*.zip", SearchOption.TopDirectoryOnly)) {
                results.push(new ExternalLanguagePackReference(zip, false));
            }
            // 文件夹语言包
            for (langDir in Directory.EnumerateDirectories(dir)) {
                results.push(new ExternalLanguagePackReference(langDir, true));
            }
        }
        return results;
    }
    private function GetExternalLanguagePackDirectory():String {
        return Path.Combine(Application.persistentDataPath, externalLangaugePackDir);
    }
    private function LoadLanguagePackMetadata(reference:LanguagePackReference):Void {
        try {
            var metadata = reference.LoadMetadata(this);
            if (metadata != null)
                addLanguagePackMetadata(reference, metadata);
        } catch (e:Dynamic) {
            Debug.LogError('加载语言包引用${reference}失败：${e}');
        }
    }
    private function RemoveLanguagePackMetadata(reference:LanguagePackReference):Void {
        if (reference == null)
            return;
        var metadata = GetLanguagePackMetadata(reference);
        if (metadata != null && metadata.icon != null) {
            main.ResourceManager.RemoveCreatedSprite(metadata.icon, reference.GetKey(), "language_pack_icon");
        }
        languagePackMetadatas.remove(reference.GetKey());
        languagePackReferences.remove(reference);
    }
    // #endregion

    // #region 启用状态
    public function LoadEnabledLanguagePackList():Void {
        enabledLanguagePacks = [];
        var path = Path.Combine(Application.persistentDataPath, enabledPackListFileName);
        if (File.Exists(path)) {
            try {
                var stream = File.Open(path, FileMode.Open);
                var reader = new system.io.StreamReader(stream);
                var json = reader.ReadToEnd();
                stream.Dispose();
                var packList:EnabledLanguagePackList = JsonConvert.DeserializeObject(json, EnabledLanguagePackList);
                if (packList != null) {
                    for (key in packList.enabled) {
                        var reference = Lambda.find(languagePackReferences, r -> r.GetKey() == key);
                        if (reference != null) {
                            enabledLanguagePacks.push(reference);
                        }
                    }
                }
            } catch (e:Dynamic) {
                Debug.LogError('读取启用的语言包列表失败：${e}');
            }
        }
        if (!enabledLanguagePacks.contains(builtinLanguagePackRef)) {
            enabledLanguagePacks.push(builtinLanguagePackRef);
        }
    }
    public function SaveEnabledLanguagePackList():Void {
        try {
            var path = Path.Combine(Application.persistentDataPath, enabledPackListFileName);
            var list = new EnabledLanguagePackList();
            for (reference in enabledLanguagePacks) {
                list.enabled.push(reference.GetKey());
            }
            var json = JsonConvert.SerializeObject(list);
            var stream = File.Open(path, FileMode.Create);
            var writer = new system.io.StreamWriter(stream);
            writer.Write(json);
            writer.Dispose();
        } catch (e:Dynamic) {
            Debug.LogError('保存启用的语言包列表失败：${e}');
        }
    }
    public function GetEnabledLanguagePackList():Array<LanguagePackReference> {
        return enabledLanguagePacks.copy();
    }
    // #endregion

    // #region 加载语言包
    public function LoadLanguagePacks():Void {
        for (reference in enabledLanguagePacks) {
            var languagePack = reference.LoadLanguagePack(this);
            if (languagePack == null)
                continue;
            loadedLanguagePacks.push(languagePack);
            for (lang in languagePack.GetLanguages()) {
                if (!allLanguages.contains(lang)) {
                    allLanguages.push(lang);
                }
            }
        }
    }
    // #endregion

    // #region 卸载语言包
    public function UnloadLanguagePacks():Void {
        for (enabledLanguagePack in loadedLanguagePacks) {
            UnloadLanguagePack(enabledLanguagePack);
        }

        allLanguages = [];
        allLanguages.push(SOURCE_LANGUAGE);
        loadedLanguagePacks = [];
    }
    public function UnloadLanguagePack(pack:LanguagePack):Void {
        for (lang in pack.GetLanguages()) {
            var assets = pack.GetLanguageAssets(lang);
            if (assets == null)
                continue;
            for (key in assets.Sprites.keys()) {
                var sprite = assets.Sprites.get(key);
                main.ResourceManager.RemoveCreatedSprite(sprite, key.toString(), GetLanguagePackSpriteCategory(pack.Key));
            }
            for (key in assets.SpriteSheets.keys()) {
                var sheet = assets.SpriteSheets.get(key);
                for (i in 0...sheet.length) {
                    var sprite = sheet[i];
                    main.ResourceManager.RemoveCreatedSprite(sprite, '${key}[${i}]', GetLanguagePackSpriteCategory(pack.Key));
                }
            }
        }
    }
    // #endregion

    // #region 加载内置
    public function LoadBuiltinBytes():Bytes {
        var op = Addressables.LoadAssetAsync("LanguagePack");
        var textAsset:TextAsset = op.Task;
        return textAsset.bytes;
    }
    // #endregion

    // #region 加载Zip元数据
    // PORT-NOTE: C# 有 (string key, string path)、(string key, byte[] bytes)、(string key, Stream stream)
    // 三个重载，Haxe 不支持重载，按 source 的运行期类型分派。
    public function ReadLanguagePackMetadataZip(key:String, source:Dynamic):LanguagePackMetadata {
        if (Std.isOfType(source, String)) {
            var stream = File.Open(cast source, FileMode.Open);
            var result = ReadLanguagePackMetadataZip(key, stream);
            stream.Dispose();
            return result;
        }
        if (Std.isOfType(source, Bytes)) {
            return ReadLanguagePackMetadataZip(key, new MemoryStream(cast source));
        }
        return ReadLanguagePackMetadataZipStream(key, cast source);
    }
    private function ReadLanguagePackMetadataZipStream(key:String, stream:Stream):LanguagePackMetadata {
        try {
            var archive = new ZipArchive(stream);

            var metadataEntry = archive.GetEntry(METADATA_FILENAME);
            if (metadataEntry == null)
                return null;

            var json = ZipArchiveHelper.ReadString(metadataEntry, Encoding.UTF8);
            var metadata:LanguagePackMetadata = JsonConvert.DeserializeObject(json, LanguagePackMetadata);
            if (metadata != null) {
                var iconEntry = archive.GetEntry(ICON_FILENAME);
                if (iconEntry != null) {
                    var bytes = ZipArchiveHelper.ReadBytes(iconEntry);
                    var texture = mvz2.sprites.SpriteHelper.LoadTextureFromBytes(bytes);
                    metadata.icon = Main.ResourceManager.CreateSprite(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(texture.width * 0.5, texture.height * 0.5), key, "language_pack_icon");
                }
            }
            archive.Dispose();
            return metadata;
        } catch (e:Dynamic) {
            Debug.LogError('读取语言包Zip的元数据失败：${e}');
            return null;
        }
    }
    // #endregion

    // #region 加载Zip语言包
    // PORT-NOTE: 同 ReadLanguagePackMetadataZip，合并了 path/byte[]/Stream 三个重载。
    public function ReadLanguagePackZip(key:String, source:Dynamic):LanguagePack {
        if (Std.isOfType(source, String)) {
            var stream = File.Open(cast source, FileMode.Open);
            var result = ReadLanguagePackZip(key, stream);
            stream.Dispose();
            return result;
        }
        if (Std.isOfType(source, Bytes)) {
            return ReadLanguagePackZip(key, new MemoryStream(cast source));
        }
        return ReadLanguagePackZipStream(key, cast source);
    }
    private function ReadLanguagePackZipStream(key:String, stream:Stream):LanguagePack {
        try {
            var archive = new ZipArchive(stream);
            var languagePack = new LanguagePack(key);
            var entries = archive.Entries.copy();
            for (entry in entries) {
                if (entry.Name == null || entry.Name.length == 0)
                    continue;

                if (Path.GetExtension(entry.FullName) == null || Path.GetExtension(entry.FullName).length == 0)
                    continue;

                var fullPath = entry.FullName.split("\\").join("/");
                var splitedPaths = fullPath.split(Path.DirectorySeparatorChar).join("|").split(Path.AltDirectorySeparatorChar).join("|").split("|");
                if (splitedPaths.length < 3 || splitedPaths[0] != "assets")
                    continue;
                var nsp = splitedPaths[1];
                var lang = splitedPaths[2].split("_").join("-");
                if (splitedPaths.length == 4) {
                    var asset = languagePack.GetOrCreateLanguageAsset(lang);
                    var filename = splitedPaths[3];
                    if (Path.GetExtension(filename) == ".mo") {
                        var filenameWithoutExt = Path.GetFileNameWithoutExtension(filename);
                        var catalog = ZipArchiveHelper.ReadCatalog(entry, lang);
                        asset.catalogs.set(filenameWithoutExt, catalog);
                    } else if (filename == SPRITE_MANIFEST_FILENAME) {
                        var manifestJson = ZipArchiveHelper.ReadString(entry, Encoding.UTF8);
                        var manifest:LocalizedSpriteManifest = JsonConvert.DeserializeObject(manifestJson, LocalizedSpriteManifest);
                        if (manifest != null) {
                            if (manifest.sprites != null) {
                                for (localizedSprite in manifest.sprites) {
                                    var texturePath = Path.Combine(Path.Combine(Path.Combine(Path.Combine(splitedPaths[0], splitedPaths[1]), splitedPaths[2]), "sprites"), localizedSprite.texture);
                                    var textureEntry = Lambda.find(entries, e -> e.FullName.split("\\").join("/") == texturePath.split("\\").join("/"));

                                    if (textureEntry == null || localizedSprite.name == null || localizedSprite.name.length == 0)
                                        continue;
                                    var resID = new NamespaceID(nsp, localizedSprite.name);
                                    var bytes = ZipArchiveHelper.ReadBytes(textureEntry);
                                    var sprite = ReadEntryToSprite(resID, bytes, localizedSprite, key);
                                    asset.Sprites.set(resID, sprite);
                                }
                            }
                            if (manifest.spritesheets != null) {
                                for (localizedSpritesheet in manifest.spritesheets) {
                                    var texturePath = Path.Combine(Path.Combine(Path.Combine(Path.Combine(splitedPaths[0], splitedPaths[1]), splitedPaths[2]), "spritesheets"), localizedSpritesheet.texture);
                                    var textureEntry = Lambda.find(entries, e -> e.FullName.split("\\").join("/") == texturePath.split("\\").join("/"));

                                    if (textureEntry == null || localizedSpritesheet.name == null || localizedSpritesheet.name.length == 0)
                                        continue;
                                    var resID = new NamespaceID(nsp, localizedSpritesheet.name);
                                    var bytes = ZipArchiveHelper.ReadBytes(textureEntry);
                                    var spritesheet = ReadEntryToSpriteSheet(resID, bytes, localizedSpritesheet, key);
                                    asset.SpriteSheets.set(resID, spritesheet);
                                }
                            }
                        }
                    }
                }
            }
            archive.Dispose();
            return languagePack;
        } catch (e:Dynamic) {
            Debug.LogError('读取语言包Zip失败：${e}');
            return null;
        }
    }
    // #endregion

    // #region 加载文件夹元数据
    public function ReadLanguagePackMetadataDirectory(key:String, path:String):LanguagePackMetadata {
        var metadataPath = Path.Combine(path, METADATA_FILENAME);
        if (!File.Exists(metadataPath))
            return null;
        try {
            var metadataStream = File.Open(metadataPath, FileMode.Open);
            var metadataReader = new system.io.StreamReader(metadataStream);
            var json = metadataReader.ReadToEnd();
            metadataStream.Dispose();
            var metadata:LanguagePackMetadata = JsonConvert.DeserializeObject(json, LanguagePackMetadata);
            if (metadata != null) {
                var iconPath = Path.Combine(path, ICON_FILENAME);
                if (File.Exists(iconPath)) {
                    var bytes = File.ReadAllBytes(iconPath);

                    var texture = mvz2.sprites.SpriteHelper.LoadTextureFromBytes(bytes);
                    metadata.icon = Main.ResourceManager.CreateSprite(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(texture.width * 0.5, texture.height * 0.5), key, "language_pack_icon");
                }
            }
            return metadata;
        } catch (e:Dynamic) {
            Debug.LogError('读取语言包${path}的元数据失败：${e}');
            return null;
        }
    }
    // #endregion

    // #region 加载文件夹语言包
    public function ReadLanguagePackDirectory(key:String, path:String):LanguagePack {
        try {
            var languagePack = new LanguagePack(key);
            var assetsDir = Path.Combine(path, "assets");
            for (nspDir in Directory.EnumerateDirectories(assetsDir)) {
                var nsp = Path.GetRelativePath(assetsDir, nspDir);
                for (langDir in Directory.EnumerateDirectories(nspDir)) {
                    var lang = Path.GetRelativePath(nspDir, langDir);
                    LoadPackLanguageDirectroy(nsp, lang, langDir, languagePack, key);
                }
            }
            return languagePack;
        } catch (e:Dynamic) {
            Debug.LogError('读取语言包${path}失败：${e}');
            return null;
        }
    }
    private function LoadPackLanguageDirectroy(nsp:String, lang:String, dir:String, pack:LanguagePack, key:String):Void {
        var asset = pack.GetOrCreateLanguageAsset(lang);
        // 加载文本
        for (moFile in Directory.EnumerateFiles(dir, "*.mo")) {
            var filenameWithoutExt = Path.GetFileNameWithoutExtension(moFile);
            var stream = File.Open(moFile, FileMode.Open);
            var catalog = new Catalog(stream, new CultureInfo(lang));
            stream.Dispose();
            asset.catalogs.set(filenameWithoutExt, catalog);
        }
        // 加载贴图
        var manifestPath = Path.Combine(dir, SPRITE_MANIFEST_FILENAME);
        if (File.Exists(manifestPath)) {
            var manifestStream = File.Open(manifestPath, FileMode.Open);
            var manifestReader = new system.io.StreamReader(manifestStream);
            var manifestJson = manifestReader.ReadToEnd();
            manifestStream.Dispose();

            var manifest:LocalizedSpriteManifest = JsonConvert.DeserializeObject(manifestJson, LocalizedSpriteManifest);
            if (manifest != null) {
                if (manifest.sprites != null) {
                    for (localizedSprite in manifest.sprites) {
                        var texturePath = Path.Combine(Path.Combine(dir, "sprites"), localizedSprite.texture).split("/").join("\\");

                        if (!File.Exists(texturePath) || localizedSprite.name == null || localizedSprite.name.length == 0)
                            continue;
                        var resID = new NamespaceID(nsp, localizedSprite.name);
                        var bytes = File.ReadAllBytes(texturePath);

                        var sprite = ReadEntryToSprite(resID, bytes, localizedSprite, key);
                        asset.Sprites.set(resID, sprite);
                    }
                }
                if (manifest.spritesheets != null) {
                    for (localizedSpritesheet in manifest.spritesheets) {
                        var texturePath = Path.Combine(Path.Combine(dir, "spritesheets"), localizedSpritesheet.texture).split("/").join("\\");

                        if (!File.Exists(texturePath) || localizedSpritesheet.name == null || localizedSpritesheet.name.length == 0)
                            continue;
                        var resID = new NamespaceID(nsp, localizedSpritesheet.name);
                        var bytes = File.ReadAllBytes(texturePath);

                        var spritesheet = ReadEntryToSpriteSheet(resID, bytes, localizedSpritesheet, key);
                        asset.SpriteSheets.set(resID, spritesheet);
                    }
                }
            }
        }
    }
    // #endregion

    // #region 加载贴图
    private function ReadEntryToSprite(spriteId:NamespaceID, bytes:Bytes, meta:LocalizedSprite, key:String):Sprite {
        try {
            var texture2D = mvz2.sprites.SpriteHelper.LoadTextureFromBytes(bytes);
            var spriteRect = new Rect(0, 0, texture2D.width, texture2D.height);
            var spritePivot:Vector2;
            if (meta != null) {
                spritePivot = new Vector2(meta.pivotX, meta.pivotY);
            } else {
                spritePivot = new Vector2(0.5, 0.5);
            }
            var spr = main.ResourceManager.CreateSprite(texture2D, spriteRect, spritePivot, spriteId.toString(), GetLanguagePackSpriteCategory(key));
            return spr;
        } catch (e:Dynamic) {
            Debug.LogError('An exception thrown when loading sprite ${spriteId} from a language pack: ${e}');
            return Main.ResourceManager.GetDefaultSpriteClone();
        }
    }
    private function ReadEntryToSpriteSheet(spriteId:NamespaceID, bytes:Bytes, meta:LocalizedSpriteSheet, key:String):Array<Sprite> {
        try {
            var texture2D = mvz2.sprites.SpriteHelper.LoadTextureFromBytes(bytes);
            var spriteInfos:Array<{rect:Rect, pivot:Vector2}>;
            if (meta != null && meta.slices != null) {
                spriteInfos = [];
                for (i in 0...meta.slices.length) {
                    var slice = meta.slices[i];
                    var rect = new Rect(slice.x, slice.y, slice.width, slice.height);
                    var pivot = new Vector2(slice.pivotX, slice.pivotY);
                    spriteInfos.push({rect: rect, pivot: pivot});
                }
            } else {
                spriteInfos = [{rect: new Rect(0, 0, texture2D.width, texture2D.height), pivot: new Vector2(0.5, 0.5)}];
            }
            var sprites = new Array<Sprite>();
            sprites.resize(spriteInfos.length);
            for (i in 0...sprites.length) {
                var info = spriteInfos[i];
                var rect = info.rect;
                rect.width = Math.min(rect.width, texture2D.width);
                rect.height = Math.min(rect.height, texture2D.height);
                var spr = main.ResourceManager.CreateSprite(texture2D, rect, info.pivot, '${spriteId}[${i}]', GetLanguagePackSpriteCategory(key));
                sprites[i] = spr;
            }
            return sprites;
        } catch (e:Dynamic) {
            Debug.LogError('An exception thrown when loading spritesheet ${spriteId} from a language pack: ${e}');
            var length = (meta != null && meta.slices != null) ? meta.slices.length : 1;
            var sprites = new Array<Sprite>();
            sprites.resize(length);
            for (i in 0...sprites.length) {
                sprites[i] = Main.ResourceManager.GetDefaultSpriteClone();
            }
            return sprites;
        }
    }
    private function GetLanguagePackSpriteCategory(key:String):String {
        return 'language-${key}';
    }
    // #endregion

    // #region 压缩ZIP
    public static function CompressLanguagePack(sourceDirectory:String, destPath:String):Void {
        FileHelper.ValidateDirectory(destPath);
        var files = Directory.GetFiles(sourceDirectory, "*", SearchOption.AllDirectories);
        var stream = File.Open(destPath, FileMode.Create);
        var archive = new ZipArchive(stream, ZipArchiveMode.Create);

        for (filePath in files) {
            if (Path.GetExtension(filePath) == ".meta")
                continue;
            var path = filePath.split("\\").join("/");
            var entryName = Path.GetRelativePath(sourceDirectory, path);
            ZipFileExtensions.CreateEntryFromFile(archive, path, entryName);
        }
        archive.Dispose();
        stream.Dispose();
    }
    // #endregion

    public static inline var METADATA_FILENAME:String = "pack.json";
    public static inline var ICON_FILENAME:String = "pack.png";
    public static inline var SPRITE_MANIFEST_FILENAME:String = "sprite_manifest.json";
    private var externalLangaugePackDir:String = "language_packs";
    private var enabledPackListFileName:String = "language_packs.json";
    // PORT-NOTE: C# 的 Dictionary<LanguagePackReference, LanguagePackMetadata> 依赖引用类型的 Equals/GetHashCode，
    // Haxe Map 对对象键使用引用相等，故改为以 GetKey() 为键，并额外维护引用数组以保留键的枚举顺序。
    private var languagePackMetadatas:Map<String, LanguagePackMetadata> = new Map();
    private var languagePackReferences:Array<LanguagePackReference> = [];
    private var enabledLanguagePacks:Array<LanguagePackReference> = [];
    private var loadedLanguagePacks:Array<LanguagePack> = [];
    private var builtinLanguagePackRef:BuiltinLanguagePackReference = new BuiltinLanguagePackReference();

    private function addLanguagePackMetadata(reference:LanguagePackReference, metadata:LanguagePackMetadata):Void {
        if (!languagePackMetadatas.exists(reference.GetKey())) {
            languagePackReferences.push(reference);
        }
        languagePackMetadatas.set(reference.GetKey(), metadata);
    }
    private function languagePackKeys():Array<String> {
        var keys:Array<String> = [];
        for (k in languagePackMetadatas.keys()) keys.push(k);
        return keys;
    }
    private function findLanguagePackReference(key:String):LanguagePackReference {
        return Lambda.find(languagePackReferences, r -> r.GetKey() == key);
    }

    static function isNumeric(value:Dynamic):Bool {
        if (Std.isOfType(value, Int) || Std.isOfType(value, Float)) return true;
        return isInt64(value);
    }
    // PORT-NOTE: haxe.Int64 是 abstract，无法用 Std.isOfType 判断，改为检查其内部字段。
    static function isInt64(value:Dynamic):Bool {
        return value != null && Reflect.hasField(value, "high") && Reflect.hasField(value, "low");
    }
    static function toLong(value:Dynamic):haxe.Int64 {
        if (value == null) return haxe.Int64.ofInt(0);
        if (isInt64(value)) return cast value;
        return haxe.Int64.ofInt(Std.int(value));
    }
    static function asArgs(value:Dynamic):Array<Dynamic> {
        if (value == null) return [];
        if (Std.isOfType(value, Array)) return cast value;
        return [value];
    }
    static function format(text:String, args:Array<Dynamic>):String {
        if (args == null || args.length == 0) return text;
        var result = text;
        for (i in 0...args.length) {
            // PORT-NOTE: 必须用**双引号拼接**而不是 `"{${i}}"`。Haxe 只在**单引号**字符串里做
            // `${...}` 插值，双引号里的 `${i}` 是字面量 —— 于是 `"{${i}}"` 求值成 4 个字符的
            // 字符串 `{${i}}`，`split` 永远匹配不到 `{0}`，参数**从未被替换**。
            // 实测后果（标题页）：`版本{0}` 原样显示，而不是 `版本0.1.0`。
            // 这条路径是**源语言（CN）与任何无语言包的字符串**的兜底，命中面很广
            //（`Catalog.formatString` 用的是正确的拼接写法，只有这里漏了）。
            result = result.split("{" + i + "}").join(Std.string(args[i]));
        }
        return result;
    }
}

// PORT-NOTE: 原 LanguageManager_Pack.cs 中的嵌套私有类提升为同模块的顶层私有类。
private class BuiltinLanguagePackReference extends LanguagePackReference {
    public function new() {
        super();
    }
    // PORT-NOTE: Haxe 中属性不能直接 override，改为覆写 getter（基类属性仍走虚分派）。
    override function get_IsBuiltin():Bool return true;
    public function Equals(obj:Dynamic):Bool {
        return Std.isOfType(obj, BuiltinLanguagePackReference);
    }
    override public function GetHashCode():Int {
        return super.GetHashCode();
    }
    override public function GetKey():String {
        return "builtin*";
    }
    override public function GetFileName():String {
        return "builtin";
    }
    override public function LoadMetadata(manager:LanguageManager):LanguagePackMetadata {
        var bytes = manager.LoadBuiltinBytes();
        return manager.ReadLanguagePackMetadataZip(GetKey(), bytes);
    }
    override public function LoadLanguagePack(manager:LanguageManager):LanguagePack {
        var bytes = manager.LoadBuiltinBytes();
        return manager.ReadLanguagePackZip(GetKey(), bytes);
    }
}

private class ExternalLanguagePackReference extends LanguagePackReference {
    public var path:String;
    public var isDirectory:Bool;

    public function new(path:String, isDirectory:Bool) {
        super();
        this.path = path;
        this.isDirectory = isDirectory;
    }

    public function Equals(obj:Dynamic):Bool {
        return Std.isOfType(obj, ExternalLanguagePackReference) && {
            var other:ExternalLanguagePackReference = cast obj;
            path == other.path && isDirectory == other.isDirectory;
        };
    }
    override public function GetHashCode():Int {
        // PORT-NOTE: C# 为 HashCode.Combine(path, isDirectory)；Haxe 用字符串哈希替代。
        return LanguagePackReference.HashString(path + (isDirectory ? "1" : "0"));
    }
    override public function GetKey():String {
        if (isDirectory) {
            return '<${Path.GetFileName(path)}>';
        } else {
            return Path.GetFileName(path);
        }
    }
    override public function GetFileName():String {
        return Path.GetFileName(path);
    }
    override public function LoadMetadata(manager:LanguageManager):LanguagePackMetadata {
        if (isDirectory) {
            return manager.ReadLanguagePackMetadataDirectory(GetKey(), path);
        }
        return manager.ReadLanguagePackMetadataZip(GetKey(), path);
    }
    override public function LoadLanguagePack(manager:LanguageManager):LanguagePack {
        if (isDirectory) {
            return manager.ReadLanguagePackDirectory(GetKey(), path);
        }
        return manager.ReadLanguagePackZip(GetKey(), path);
    }
}

// abstract
class LanguagePackReference {
    public var IsBuiltin(get, never):Bool;
    function get_IsBuiltin():Bool return false;
    public function new() {}
    // abstract
    public function LoadMetadata(manager:LanguageManager):LanguagePackMetadata {
        throw "abstract";
    }
    // abstract
    public function LoadLanguagePack(manager:LanguageManager):LanguagePack {
        throw "abstract";
    }
    // abstract
    public function GetKey():String {
        throw "abstract";
    }
    // abstract
    public function GetFileName():String {
        throw "abstract";
    }
    public function ToString():String {
        return GetKey();
    }
    // PORT-NOTE: C# 覆写 Object.GetHashCode（基类为默认实现）；Haxe 的 String 无 GetHashCode，用简易字符串哈希替代。
    public function GetHashCode():Int {
        return HashString(GetKey());
    }
    public static function HashString(s:String):Int {
        var h = 0;
        if (s != null) {
            for (i in 0...s.length)
                h = 31 * h + s.charCodeAt(i);
        }
        return h & 0x7FFFFFFF;
    }
}
