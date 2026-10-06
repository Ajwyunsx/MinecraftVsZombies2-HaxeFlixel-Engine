// Ported from: Assets/Scripts/Logic/Unlocks/LogicUnlockGroupID.cs
package mvz2logic.unlocks;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicUnlockGroupID
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var starshard(get, never):NamespaceID;
	private static var _starshard:NamespaceID;
	static function get_starshard():NamespaceID
	{
		if (_starshard == null) _starshard = Get("starshard");
		return _starshard;
	}
	public static var almanac(get, never):NamespaceID;
	private static var _almanac:NamespaceID;
	static function get_almanac():NamespaceID
	{
		if (_almanac == null) _almanac = Get("almanac");
		return _almanac;
	}
	public static var trigger(get, never):NamespaceID;
	private static var _trigger:NamespaceID;
	static function get_trigger():NamespaceID
	{
		if (_trigger == null) _trigger = Get("trigger");
		return _trigger;
	}

	public static var chapter_Dream(get, never):NamespaceID;
	private static var _chapter_Dream:NamespaceID;
	static function get_chapter_Dream():NamespaceID
	{
		if (_chapter_Dream == null) _chapter_Dream = Get("chapter.dream");
		return _chapter_Dream;
	}
	public static var store(get, never):NamespaceID;
	private static var _store:NamespaceID;
	static function get_store():NamespaceID
	{
		if (_store == null) _store = Get("store");
		return _store;
	}
	public static var gensokyo(get, never):NamespaceID;
	private static var _gensokyo:NamespaceID;
	static function get_gensokyo():NamespaceID
	{
		if (_gensokyo == null) _gensokyo = Get("gensokyo");
		return _gensokyo;
	}

	public static var musicRoom(get, never):NamespaceID;
	private static var _musicRoom:NamespaceID;
	static function get_musicRoom():NamespaceID
	{
		if (_musicRoom == null) _musicRoom = Get("music_room");
		return _musicRoom;
	}

	public static var arcade(get, never):NamespaceID;
	private static var _arcade:NamespaceID;
	static function get_arcade():NamespaceID
	{
		if (_arcade == null) _arcade = Get("arcade");
		return _arcade;
	}
	public static var commandBlock(get, never):NamespaceID;
	private static var _commandBlock:NamespaceID;
	static function get_commandBlock():NamespaceID
	{
		if (_commandBlock == null) _commandBlock = Get("command_block");
		return _commandBlock;
	}

	public static var hpBar(get, never):NamespaceID;
	private static var _hpBar:NamespaceID;
	static function get_hpBar():NamespaceID
	{
		if (_hpBar == null) _hpBar = Get("hp_bar");
		return _hpBar;
	}
	private static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}
}
