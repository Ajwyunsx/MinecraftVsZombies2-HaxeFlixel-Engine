// Ported from: Assets/Scripts/Logic/HeldItems/LogicHeldTypes.cs
package mvz2logic.helditems;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicHeldTypes
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var pickaxe(get, never):NamespaceID;
	private static var _pickaxe:NamespaceID;
	static function get_pickaxe():NamespaceID
	{
		if (_pickaxe == null) _pickaxe = Get(LogicHeldItemNames.pickaxe);
		return _pickaxe;
	}
	public static var starshard(get, never):NamespaceID;
	private static var _starshard:NamespaceID;
	static function get_starshard():NamespaceID
	{
		if (_starshard == null) _starshard = Get(LogicHeldItemNames.starshard);
		return _starshard;
	}
	public static var trigger(get, never):NamespaceID;
	private static var _trigger:NamespaceID;
	static function get_trigger():NamespaceID
	{
		if (_trigger == null) _trigger = Get(LogicHeldItemNames.trigger);
		return _trigger;
	}
	public static var sword(get, never):NamespaceID;
	private static var _sword:NamespaceID;
	static function get_sword():NamespaceID
	{
		if (_sword == null) _sword = Get(LogicHeldItemNames.sword);
		return _sword;
	}
	public static var none(get, never):NamespaceID;
	private static var _none:NamespaceID;
	static function get_none():NamespaceID
	{
		if (_none == null) _none = Get(LogicHeldItemNames.none);
		return _none;
	}
	public static var blueprint(get, never):NamespaceID;
	private static var _blueprint:NamespaceID;
	static function get_blueprint():NamespaceID
	{
		if (_blueprint == null) _blueprint = Get(LogicHeldItemNames.blueprint);
		return _blueprint;
	}
	public static var conveyor(get, never):NamespaceID;
	private static var _conveyor:NamespaceID;
	static function get_conveyor():NamespaceID
	{
		if (_conveyor == null) _conveyor = Get(LogicHeldItemNames.conveyor);
		return _conveyor;
	}
	public static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}

	private function new() {}
}
