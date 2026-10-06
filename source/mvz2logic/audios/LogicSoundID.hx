// Ported from: Assets/Scripts/Logic/Audios/LogicSoundID.cs
package mvz2logic.audios;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicSoundID
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var achievement(get, never):NamespaceID;
	private static var _achievement:NamespaceID;
	static function get_achievement():NamespaceID
	{
		if (_achievement == null) _achievement = Get("achievement");
		return _achievement;
	}
	public static var buzzer(get, never):NamespaceID;
	private static var _buzzer:NamespaceID;
	static function get_buzzer():NamespaceID
	{
		if (_buzzer == null) _buzzer = Get("buzzer");
		return _buzzer;
	}
	public static var cashRegister(get, never):NamespaceID;
	private static var _cashRegister:NamespaceID;
	static function get_cashRegister():NamespaceID
	{
		if (_cashRegister == null) _cashRegister = Get("cash_register");
		return _cashRegister;
	}
	public static var click(get, never):NamespaceID;
	private static var _click:NamespaceID;
	static function get_click():NamespaceID
	{
		if (_click == null) _click = Get("click");
		return _click;
	}
	public static var dialogItemShow(get, never):NamespaceID;
	private static var _dialogItemShow:NamespaceID;
	static function get_dialogItemShow():NamespaceID
	{
		if (_dialogItemShow == null) _dialogItemShow = Get("dialog_item_show");
		return _dialogItemShow;
	}
	public static var dialogItemHide(get, never):NamespaceID;
	private static var _dialogItemHide:NamespaceID;
	static function get_dialogItemHide():NamespaceID
	{
		if (_dialogItemHide == null) _dialogItemHide = Get("dialog_item_hide");
		return _dialogItemHide;
	}
	public static var fastForward(get, never):NamespaceID;
	private static var _fastForward:NamespaceID;
	static function get_fastForward():NamespaceID
	{
		if (_fastForward == null) _fastForward = Get("fast_forward");
		return _fastForward;
	}
	public static var hit(get, never):NamespaceID;
	private static var _hit:NamespaceID;
	static function get_hit():NamespaceID
	{
		if (_hit == null) _hit = Get("hit");
		return _hit;
	}
	public static var loseMusic(get, never):NamespaceID;
	private static var _loseMusic:NamespaceID;
	static function get_loseMusic():NamespaceID
	{
		if (_loseMusic == null) _loseMusic = Get("lose_music");
		return _loseMusic;
	}
	public static var paper(get, never):NamespaceID;
	private static var _paper:NamespaceID;
	static function get_paper():NamespaceID
	{
		if (_paper == null) _paper = Get("paper");
		return _paper;
	}
	public static var pause(get, never):NamespaceID;
	private static var _pause:NamespaceID;
	static function get_pause():NamespaceID
	{
		if (_pause == null) _pause = Get("pause");
		return _pause;
	}
	public static var pickaxe(get, never):NamespaceID;
	private static var _pickaxe:NamespaceID;
	static function get_pickaxe():NamespaceID
	{
		if (_pickaxe == null) _pickaxe = Get("pickaxe");
		return _pickaxe;
	}
	public static var readySetBuild(get, never):NamespaceID;
	private static var _readySetBuild:NamespaceID;
	static function get_readySetBuild():NamespaceID
	{
		if (_readySetBuild == null) _readySetBuild = Get("ready_set_build");
		return _readySetBuild;
	}
	public static var scream(get, never):NamespaceID;
	private static var _scream:NamespaceID;
	static function get_scream():NamespaceID
	{
		if (_scream == null) _scream = Get("scream");
		return _scream;
	}
	public static var slowDown(get, never):NamespaceID;
	private static var _slowDown:NamespaceID;
	static function get_slowDown():NamespaceID
	{
		if (_slowDown == null) _slowDown = Get("slow_down");
		return _slowDown;
	}
	public static var spring(get, never):NamespaceID;
	private static var _spring:NamespaceID;
	static function get_spring():NamespaceID
	{
		if (_spring == null) _spring = Get("spring");
		return _spring;
	}
	public static var tap(get, never):NamespaceID;
	private static var _tap:NamespaceID;
	static function get_tap():NamespaceID
	{
		if (_tap == null) _tap = Get("tap");
		return _tap;
	}
	public static var travel(get, never):NamespaceID;
	private static var _travel:NamespaceID;
	static function get_travel():NamespaceID
	{
		if (_travel == null) _travel = Get("travel");
		return _travel;
	}

	private static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}
}
