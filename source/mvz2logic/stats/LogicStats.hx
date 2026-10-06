// Ported from: Assets/Scripts/Logic/Stats/LogicStats.cs
package mvz2logic.stats;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicStats
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var CATEGORY_ENEMY_NEUTRALIZE(get, never):NamespaceID;
	private static var _cATEGORY_ENEMY_NEUTRALIZE:NamespaceID;
	static function get_CATEGORY_ENEMY_NEUTRALIZE():NamespaceID
	{
		if (_cATEGORY_ENEMY_NEUTRALIZE == null) _cATEGORY_ENEMY_NEUTRALIZE = Get("enemy_neutralize");
		return _cATEGORY_ENEMY_NEUTRALIZE;
	}
	public static var CATEGORY_MAX_ENDLESS_FLAGS(get, never):NamespaceID;
	private static var _cATEGORY_MAX_ENDLESS_FLAGS:NamespaceID;
	static function get_CATEGORY_MAX_ENDLESS_FLAGS():NamespaceID
	{
		if (_cATEGORY_MAX_ENDLESS_FLAGS == null) _cATEGORY_MAX_ENDLESS_FLAGS = Get("max_endless_flags");
		return _cATEGORY_MAX_ENDLESS_FLAGS;
	}
	public static function Get(path:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, path);
	}
}
