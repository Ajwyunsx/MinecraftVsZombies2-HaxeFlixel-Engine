// Ported from: Assets/Scripts/Logic/Options/Widgets/LogicOptionWidgetID.cs
// PORT-NOTE: 同文件的 LogicOptionWidgetNames 已拆为独立模块 mvz2logic/options/LogicOptionWidgetNames.hx。
package mvz2logic.options;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicOptionWidgetID
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var language(get, never):NamespaceID;
	private static var _language:NamespaceID;
	static function get_language():NamespaceID
	{
		if (_language == null) _language = Get(LogicOptionWidgetNames.language);
		return _language;
	}
	public static var blueprintWarnings(get, never):NamespaceID;
	private static var _blueprintWarnings:NamespaceID;
	static function get_blueprintWarnings():NamespaceID
	{
		if (_blueprintWarnings == null) _blueprintWarnings = Get(LogicOptionWidgetNames.blueprintWarnings);
		return _blueprintWarnings;
	}
	public static var commandBlockMode(get, never):NamespaceID;
	private static var _commandBlockMode:NamespaceID;
	static function get_commandBlockMode():NamespaceID
	{
		if (_commandBlockMode == null) _commandBlockMode = Get(LogicOptionWidgetNames.commandBlockMode);
		return _commandBlockMode;
	}
	public static var skipTalks(get, never):NamespaceID;
	private static var _skipTalks:NamespaceID;
	static function get_skipTalks():NamespaceID
	{
		if (_skipTalks == null) _skipTalks = Get(LogicOptionWidgetNames.skipTalks);
		return _skipTalks;
	}
	public static var vibration(get, never):NamespaceID;
	private static var _vibration:NamespaceID;
	static function get_vibration():NamespaceID
	{
		if (_vibration == null) _vibration = Get(LogicOptionWidgetNames.vibration);
		return _vibration;
	}
	public static var fullscreen(get, never):NamespaceID;
	private static var _fullscreen:NamespaceID;
	static function get_fullscreen():NamespaceID
	{
		if (_fullscreen == null) _fullscreen = Get(LogicOptionWidgetNames.fullscreen);
		return _fullscreen;
	}
	public static var resolution(get, never):NamespaceID;
	private static var _resolution:NamespaceID;
	static function get_resolution():NamespaceID
	{
		if (_resolution == null) _resolution = Get(LogicOptionWidgetNames.resolution);
		return _resolution;
	}
	public static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}
}
