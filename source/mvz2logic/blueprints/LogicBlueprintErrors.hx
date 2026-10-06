// Ported from: Assets/Scripts/Logic/Blueprints/LogicBlueprintErrors.cs
package mvz2logic.blueprints;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicBlueprintErrors
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var invalid(get, never):NamespaceID;
	private static var _invalid:NamespaceID;
	static function get_invalid():NamespaceID
	{
		if (_invalid == null) _invalid = Get("invalid");
		return _invalid;
	}
	public static var recharging(get, never):NamespaceID;
	private static var _recharging:NamespaceID;
	static function get_recharging():NamespaceID
	{
		if (_recharging == null) _recharging = Get("recharging");
		return _recharging;
	}
	public static var notEnoughEnergy(get, never):NamespaceID;
	private static var _notEnoughEnergy:NamespaceID;
	static function get_notEnoughEnergy():NamespaceID
	{
		if (_notEnoughEnergy == null) _notEnoughEnergy = Get("not_enough_energy");
		return _notEnoughEnergy;
	}
	static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}

	private function new() {}
}
