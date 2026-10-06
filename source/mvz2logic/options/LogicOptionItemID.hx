// Ported from: Assets/Scripts/Logic/Options/LogicOptionItemID.cs
// PORT-NOTE: 同文件的 LogicOptionItemNames 已拆为独立模块 mvz2logic/options/LogicOptionItemNames.hx。
package mvz2logic.options;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicOptionItemID
{
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var language(get, never):NamespaceID;
	private static var _language:NamespaceID;
	static function get_language():NamespaceID
	{
		if (_language == null) _language = Get(LogicOptionItemNames.language);
		return _language;
	}
	public static var difficulty(get, never):NamespaceID;
	private static var _difficulty:NamespaceID;
	static function get_difficulty():NamespaceID
	{
		if (_difficulty == null) _difficulty = Get(LogicOptionItemNames.difficulty);
		return _difficulty;
	}

	public static var swapTrigger(get, never):NamespaceID;
	private static var _swapTrigger:NamespaceID;
	static function get_swapTrigger():NamespaceID
	{
		if (_swapTrigger == null) _swapTrigger = Get(LogicOptionItemNames.swapTrigger);
		return _swapTrigger;
	}
	public static var vibration(get, never):NamespaceID;
	private static var _vibration:NamespaceID;
	static function get_vibration():NamespaceID
	{
		if (_vibration == null) _vibration = Get(LogicOptionItemNames.vibration);
		return _vibration;
	}
	public static var fullscreen(get, never):NamespaceID;
	private static var _fullscreen:NamespaceID;
	static function get_fullscreen():NamespaceID
	{
		if (_fullscreen == null) _fullscreen = Get(LogicOptionItemNames.fullscreen);
		return _fullscreen;
	}
	public static var vSync(get, never):NamespaceID;
	private static var _vSync:NamespaceID;
	static function get_vSync():NamespaceID
	{
		if (_vSync == null) _vSync = Get(LogicOptionItemNames.vSync);
		return _vSync;
	}
	public static var targetFramerate(get, never):NamespaceID;
	private static var _targetFramerate:NamespaceID;
	static function get_targetFramerate():NamespaceID
	{
		if (_targetFramerate == null) _targetFramerate = Get(LogicOptionItemNames.targetFramerate);
		return _targetFramerate;
	}
	public static var bloodAndGore(get, never):NamespaceID;
	private static var _bloodAndGore:NamespaceID;
	static function get_bloodAndGore():NamespaceID
	{
		if (_bloodAndGore == null) _bloodAndGore = Get(LogicOptionItemNames.bloodAndGore);
		return _bloodAndGore;
	}
	public static var pauseOnFocusLost(get, never):NamespaceID;
	private static var _pauseOnFocusLost:NamespaceID;
	static function get_pauseOnFocusLost():NamespaceID
	{
		if (_pauseOnFocusLost == null) _pauseOnFocusLost = Get(LogicOptionItemNames.pauseOnFocusLost);
		return _pauseOnFocusLost;
	}
	public static var skipTalks(get, never):NamespaceID;
	private static var _skipTalks:NamespaceID;
	static function get_skipTalks():NamespaceID
	{
		if (_skipTalks == null) _skipTalks = Get(LogicOptionItemNames.skipTalks);
		return _skipTalks;
	}
	public static var showSponsorNames(get, never):NamespaceID;
	private static var _showSponsorNames:NamespaceID;
	static function get_showSponsorNames():NamespaceID
	{
		if (_showSponsorNames == null) _showSponsorNames = Get(LogicOptionItemNames.showSponsorNames);
		return _showSponsorNames;
	}
	public static var blueprintWarnings(get, never):NamespaceID;
	private static var _blueprintWarnings:NamespaceID;
	static function get_blueprintWarnings():NamespaceID
	{
		if (_blueprintWarnings == null) _blueprintWarnings = Get(LogicOptionItemNames.blueprintWarnings);
		return _blueprintWarnings;
	}
	public static var showHotkeys(get, never):NamespaceID;
	private static var _showHotkeys:NamespaceID;
	static function get_showHotkeys():NamespaceID
	{
		if (_showHotkeys == null) _showHotkeys = Get(LogicOptionItemNames.showHotkeys);
		return _showHotkeys;
	}
	public static var hdrLighting(get, never):NamespaceID;
	private static var _hdrLighting:NamespaceID;
	static function get_hdrLighting():NamespaceID
	{
		if (_hdrLighting == null) _hdrLighting = Get(LogicOptionItemNames.hdrLighting);
		return _hdrLighting;
	}
	public static var heightIndicator(get, never):NamespaceID;
	private static var _heightIndicator:NamespaceID;
	static function get_heightIndicator():NamespaceID
	{
		if (_heightIndicator == null) _heightIndicator = Get(LogicOptionItemNames.heightIndicator);
		return _heightIndicator;
	}

	public static var commandBlockMode(get, never):NamespaceID;
	private static var _commandBlockMode:NamespaceID;
	static function get_commandBlockMode():NamespaceID
	{
		if (_commandBlockMode == null) _commandBlockMode = Get(LogicOptionItemNames.commandBlockMode);
		return _commandBlockMode;
	}
	public static var fpsMode(get, never):NamespaceID;
	private static var _fpsMode:NamespaceID;
	static function get_fpsMode():NamespaceID
	{
		if (_fpsMode == null) _fpsMode = Get(LogicOptionItemNames.fpsMode);
		return _fpsMode;
	}
	public static var screenLayout(get, never):NamespaceID;
	private static var _screenLayout:NamespaceID;
	static function get_screenLayout():NamespaceID
	{
		if (_screenLayout == null) _screenLayout = Get(LogicOptionItemNames.screenLayout);
		return _screenLayout;
	}

	public static var hpBarEnabled(get, never):NamespaceID;
	private static var _hpBarEnabled:NamespaceID;
	static function get_hpBarEnabled():NamespaceID
	{
		if (_hpBarEnabled == null) _hpBarEnabled = Get(LogicOptionItemNames.hpBarEnabled);
		return _hpBarEnabled;
	}
	public static var hpBarAutoHide(get, never):NamespaceID;
	private static var _hpBarAutoHide:NamespaceID;
	static function get_hpBarAutoHide():NamespaceID
	{
		if (_hpBarAutoHide == null) _hpBarAutoHide = Get(LogicOptionItemNames.hpBarAutoHide);
		return _hpBarAutoHide;
	}
	public static var hpBarAmountMode(get, never):NamespaceID;
	private static var _hpBarAmountMode:NamespaceID;
	static function get_hpBarAmountMode():NamespaceID
	{
		if (_hpBarAmountMode == null) _hpBarAmountMode = Get(LogicOptionItemNames.hpBarAmountMode);
		return _hpBarAmountMode;
	}
	public static var hpBarHoverDisplayRange(get, never):NamespaceID;
	private static var _hpBarHoverDisplayRange:NamespaceID;
	static function get_hpBarHoverDisplayRange():NamespaceID
	{
		if (_hpBarHoverDisplayRange == null) _hpBarHoverDisplayRange = Get(LogicOptionItemNames.hpBarHoverDisplayRange);
		return _hpBarHoverDisplayRange;
	}

	public static var musicVolume(get, never):NamespaceID;
	private static var _musicVolume:NamespaceID;
	static function get_musicVolume():NamespaceID
	{
		if (_musicVolume == null) _musicVolume = Get(LogicOptionItemNames.musicVolume);
		return _musicVolume;
	}
	public static var soundVolume(get, never):NamespaceID;
	private static var _soundVolume:NamespaceID;
	static function get_soundVolume():NamespaceID
	{
		if (_soundVolume == null) _soundVolume = Get(LogicOptionItemNames.soundVolume);
		return _soundVolume;
	}
	public static var fastForwardMultiplier(get, never):NamespaceID;
	private static var _fastForwardMultiplier:NamespaceID;
	static function get_fastForwardMultiplier():NamespaceID
	{
		if (_fastForwardMultiplier == null) _fastForwardMultiplier = Get(LogicOptionItemNames.fastForwardMultiplier);
		return _fastForwardMultiplier;
	}
	public static var particleAmount(get, never):NamespaceID;
	private static var _particleAmount:NamespaceID;
	static function get_particleAmount():NamespaceID
	{
		if (_particleAmount == null) _particleAmount = Get(LogicOptionItemNames.particleAmount);
		return _particleAmount;
	}
	public static var shakeAmount(get, never):NamespaceID;
	private static var _shakeAmount:NamespaceID;
	static function get_shakeAmount():NamespaceID
	{
		if (_shakeAmount == null) _shakeAmount = Get(LogicOptionItemNames.shakeAmount);
		return _shakeAmount;
	}
	public static var animationFrequency(get, never):NamespaceID;
	private static var _animationFrequency:NamespaceID;
	static function get_animationFrequency():NamespaceID
	{
		if (_animationFrequency == null) _animationFrequency = Get(LogicOptionItemNames.animationFrequency);
		return _animationFrequency;
	}

	public static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}
}
