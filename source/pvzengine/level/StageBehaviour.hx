// Ported from: Assets/Scripts/Engine/Level/Level/StageBehaviour.cs
package pvzengine.level;

import pvzengine.entities.Entity;
import pvzengine.modifiers.PropertyModifier;

// PORT-NOTE: C# `abstract class StageBehaviour`。按 PORTING.md，抽象类仍写作普通 class，
// 抽象方法留空实现。既有子类（mvz2/gamecontent/stages/*StageBehaviour.hx）用 `override`。
class StageBehaviour
{
	public function new(stageDef:StageDefinition)
	{
	}
	public function Setup(level:LevelEngine):Void {}
	public function Start(level:LevelEngine):Void {}
	public function Update(level:LevelEngine):Void {}
	public function PrepareForBattle(level:LevelEngine):Void {}
	public function PostWave(level:LevelEngine, wave:Int):Void {}
	public function PostHugeWaveEvent(level:LevelEngine):Void {}
	public function PostFinalWaveEvent(level:LevelEngine):Void {}
	public function PostEnemySpawned(entity:Entity):Void {}
	// PORT-NOTE: C# `bool LevelHasBehaviour<T>(LevelEngine level) where T : StageBehaviour` →
	// 按工程既有约定（无法在 Haxe 中书写类型实参）改为传入类型对象。
	public function LevelHasBehaviour<T:StageBehaviour>(level:LevelEngine, typeClass:Class<T>):Bool
	{
		return level.StageDefinition.HasBehaviour(typeClass);
	}
	public function GetModifiers():Array<PropertyModifier>
	{
		return modifiers.copy();
	}
	// C#: protected void AddModifier(PropertyModifier modifier)
	// PORT-NOTE: Haxe 无 protected，private 对子类可见，语义等价（同 pvzengine.grids.GridDefinition）。
	private function AddModifier(modifier:PropertyModifier):Void
	{
		modifiers.push(modifier);
	}
	private var modifiers:Array<PropertyModifier> = [];
}
