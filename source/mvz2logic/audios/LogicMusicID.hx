// Ported from: Assets/Scripts/Logic/Audios/LogicMusicID.cs
package mvz2logic.audios;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicMusicID
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var mainmenu(get, never):NamespaceID;
	private static var _mainmenu:NamespaceID;
	static function get_mainmenu():NamespaceID
	{
		if (_mainmenu == null) _mainmenu = Get("mainmenu");
		return _mainmenu;
	}
	public static var choosing(get, never):NamespaceID;
	private static var _choosing:NamespaceID;
	static function get_choosing():NamespaceID
	{
		if (_choosing == null) _choosing = Get("choosing");
		return _choosing;
	}

	private static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}
}
