// Ported from: Assets/Scripts/Engine/Level/Level/ILevelObject.cs
package pvzengine.level;

import pvzengine.entities.Entity;

interface ILevelObject
{
	public function GetEntity():Null<Entity>;
	public function GetLevel():LevelEngine;
	public function Exists():Bool;
	// PORT-NOTE: C# `IEnumerable<ILevelObject>` → Haxe `Array<ILevelObject>`（同 pvzengine.grids.LawnGrid 的移植）。
	public function GetChildrenObjects():Array<ILevelObject>;
	public function OnAddToLevel(level:LevelEngine):Void;
	public function OnRemoveFromLevel(level:LevelEngine):Void;
}
