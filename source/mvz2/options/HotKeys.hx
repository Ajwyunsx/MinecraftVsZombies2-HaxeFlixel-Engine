// Ported from: Assets/Scripts/MVZ2/Options/HotKeys.cs
package mvz2.options;

import mvz2.managers.MainManager;
import pvzengine.NamespaceID;

class HotKeys {
    // PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
    // （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
    // 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
    public static var pickaxe(get, never):NamespaceID;
    private static var _pickaxe:NamespaceID;
    static function get_pickaxe():NamespaceID
    {
    	if (_pickaxe == null) _pickaxe = Get("pickaxe");
    	return _pickaxe;
    }
    public static var starshard(get, never):NamespaceID;
    private static var _starshard:NamespaceID;
    static function get_starshard():NamespaceID
    {
    	if (_starshard == null) _starshard = Get("starshard");
    	return _starshard;
    }
    public static var trigger(get, never):NamespaceID;
    private static var _trigger:NamespaceID;
    static function get_trigger():NamespaceID
    {
    	if (_trigger == null) _trigger = Get("trigger");
    	return _trigger;
    }
    public static var fastForward(get, never):NamespaceID;
    private static var _fastForward:NamespaceID;
    static function get_fastForward():NamespaceID
    {
    	if (_fastForward == null) _fastForward = Get("fast_forward");
    	return _fastForward;
    }
    public static var console(get, never):NamespaceID;
    private static var _console:NamespaceID;
    static function get_console():NamespaceID
    {
    	if (_console == null) _console = Get("console");
    	return _console;
    }
    public static var hpBars(get, never):NamespaceID;
    private static var _hpBars:NamespaceID;
    static function get_hpBars():NamespaceID
    {
    	if (_hpBars == null) _hpBars = Get("hp_bars");
    	return _hpBars;
    }
    public static var blueprint1(get, never):NamespaceID;
    private static var _blueprint1:NamespaceID;
    static function get_blueprint1():NamespaceID
    {
    	if (_blueprint1 == null) _blueprint1 = Get("blueprint_1");
    	return _blueprint1;
    }
    public static var blueprint2(get, never):NamespaceID;
    private static var _blueprint2:NamespaceID;
    static function get_blueprint2():NamespaceID
    {
    	if (_blueprint2 == null) _blueprint2 = Get("blueprint_2");
    	return _blueprint2;
    }
    public static var blueprint3(get, never):NamespaceID;
    private static var _blueprint3:NamespaceID;
    static function get_blueprint3():NamespaceID
    {
    	if (_blueprint3 == null) _blueprint3 = Get("blueprint_3");
    	return _blueprint3;
    }
    public static var blueprint4(get, never):NamespaceID;
    private static var _blueprint4:NamespaceID;
    static function get_blueprint4():NamespaceID
    {
    	if (_blueprint4 == null) _blueprint4 = Get("blueprint_4");
    	return _blueprint4;
    }
    public static var blueprint5(get, never):NamespaceID;
    private static var _blueprint5:NamespaceID;
    static function get_blueprint5():NamespaceID
    {
    	if (_blueprint5 == null) _blueprint5 = Get("blueprint_5");
    	return _blueprint5;
    }
    public static var blueprint6(get, never):NamespaceID;
    private static var _blueprint6:NamespaceID;
    static function get_blueprint6():NamespaceID
    {
    	if (_blueprint6 == null) _blueprint6 = Get("blueprint_6");
    	return _blueprint6;
    }
    public static var blueprint7(get, never):NamespaceID;
    private static var _blueprint7:NamespaceID;
    static function get_blueprint7():NamespaceID
    {
    	if (_blueprint7 == null) _blueprint7 = Get("blueprint_7");
    	return _blueprint7;
    }
    public static var blueprint8(get, never):NamespaceID;
    private static var _blueprint8:NamespaceID;
    static function get_blueprint8():NamespaceID
    {
    	if (_blueprint8 == null) _blueprint8 = Get("blueprint_8");
    	return _blueprint8;
    }
    public static var blueprint9(get, never):NamespaceID;
    private static var _blueprint9:NamespaceID;
    static function get_blueprint9():NamespaceID
    {
    	if (_blueprint9 == null) _blueprint9 = Get("blueprint_9");
    	return _blueprint9;
    }
    public static var blueprint10(get, never):NamespaceID;
    private static var _blueprint10:NamespaceID;
    static function get_blueprint10():NamespaceID
    {
    	if (_blueprint10 == null) _blueprint10 = Get("blueprint_10");
    	return _blueprint10;
    }
    // PORT-NOTE: 同上的启动期求值问题：数组元素是惰性的，数组本身也必须惰性。
    private static var blueprintList(get, never):Array<NamespaceID>;
    private static var _blueprintList:Array<NamespaceID>;
    static function get_blueprintList():Array<NamespaceID>
    {
    	if (_blueprintList == null)
    		_blueprintList = [blueprint1, blueprint2, blueprint3, blueprint4, blueprint5,
    			blueprint6, blueprint7, blueprint8, blueprint9, blueprint10];
    	return _blueprintList;
    }
    public static function GetBlueprintHotKey(index:Int):NamespaceID {
        return blueprintList[index];
    }
    public static function Get(path:String):NamespaceID {
        return new NamespaceID(MainManager.Instance.BuiltinNamespace, path);
    }
}
