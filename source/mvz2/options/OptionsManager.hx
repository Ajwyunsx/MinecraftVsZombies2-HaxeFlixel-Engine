// Ported from: Assets/Scripts/MVZ2/Options/OptionsManager.cs
// Ported from: Assets/Scripts/MVZ2/Options/OptionsManager_KeyBindings.cs (partial class 合并)
package mvz2.options;
import mvz2.options.KeyBinding.KeyBindingMeta;  // IMPORTAUTO

import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSignal;
import mongodb.bson.BsonExtensionMethods;
import mongodb.bson.io.JsonReader;
import mvz2.io.FileHelper;
import mvz2.managers.MainManager;
import mvz2.metas.OptionItemMeta;
import mvz2logic.games.IGlobalOptions;
import mvz2logic.localization.LogicStrings;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.OptionItemType;
import mvz2logic.serialization.SerializeHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.io.File;
import system.io.Path;
import system.io.SeekOrigin;
import system.io.StreamReader;
import system.io.StreamWriter;
import unity.KeyCode;
import unity.PlayerPrefs;
import tools.Ref;
using mvz2.io.FileHelper;  // EXTUSING
using mvz2logic.serialization.SerializeHelper;  // EXTUSING

class OptionsManager extends unity.MonoBehaviour implements IGlobalOptions {
    public function new() {
        super();
    }

    public function InitOptions():Void {
        options = new Options();
        InitKeyBindings();
    }
    public function LoadOptions():Void {
        LoadOptionsFromFile();
        UpdateOptions();
    }
    public function SaveOptions():Void {
        SaveOptionsToFile();
    }

    private function LoadOptionsFromFile():Void {
        if (options == null)
            return;
        var path = GetOptionsFilePath();
        if (!File.Exists(path))
            return;
        try {
            // 打开文件流
            var stream = Main.FileManager.OpenFileRead(path);
            var streamReader = new StreamReader(stream);
            // PORT-NOTE: C# 用 JsonReader 逐 token 读取；Haxe 侧 SerializeHelper.ReadBson 接收整段字符串，
            // 故这里按“逐行读取”的方式传入文本（设置文件每行保存一个 BSON/JSON 文档）。
            var header = LoadOptionsHeader(streamReader.ReadLine());

            switch (header.version) {
                case VERSION_1:
                    LoadOptionsV1(streamReader.ReadLine());
                default:
                    stream.Seek(0, SeekOrigin.Begin);
                    var v0Reader = new StreamReader(stream);
                    LoadOptionsV0(v0Reader.ReadLine());
                    v0Reader.Dispose();
            }
            stream.Dispose();
            streamReader.Dispose();
        } catch (e:Dynamic) {
            Log.LogError('读取设置文件失败：${e}');
        }
    }
    private function SaveOptionsToFile():Void {
        if (options == null)
            return;
        var path = GetOptionsFilePath();
        try {
            FileHelper.ValidateDirectory(path);

            // 打开文件流
            var stream = Main.FileManager.OpenFileWrite(path);
            var writer = new StreamWriter(stream);

            // 写入文件首信息
            SaveOptionsHeader(writer);

            // 写入文件内容
            SaveOptionsV1(writer);
            writer.Dispose();
            stream.Dispose();
        } catch (e:Dynamic) {
            Log.LogError('保存设置文件失败：${e}');
        }
    }
    public function GetOptionsFilePath():String {
        return Path.Combine(unity.Application.persistentDataPath, "options.json");
    }

    // #region 选项
    public function SetOptionBool(id:NamespaceID, value:Bool):Void {
        options.SetOptionBool(id, value);
        CallOptionChangedBool(id, value);
    }
    public function SetOptionInt(id:NamespaceID, value:Int):Void {
        options.SetOptionInt(id, value);
        CallOptionChangedInt(id, value);
    }
    public function SetOptionFloat(id:NamespaceID, value:Float):Void {
        options.SetOptionFloat(id, value);
        CallOptionChangedFloat(id, value);
    }
    public function SetOptionString(id:NamespaceID, value:String):Void {
        options.SetOptionString(id, value);
        CallOptionChangedString(id, value);
    }
    public function SetOptionID(id:NamespaceID, value:NamespaceID):Void {
        options.SetOptionID(id, value);
        CallOptionChangedID(id, value);
    }

    // PORT-NOTE: IGlobalOptions 定义为 out 参数，Haxe 统一用 tools.Ref<T> 容器实现。
    public function TryGetOptionBool(id:NamespaceID, value:Ref<Bool>):Bool {
        var v = options.TryGetOptionBool(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }
    public function TryGetOptionInt(id:NamespaceID, value:Ref<Int>):Bool {
        var v = options.TryGetOptionInt(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }
    public function TryGetOptionFloat(id:NamespaceID, value:Ref<Float>):Bool {
        var v = options.TryGetOptionFloat(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }
    public function TryGetOptionString(id:NamespaceID, value:Ref<String>):Bool {
        var v = options.TryGetOptionString(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }
    public function TryGetOptionID(id:NamespaceID, value:Ref<Null<NamespaceID>>):Bool {
        var v = options.TryGetOptionID(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }

    public function GetOptionBool(id:NamespaceID):Bool {
        var ref:Ref<Bool> = new Ref<Bool>(false);
        return TryGetOptionBool(id, ref) ? ref.value : GetDefaultOptionValueBool(id);
    }
    public function GetOptionInt(id:NamespaceID):Int {
        var ref:Ref<Int> = new Ref<Int>(0);
        return TryGetOptionInt(id, ref) ? ref.value : GetDefaultOptionValueInt(id);
    }
    public function GetOptionFloat(id:NamespaceID):Float {
        var ref:Ref<Float> = new Ref<Float>(0);
        return TryGetOptionFloat(id, ref) ? ref.value : GetDefaultOptionValueFloat(id);
    }
    public function GetOptionString(id:NamespaceID):String {
        var ref:Ref<String> = new Ref<String>(null);
        return TryGetOptionString(id, ref) ? ref.value : GetDefaultOptionValueString(id);
    }
    public function GetOptionID(id:NamespaceID):Null<NamespaceID> {
        var ref:Ref<Null<NamespaceID>> = new Ref<Null<NamespaceID>>(null);
        return TryGetOptionID(id, ref) ? ref.value : GetDefaultOptionValueID(id);
    }


    public function GetDefaultOptionValueBool(id:NamespaceID):Bool return GetOrSetOptionDefaultValue(defaultOptionValuesBool, id, false);
    public function GetDefaultOptionValueInt(id:NamespaceID):Int return GetOrSetOptionDefaultValue(defaultOptionValuesInt, id, 0);
    public function GetDefaultOptionValueFloat(id:NamespaceID):Float return GetOrSetOptionDefaultValue(defaultOptionValuesFloat, id, 0);
    public function GetDefaultOptionValueString(id:NamespaceID):String return GetOrSetOptionDefaultValue(defaultOptionValuesString, id, "");
    public function GetDefaultOptionValueID(id:NamespaceID):Null<NamespaceID> return GetOrSetOptionDefaultValueID(id);
    @:generic
    private function GetOrSetOptionDefaultValue<T>(dictionary:Map<NamespaceID, T>, id:NamespaceID, fallback:T):T {
        if (!dictionary.exists(id)) {
            var value = GetOptionItemMetaDefaultValue(id, fallback);
            dictionary.set(id, value);
        }
        return dictionary.get(id);
    }
    private function GetOrSetOptionDefaultValueID(id:NamespaceID):Null<NamespaceID> {
        if (!defaultOptionValuesID.exists(id)) {
            defaultOptionValuesID.set(id, GetOptionItemMetaDefaultValueID(id));
        }
        return defaultOptionValuesID.get(id);
    }
    @:generic
    private function GetOptionItemMetaDefaultValue<T>(id:NamespaceID, fallback:T):T {
        var itemMeta = Main.ResourceManager.GetOptionItemMeta(id);
        if (itemMeta != null && Std.isOfType(itemMeta.DefaultValue, T)) {
            return cast itemMeta.DefaultValue;
        }
        return fallback;
    }
    private function GetOptionItemMetaDefaultValueID(id:NamespaceID):Null<NamespaceID> {
        var itemMeta = Main.ResourceManager.GetOptionItemMeta(id);
        // PORT-NOTE: C# `itemMeta.DefaultValue is NamespaceID`；Haxe 中 NamespaceID 是 abstract(String)，
        // 运行期无独立值，ID 类型（OptionItemType.ID）的 DefaultValue 由 GetAttributeNamespaceID 产出，
        // 运行期就是 String，故改为判定 String（本函数只被 ID 选项调用）。
        if (itemMeta != null && Std.isOfType(itemMeta.DefaultValue, String)) {
            return cast itemMeta.DefaultValue;
        }
        return null;
    }

    private function UpdateOptions():Void {
        var metasID = Main.ResourceManager.GetAllOptionItemsID();
        for (id in metasID) {
            var meta = Main.ResourceManager.GetOptionItemMeta(id);
            if (meta == null)
                continue;
            switch (meta.Type) {
                case OptionItemType.Boolean:
                    CallOptionChangedBool(id, GetOptionBool(id));
                case OptionItemType.Int:
                    CallOptionChangedInt(id, GetOptionInt(id));
                case OptionItemType.Float:
                    CallOptionChangedFloat(id, GetOptionFloat(id));
                case OptionItemType.String:
                    CallOptionChangedString(id, GetOptionString(id));
                case OptionItemType.ID:
                    CallOptionChangedID(id, GetOptionID(id));
            }
        }
    }
    private function CallOptionChangedBool(id:NamespaceID, value:Bool):Void {
        OnOptionChangedBool.dispatch(id, value);
    }
    private function CallOptionChangedInt(id:NamespaceID, value:Int):Void {
        OnOptionChangedInt.dispatch(id, value);
    }
    private function CallOptionChangedFloat(id:NamespaceID, value:Float):Void {
        OnOptionChangedFloat.dispatch(id, value);
    }
    private function CallOptionChangedString(id:NamespaceID, value:String):Void {
        OnOptionChangedString.dispatch(id, value);
    }
    private function CallOptionChangedID(id:NamespaceID, value:NamespaceID):Void {
        OnOptionChangedID.dispatch(id, value);
    }
    // #endregion

    // #region 选项文件首部
    private function SaveOptionsHeader(writer:StreamWriter):Void {
        // 写入文件首信息
        var header = new SerializableOptionsHeader(CURRENT_OPTION_VERSION);
        var headerJson = BsonExtensionMethods.ToBson(header);
        // PORT-NOTE: 移植层的 ToBson 返回 JSON 文本的字节，写入时转回字符串（与读取端按行解析一致）。
        writer.WriteLine(headerJson.toString());
    }
    private function LoadOptionsHeader(text:String):SerializableOptionsHeader {
        // 读取首行数据
        return SerializeHelper.ReadBson(text, SerializableOptionsHeader);
    }
    // #endregion

    // #region 选项版本0
    private function LoadOptionsV0(text:String):Void {
        var seri:SerializableOptions = SerializeHelper.ReadBson(text, SerializableOptions);
        options.LoadFromSerializableV0(seri);
        LoadOptionsFromPrefs();
    }
    private function LoadOptionsFromPrefs():Void {
        LoadOptionFromPrefsID(LogicOptionItemID.difficulty, PREFS_DIFFICULTY);
        LoadOptionFromPrefsBool(LogicOptionItemID.swapTrigger, PREFS_SWAP_TRIGGER);
        LoadOptionFromPrefsBool(LogicOptionItemID.vibration, PREFS_VIBRATION);
        LoadOptionFromPrefsBool(LogicOptionItemID.bloodAndGore, PREFS_BLOOD_AND_GORE);
        LoadOptionFromPrefsBool(LogicOptionItemID.pauseOnFocusLost, PREFS_PAUSE_ON_FOCUS_LOST);
        LoadOptionFromPrefsBool(LogicOptionItemID.skipTalks, PREFS_SKIP_ALL_TALKS);
        LoadOptionFromPrefsBool(LogicOptionItemID.showSponsorNames, PREFS_SHOW_SPONSOR_NAMES);

        LoadOptionFromPrefsFloat(LogicOptionItemID.musicVolume, PREFS_MUSIC_VOLUME);
        LoadOptionFromPrefsFloat(LogicOptionItemID.soundVolume, PREFS_SOUND_VOLUME);
        LoadOptionFromPrefsFloat(LogicOptionItemID.fastForwardMultiplier, PREFS_FASTFORWARD_MULTIPLIER);
        LoadOptionFromPrefsFloat(LogicOptionItemID.animationFrequency, PREFS_ANIMATION_FREQUENCY);
        LoadOptionFromPrefsFloat(LogicOptionItemID.particleAmount, PREFS_PARTICLE_AMOUNT);
        LoadOptionFromPrefsFloat(LogicOptionItemID.shakeAmount, PREFS_SHAKE_AMOUNT);

        LoadOptionFromPrefsString(LogicOptionItemID.language, PREFS_LANGUAGE);
    }
    private function LoadOptionFromPrefsBool(optionID:NamespaceID, prefKey:String):Void {
        if (!options.ContainsOptionID(optionID) && PlayerPrefs.HasKey(prefKey)) {
            var prefs = PlayerPrefs.GetInt(prefKey);
            var value = IntToBool(prefs);
            PlayerPrefs.DeleteKey(prefKey);
            options.SetOptionBool(optionID, value);
        }
    }
    private function LoadOptionFromPrefsFloat(optionID:NamespaceID, prefKey:String):Void {
        if (!options.ContainsOptionID(optionID) && PlayerPrefs.HasKey(prefKey)) {
            var value = PlayerPrefs.GetFloat(prefKey);
            PlayerPrefs.DeleteKey(prefKey);
            options.SetOptionFloat(optionID, value);
        }
    }
    private function LoadOptionFromPrefsString(optionID:NamespaceID, prefKey:String):Void {
        if (!options.ContainsOptionID(optionID) && PlayerPrefs.HasKey(prefKey)) {
            var value = PlayerPrefs.GetString(prefKey);
            PlayerPrefs.DeleteKey(prefKey);
            options.SetOptionString(optionID, value);
        }
    }
    private function LoadOptionFromPrefsID(optionID:NamespaceID, prefKey:String):Void {
        if (!options.ContainsOptionID(optionID) && PlayerPrefs.HasKey(prefKey)) {
            var name = PlayerPrefs.GetString(prefKey);
            var value = NamespaceID.Parse(name, Main.BuiltinNamespace);
            PlayerPrefs.DeleteKey(prefKey);
            options.SetOptionID(optionID, value);
        }
    }
    // #endregion

    // #region 选项版本1
    private function SaveOptionsV1(writer:StreamWriter):Void {
        // 写入文件内容
        var body = options.ToSerializable();
        var bodyJson = BsonExtensionMethods.ToBson(body);
        // PORT-NOTE: 同上，字节转字符串后按行写入。
        writer.WriteLine(bodyJson.toString());
    }
    private function LoadOptionsV1(text:String):Void {
        var body:SerializableOptionsV1 = SerializeHelper.ReadBson(text, SerializableOptionsV1);
        options.LoadFromSerializableV1(body);
    }
    // #endregion

    // #region PlayerPrefs
    private static function GetPlayerPrefsBool(key:String, defaultValue:Bool):Bool {
        if (!PlayerPrefs.HasKey(key)) {
            PlayerPrefs.SetInt(key, BoolToInt(defaultValue));
        }
        return IntToBool(PlayerPrefs.GetInt(key));
    }
    private static function GetPlayerPrefsInt(key:String, defaultValue:Int):Int {
        if (!PlayerPrefs.HasKey(key)) {
            PlayerPrefs.SetInt(key, defaultValue);
        }
        return PlayerPrefs.GetInt(key);
    }
    private static function GetPlayerPrefsString(key:String, defaultValue:String):String {
        if (!PlayerPrefs.HasKey(key)) {
            PlayerPrefs.SetString(key, defaultValue);
        }
        return PlayerPrefs.GetString(key);
    }
    private static function GetPlayerPrefsFloat(key:String, defaultValue:Float):Float {
        if (!PlayerPrefs.HasKey(key)) {
            PlayerPrefs.SetFloat(key, defaultValue);
        }
        return PlayerPrefs.GetFloat(key);
    }
    // #endregion

    private static function IntToBool(value:Int):Bool {
        return value > 0;
    }
    private static function BoolToInt(value:Bool):Int {
        return value ? 1 : 0;
    }
    public var Main(get, never):MainManager;
    function get_Main():MainManager return MainManager.Instance;
    public static var OnOptionChangedBool:FlxTypedSignal<NamespaceID->Bool->Void> = new FlxTypedSignal<NamespaceID->Bool->Void>();
    public static var OnOptionChangedInt:FlxTypedSignal<NamespaceID->Int->Void> = new FlxTypedSignal<NamespaceID->Int->Void>();
    public static var OnOptionChangedFloat:FlxTypedSignal<NamespaceID->Float->Void> = new FlxTypedSignal<NamespaceID->Float->Void>();
    public static var OnOptionChangedString:FlxTypedSignal<NamespaceID->String->Void> = new FlxTypedSignal<NamespaceID->String->Void>();
    public static var OnOptionChangedID:FlxTypedSignal<NamespaceID->NamespaceID->Void> = new FlxTypedSignal<NamespaceID->NamespaceID->Void>();

    private var defaultOptionValuesBool:Map<NamespaceID, Bool> = new Map();
    private var defaultOptionValuesInt:Map<NamespaceID, Int> = new Map();
    private var defaultOptionValuesFloat:Map<NamespaceID, Float> = new Map();
    private var defaultOptionValuesString:Map<NamespaceID, String> = new Map();
    private var defaultOptionValuesID:Map<NamespaceID, NamespaceID> = new Map();

    public static inline var VERSION_1:Int = 1;
    public static inline var CURRENT_OPTION_VERSION:Int = VERSION_1;

    public static inline var PREFS_LANGUAGE:String = "Language";
    public static inline var PREFS_DIFFICULTY:String = "Difficulty";
    public static inline var PREFS_SWAP_TRIGGER:String = "SwapTrigger";
    public static inline var PREFS_VIBRATION:String = "Vibration";
    public static inline var PREFS_BLOOD_AND_GORE:String = "BloodAndGore";
    public static inline var PREFS_PAUSE_ON_FOCUS_LOST:String = "PauseOnFocusLost";
    public static inline var PREFS_SKIP_ALL_TALKS:String = "SkipAllTalks";
    public static inline var PREFS_SHOW_SPONSOR_NAMES:String = "ShowSponsorNames";

    public static inline var PREFS_MUSIC_VOLUME:String = "MusicVolume";
    public static inline var PREFS_SOUND_VOLUME:String = "SoundVolume";
    public static inline var PREFS_FASTFORWARD_MULTIPLIER:String = "FastForwardMultiplier";
    public static inline var PREFS_ANIMATION_FREQUENCY:String = "AnimationFrequency";
    public static inline var PREFS_PARTICLE_AMOUNT:String = "ParticleAmount";
    public static inline var PREFS_SHAKE_AMOUNT:String = "ShakeAmount";

    private var options:Options = null;

    // ============================== OptionsManager_KeyBindings.cs ==============================

    // #region 按键绑定
    public function GetKeyBinding(hotkey:NamespaceID):KeyCode {
        var code = options.keyBindings.TryGetKeyBinding(hotkey, KeyCode.None);
        // PORT-NOTE: C# 使用 TryGetKeyBinding 的 out 参数判断是否找到；
        // Haxe 版本用 KeyCode.None 作为“未找到”的标记（None 也不会被设置为有效按键）。
        if (code != KeyCode.None) {
            return code;
        }
        return GetDefaultKeyBinding(hotkey);
    }
    public function GetBlueprintKeyBinding(index:Int):KeyCode {
        var keyID = HotKeys.GetBlueprintHotKey(index);
        return GetKeyBinding(keyID);
    }
    public function SetKeyBinding(hotkey:NamespaceID, code:KeyCode):Void {
        options.keyBindings.SetKeyBinding(hotkey, code);
        CallKeybindingChanged(hotkey, code);
        SaveOptionsToFile();
    }
    public function ResetKeyBindings():Void {
        options.keyBindings.Reset();
        CallKeybindingsReset();
        SaveOptionsToFile();
    }
    public function GetHotkeyNameKey(hotkey:NamespaceID):String {
        var meta = GetKeybindingMeta(hotkey);
        if (meta == null)
            return HOTKEY_NAME_UNKNOWN;
        return meta.Name;
    }
    public function GetDefaultKeyBinding(hotkey:NamespaceID):KeyCode {
        var meta = GetKeybindingMeta(hotkey);
        if (meta == null)
            return KeyCode.None;
        return meta.DefaultCode;
    }
    public function GetAllKeyBindings():Array<NamespaceID> {
        var keys:Array<NamespaceID> = [];
        for (key in keyBindingMetas.keys()) keys.push(key);
        return keys;
    }
    public function GetKeybindingMeta(hotkey:NamespaceID):KeyBindingMeta {
        if (keyBindingMetas.exists(hotkey)) {
            return keyBindingMetas.get(hotkey);
        }
        return null;
    }
    private function InitKeyBindings():Void {
        AddKeyBindingMeta(HotKeys.pickaxe, KeyCode.Q, HOTKEY_NAME_PICKAXE);
        AddKeyBindingMeta(HotKeys.starshard, KeyCode.W, HOTKEY_NAME_STARSHARD);
        AddKeyBindingMeta(HotKeys.trigger, KeyCode.BackQuote, HOTKEY_NAME_TRIGGER);
        AddKeyBindingMeta(HotKeys.fastForward, KeyCode.F, HOTKEY_NAME_FASTFORWARD);
        AddKeyBindingMeta(HotKeys.hpBars, KeyCode.H, HOTKEY_NAME_HP_BARS);
        AddKeyBindingMeta(HotKeys.console, KeyCode.Slash, HOTKEY_NAME_CONSOLE);
        AddKeyBindingMeta(HotKeys.blueprint1, KeyCode.Alpha1, HOTKEY_NAME_BLUEPRINT1);
        AddKeyBindingMeta(HotKeys.blueprint2, KeyCode.Alpha2, HOTKEY_NAME_BLUEPRINT2);
        AddKeyBindingMeta(HotKeys.blueprint3, KeyCode.Alpha3, HOTKEY_NAME_BLUEPRINT3);
        AddKeyBindingMeta(HotKeys.blueprint4, KeyCode.Alpha4, HOTKEY_NAME_BLUEPRINT4);
        AddKeyBindingMeta(HotKeys.blueprint5, KeyCode.Alpha5, HOTKEY_NAME_BLUEPRINT5);
        AddKeyBindingMeta(HotKeys.blueprint6, KeyCode.Alpha6, HOTKEY_NAME_BLUEPRINT6);
        AddKeyBindingMeta(HotKeys.blueprint7, KeyCode.Alpha7, HOTKEY_NAME_BLUEPRINT7);
        AddKeyBindingMeta(HotKeys.blueprint8, KeyCode.Alpha8, HOTKEY_NAME_BLUEPRINT8);
        AddKeyBindingMeta(HotKeys.blueprint9, KeyCode.Alpha9, HOTKEY_NAME_BLUEPRINT9);
        AddKeyBindingMeta(HotKeys.blueprint10, KeyCode.Alpha0, HOTKEY_NAME_BLUEPRINT10);
    }
    private static function CallKeybindingChanged(hotkey:NamespaceID, code:KeyCode):Void {
        OnKeybindingChanged.dispatch(hotkey, code);
    }
    private static function CallKeybindingsReset():Void {
        OnKeybindingsReset.dispatch();
    }
    private function AddKeyBindingMeta(hotkey:NamespaceID, defaultCode:KeyCode, name:String):Void {
        keyBindingMetas.set(hotkey, new KeyBindingMeta(hotkey, defaultCode, name));
    }
    public static var OnKeybindingChanged:FlxTypedSignal<NamespaceID->KeyCode->Void> = new FlxTypedSignal<NamespaceID->KeyCode->Void>();
    public static var OnKeybindingsReset:FlxSignal = new FlxSignal();
    private var keyBindingMetas:Map<NamespaceID, KeyBindingMeta> = new Map();

    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_UNKNOWN:String = "？？？";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_PICKAXE:String = "铁镐";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_STARSHARD:String = "星之碎片";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_TRIGGER:String = "触发器";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_FASTFORWARD:String = "快进";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_HP_BARS:String = "血条";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_CONSOLE:String = "控制台";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT1:String = "蓝图1";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT2:String = "蓝图2";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT3:String = "蓝图3";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT4:String = "蓝图4";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT5:String = "蓝图5";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT6:String = "蓝图6";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT7:String = "蓝图7";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT8:String = "蓝图8";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT9:String = "蓝图9";
    // [TranslateMsg("按键名", LogicStrings.CONTEXT_HOTKEY_NAME)]
    public static inline var HOTKEY_NAME_BLUEPRINT10:String = "蓝图10";
    // #endregion
}
