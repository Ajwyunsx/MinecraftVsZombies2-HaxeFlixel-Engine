// Ported from: Assets/Scripts/MVZ2/Level/ILevelController.cs
package mvz2.level;

import mvz2.globalgames.GlobalGame;
// PORT-NOTE: 原 import 写作 mvz2.ui.ILevelUI；ILevelUI 与 LevelUI 同文件，
// 属次类型，须按 Haxe 模块规则从所属模块导入。
import mvz2.ui.level.LevelUI.ILevelUI;
import mvz2.ui.ITooltipSource;
// PORT-NOTE: ILevelUIController / ILevelTransitionController 是本文件内的次类型，同包直接可见，无需 import。
import pvzengine.level.LevelEngine;
import unity.Camera;
import mvz2.ui.level.LevelUI;
import unity.Coroutine;

interface ILevelController extends ILevelUIController extends ILevelTransitionController
{
	public var Game(get, never):GlobalGame;
	public function GetUI():ILevelUI;
	public function GetEngine():LevelEngine;
	public function GetCamera():Camera;
	public var BlueprintController(get, never):LevelBlueprintController;
	public var BlueprintChoosePart(get, never):LevelBlueprintChooseController;

	public function ChooseBlueprintsInteractable():Bool;
	public function OpenAlmanac():Void;
	public function OpenStore():Void;
	public function IsOpeningExtraScene():Bool;

	public function GetTwinkleAlpha():Float;
}

interface ILevelUIController
{
	public function ShowTooltip(source:ITooltipSource):Void;
	public function HideTooltip():Void;
}

interface ILevelTransitionController
{
	public function GameStartToLawnTransition():unity.Coroutine;
	public function MoveCameraToLawn():unity.Coroutine;
	public function MoveCameraToChoose():unity.Coroutine;
}
