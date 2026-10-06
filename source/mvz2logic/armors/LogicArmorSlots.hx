// Ported from: Assets/Scripts/Logic/Armors/LogicArmorSlots.cs
package mvz2logic.armors;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicArmorSlots
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var main(get, never):NamespaceID;
	private static var _main:NamespaceID;
	static function get_main():NamespaceID
	{
		if (_main == null) _main = Get("main");
		return _main;
	}
	public static var shield(get, never):NamespaceID;
	private static var _shield:NamespaceID;
	static function get_shield():NamespaceID
	{
		if (_shield == null) _shield = Get("shield");
		return _shield;
	}

	private static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}
}
