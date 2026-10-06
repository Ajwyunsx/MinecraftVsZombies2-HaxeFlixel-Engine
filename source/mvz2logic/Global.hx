// Ported from: Assets/Scripts/Logic/Game/Global.cs
// PORT-NOTE: C# 同文件中的 struct GlobalParams 已拆分为独立模块 mvz2logic.GlobalParams
// （工程中已有其他包的文件以 `import mvz2logic.GlobalParams;` 引用它）。
package mvz2logic;

import mvz2logic.games.IGlobalAlmanac;
import mvz2logic.games.IGlobalCursors;
import mvz2logic.games.IGlobalDebug;
import mvz2logic.games.IGlobalGUI;
import mvz2logic.games.IGlobalGame;
import mvz2logic.games.IGlobalInput;
import mvz2logic.games.IGlobalLevel;
import mvz2logic.games.IGlobalLocalization;
import mvz2logic.games.IGlobalModels;
import mvz2logic.games.IGlobalMusic;
import mvz2logic.games.IGlobalOptions;
import mvz2logic.games.IGlobalSaveData;
import mvz2logic.games.IGlobalScene;
import mvz2logic.modding.IVanillaInterface;

class Global
{
	public static function Init(param:GlobalParams):Void
	{
		Models = param.models;
		Almanac = param.almanac;
		Saves = param.saveData;
		Options = param.options;
		Input = param.input;
		Level = param.level;
		Music = param.music;
		GUI = param.gui;
		Scene = param.scene;
		Localization = param.localization;
		Debugs = param.debug;
		Cursors = param.cursors;
	}
	public static function InitGame(game:IGlobalGame):Void
	{
		Game = game;
	}
	public static function SetVanillaInterface(vanillaInterface:IVanillaInterface):Void
	{
		VanillaInterface = vanillaInterface;
	}
	// C#: { get; private set; } 的自动属性
	public static var Models(default, null):IGlobalModels;
	public static var Almanac(default, null):IGlobalAlmanac;
	public static var Saves(default, null):IGlobalSaveData;
	public static var Options(default, null):IGlobalOptions;
	public static var Input(default, null):IGlobalInput;
	public static var Level(default, null):IGlobalLevel;
	public static var Music(default, null):IGlobalMusic;
	public static var GUI(default, null):IGlobalGUI;
	public static var Scene(default, null):IGlobalScene;
	public static var Game(default, null):IGlobalGame;
	public static var Localization(default, null):IGlobalLocalization;
	public static var Debugs(default, null):IGlobalDebug;
	public static var Cursors(default, null):IGlobalCursors;
	public static var VanillaInterface(default, null):IVanillaInterface;
	// PORT-NOTE: C# 的 BuiltinNamespace => Game.DefaultNamespace 依赖 C# 静态字段"首次使用时才初始化"的
	// 语义，因此不会在运行期单例可用之前被求值。hxcpp 则会在 main() 之前执行**全部**静态初始化
	// （__boot_all()），此时 Game 仍为 null，任何在该阶段读取 BuiltinNamespace 的静态字段都会段错误。
	// 移植层的 Game.DefaultNamespace 恒等于 MainManager.builtinNamespace，其初值固定为字面量 "mvz2"
	// （Assets/Scripts/MVZ2/Managers/MainManager.cs:377，移植层运行期从不改写），故启动期回退到同一常量：
	// 取值与运行期完全一致，同时一次性消除这一整类启动期空引用。
	public static inline var BOOT_BUILTIN_NAMESPACE:String = "mvz2";
	public static var BuiltinNamespace(get, never):String;
	static function get_BuiltinNamespace():String return Game == null ? BOOT_BUILTIN_NAMESPACE : Game.DefaultNamespace;

	private function new() {}
}
