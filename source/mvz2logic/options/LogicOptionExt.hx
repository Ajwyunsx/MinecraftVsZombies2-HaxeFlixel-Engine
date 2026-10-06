// Ported from: Assets/Scripts/Logic/Options/LogicOptionExt.cs
package mvz2logic.options;

import mvz2logic.Global;
import mvz2logic.games.IGlobalOptions;
import pvzengine.NamespaceID;
import tools.Ref;
using pvzengine.ContentProviderHelper;

class LogicOptionExt
{
	// #region 语言
	public static function GetLanguage(options:IGlobalOptions):String return options.GetOptionString(LogicOptionItemID.language);
	public static function SetLanguage(options:IGlobalOptions, language:String):Void return options.SetOptionString(LogicOptionItemID.language, language);
	public static function IsLanguageInitialized(options:IGlobalOptions):Bool
	{
		var lang = new Ref<String>(null);
		return options.TryGetOptionString(LogicOptionItemID.language, lang) && lang.value != null && lang.value.length > 0;
	}
	// #endregion

	// #region 难度
	public static function GetDifficulty(options:IGlobalOptions):NamespaceID
	{
		var difficulty = options.GetOptionID(LogicOptionItemID.difficulty);
		return difficulty == null ? GetDefaultDifficulty() : difficulty;
	}
	public static function SetDifficulty(options:IGlobalOptions, difficulty:NamespaceID):Void return options.SetOptionID(LogicOptionItemID.difficulty, difficulty);
	public static function CycleDifficulty(options:IGlobalOptions):Void
	{
		var difficultyDefs = Global.Game.GetAllDifficultyDefinitions();
		var difficulties:Array<NamespaceID> = [];
		for (d in difficultyDefs)
			difficulties.push(d.GetID());
		var index = difficulties.indexOf(GetDifficulty(options));
		index++;
		index %= difficulties.length;
		SetDifficulty(options, difficulties[index]);
	}
	private static function GetDefaultDifficulty():NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, "normal");
	}
	// #endregion

	// #region 交换触发
	public static function IsTriggerSwapped(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.swapTrigger);
	public static function SetSwapTrigger(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.swapTrigger, value);
	// #endregion

	// #region 全屏
	public static function IsFullscreen(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.fullscreen);
	public static function SetFullscreen(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.fullscreen, value);
	// #endregion

	// #region HDR
	public static function HDRLightingDisabled(options:IGlobalOptions):Bool return !options.GetOptionBool(LogicOptionItemID.hdrLighting);
	public static function SetHDRLightingDisabled(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.hdrLighting, !value);
	// #endregion

	// #region 震动
	public static function IsVibration(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.vibration);
	// PORT-NOTE: 原文如此（使用 fullscreen 的 ID），保留 1:1。
	public static function SetVibration(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.fullscreen, value);
	// #endregion

	// #region 血与碎块
	public static function HasBloodAndGore(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.bloodAndGore);
	public static function SetBloodAndGore(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.bloodAndGore, value);
	// #endregion

	// #region 焦点丢失暂停
	public static function GetPauseOnFocusLost(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.pauseOnFocusLost);
	public static function SetPauseOnFocusLost(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.pauseOnFocusLost, value);
	// #endregion

	// #region 显示赞助者名称
	public static function ShowSponsorNames(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.showSponsorNames);
	public static function SetShowSponsorNames(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.showSponsorNames, value);
	// #endregion

	// #region 跳过对话
	public static function SkipAllTalks(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.skipTalks);
	public static function SetSkipAllTalks(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.skipTalks, value);
	// #endregion

	// #region 蓝图选择警告
	public static function AreBlueprintChooseWarningsDisabled(options:IGlobalOptions):Bool return !options.GetOptionBool(LogicOptionItemID.blueprintWarnings);
	// PORT-NOTE: 原文如此（使用 skipTalks 的 ID），保留 1:1。
	public static function SetBlueprintChooseWarningsDisabled(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.skipTalks, !value);
	// #endregion

	// #region 命令方块模式
	public static function GetCommandBlockMode(options:IGlobalOptions):Int return options.GetOptionInt(LogicOptionItemID.commandBlockMode);
	public static function SetCommandBlockMode(options:IGlobalOptions, value:Int):Void return options.SetOptionInt(LogicOptionItemID.commandBlockMode, value);
	public static function CycleCommandBlockMode(options:IGlobalOptions):Void
	{
		var mode = GetCommandBlockMode(options);
		mode = (mode + 1) % CommandBlockModes.COUNT;
		SetCommandBlockMode(options, mode);
	}
	// #endregion

	// #region FPS显示
	public static function GetFPSMode(options:IGlobalOptions):Int return options.GetOptionInt(LogicOptionItemID.fpsMode);
	public static function SetFPSMode(options:IGlobalOptions, value:Int):Void return options.SetOptionInt(LogicOptionItemID.fpsMode, value);
	public static function CycleFPSMode(options:IGlobalOptions):Void
	{
		var mode = GetFPSMode(options);
		mode = (mode + 1) % FPSModes.COUNT;
		SetFPSMode(options, mode);
	}
	// #endregion

	// #region 热键显示
	public static function ShowHotkeyIndicators(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.showHotkeys);
	public static function SetShowHotkeyIndicators(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.showHotkeys, value);
	// #endregion

	// #region 高度指示器
	public static function IsHeightIndicatorEnabled(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.heightIndicator);
	public static function SetHeightIndicatorEnabled(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.heightIndicator, value);
	// #endregion

	// #region 血条
	public static function IsHPBarEnabled(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.hpBarEnabled);
	public static function SetHPBarEnabled(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.hpBarEnabled, value);
	public static function SwitchHPBarEnabled(options:IGlobalOptions):Void return SetHPBarEnabled(options, !IsHPBarEnabled(options));


	public static function IsHPBarAutoHide(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.hpBarAutoHide);
	public static function SetHPBarAutoHide(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.hpBarAutoHide, value);


	public static function GetHPBarHoverDisplayRange(options:IGlobalOptions):Float return options.GetOptionFloat(LogicOptionItemID.hpBarHoverDisplayRange);
	public static function SetHPBarHoverDisplayRange(options:IGlobalOptions, value:Float):Void return options.SetOptionFloat(LogicOptionItemID.hpBarHoverDisplayRange, value);

	public static function GetHPBarAmountMode(options:IGlobalOptions):Int return options.GetOptionInt(LogicOptionItemID.hpBarAmountMode);
	public static function SetHPBarAmountMode(options:IGlobalOptions, value:Int):Void return options.SetOptionInt(LogicOptionItemID.hpBarAmountMode, value);
	public static function CycleHPBarAmountMode(options:IGlobalOptions):Void
	{
		var mode = GetHPBarAmountMode(options);
		mode = (mode + 1) % HPBarAmountMode.COUNT;
		SetHPBarAmountMode(options, mode);
	}
	// #endregion

	// #region 音乐音量
	public static function GetMusicVolume(options:IGlobalOptions):Float return options.GetOptionFloat(LogicOptionItemID.musicVolume);
	public static function SetMusicVolume(options:IGlobalOptions, value:Float):Void return options.SetOptionFloat(LogicOptionItemID.musicVolume, value);
	// #endregion

	// #region 音效音量
	public static function GetSoundVolume(options:IGlobalOptions):Float return options.GetOptionFloat(LogicOptionItemID.soundVolume);
	public static function SetSoundVolume(options:IGlobalOptions, value:Float):Void return options.SetOptionFloat(LogicOptionItemID.soundVolume, value);
	// #endregion

	// #region 快进倍率
	public static function GetFastForwardMultiplier(options:IGlobalOptions):Float return options.GetOptionFloat(LogicOptionItemID.fastForwardMultiplier);
	public static function SetFastForwardMultiplier(options:IGlobalOptions, value:Float):Void return options.SetOptionFloat(LogicOptionItemID.fastForwardMultiplier, value);
	// #endregion

	// #region 粒子数量
	public static function GetParticleAmount(options:IGlobalOptions):Float return options.GetOptionFloat(LogicOptionItemID.particleAmount);
	public static function SetParticleAmount(options:IGlobalOptions, value:Float):Void return options.SetOptionFloat(LogicOptionItemID.particleAmount, value);
	// #endregion

	// #region 震动幅度
	public static function GetShakeAmount(options:IGlobalOptions):Float return options.GetOptionFloat(LogicOptionItemID.shakeAmount);
	public static function SetShakeAmount(options:IGlobalOptions, value:Float):Void return options.SetOptionFloat(LogicOptionItemID.shakeAmount, value);
	// #endregion

	// #region 动画频率
	public static function GetAnimationFrequency(options:IGlobalOptions):Float return options.GetOptionFloat(LogicOptionItemID.animationFrequency);
	public static function SetAnimationFrequency(options:IGlobalOptions, value:Float):Void return options.SetOptionFloat(LogicOptionItemID.animationFrequency, value);
	// #endregion

	// #region 垂直同步
	public static function GetVSync(options:IGlobalOptions):Bool return options.GetOptionBool(LogicOptionItemID.vSync);
	public static function SetVSync(options:IGlobalOptions, value:Bool):Void return options.SetOptionBool(LogicOptionItemID.vSync, value);
	// #endregion

	// #region 目标帧率
	public static function GetTargetFramerate(options:IGlobalOptions):Int return options.GetOptionInt(LogicOptionItemID.targetFramerate);
	public static function SetTargetFramerate(options:IGlobalOptions, value:Int):Void return options.SetOptionInt(LogicOptionItemID.targetFramerate, value);
	// #endregion

	// #region 屏幕布局
	public static function GetScreenLayout(options:IGlobalOptions):Int return options.GetOptionInt(LogicOptionItemID.screenLayout);
	public static function SetScreenLayout(options:IGlobalOptions, value:Int):Void return options.SetOptionInt(LogicOptionItemID.screenLayout, value);
	// #endregion
}
