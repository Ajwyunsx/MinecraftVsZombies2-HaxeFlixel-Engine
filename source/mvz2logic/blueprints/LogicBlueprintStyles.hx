// Ported from: Assets/Scripts/Logic/Blueprints/LogicBlueprintStyles.cs
package mvz2logic.blueprints;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicBlueprintStyles
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var normal(get, never):NamespaceID;
	private static var _normal:NamespaceID;
	static function get_normal():NamespaceID
	{
		if (_normal == null) _normal = Get("normal");
		return _normal;
	}
	public static var commandBlock(get, never):NamespaceID;
	private static var _commandBlock:NamespaceID;
	static function get_commandBlock():NamespaceID
	{
		if (_commandBlock == null) _commandBlock = Get("command_block");
		return _commandBlock;
	}
	public static var upgrade(get, never):NamespaceID;
	private static var _upgrade:NamespaceID;
	static function get_upgrade():NamespaceID
	{
		if (_upgrade == null) _upgrade = Get("upgrade");
		return _upgrade;
	}
	public static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}

	private function new() {}
}
