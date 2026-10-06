// Ported from: Assets/Scripts/Logic/Level/LogicAreaTags.cs
package mvz2logic.level;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicAreaTags
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var day(get, never):NamespaceID;
	private static var _day:NamespaceID;
	static function get_day():NamespaceID
	{
		if (_day == null) _day = Get("day");
		return _day;
	}
	public static var night(get, never):NamespaceID;
	private static var _night:NamespaceID;
	static function get_night():NamespaceID
	{
		if (_night == null) _night = Get("night");
		return _night;
	}
	public static var water(get, never):NamespaceID;
	private static var _water:NamespaceID;
	static function get_water():NamespaceID
	{
		if (_water == null) _water = Get("water");
		return _water;
	}
	public static var noWater(get, never):NamespaceID;
	private static var _noWater:NamespaceID;
	static function get_noWater():NamespaceID
	{
		if (_noWater == null) _noWater = Get("no_water");
		return _noWater;
	}

	private static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}

	private function new() {}
}
