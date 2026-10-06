// Ported from: Assets/Scripts/Logic/Game/IGlobalLevel.cs
package mvz2logic.games;

import mvz2logic.level.LevelExitTarget;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;

interface IGlobalLevel
{
	function InitLevel(areaId:NamespaceID, stageId:NamespaceID, introDelay:Float = 0, exitTarget:LevelExitTarget = LevelExitTarget.MapOrMainmenu):Void;
	function GetLevel():Null<LevelEngine>;
	// TODO-PORT: C# 的 IsInLevel() 在接口中有默认实现，Haxe 接口不支持默认方法，此处改为需要实现的抽象方法。
	function IsInLevel():Bool;
}
