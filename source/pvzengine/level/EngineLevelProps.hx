// Ported from: Assets/Scripts/Engine/Level/Level/EngineLevelProps.cs
package pvzengine.level;

import pvzengine.PropertyMeta;
import pvzengine.PropertyRegions;

// C#: [PropertyRegistryRegion(PropertyRegions.level)]
@:propertyRegistryRegion(PropertyRegions.level)
class EngineLevelProps
{
	public static var START_ENERGY:PropertyMeta<Float> = new PropertyMeta<Float>("startEnergy");
	public static function GetStartEnergy(level:LevelEngine):Float
	{
		return level.GetProperty(START_ENERGY);
	}
	// PORT-NOTE: C# 有两个 SetStartEnergy 重载（LevelEngine / StageDefinition），Haxe 不支持重载，
	// 故按工程既有做法合并为 Dynamic 形参 + 运行期分派（同 pvzengine.buffs.BuffTargetExt）。
	// 调用点：mvz2/modding/ModLoader.hx 的 `stageDef.SetStartEnergy(...)`、
	//         `level.SetStartEnergy(...)`（经由类上的 @:using）。
	public static function SetStartEnergy(target:Dynamic, value:Float):Void
	{
		if (Std.isOfType(target, StageDefinition))
		{
			(cast target:StageDefinition).SetProperty(START_ENERGY, value);
			return;
		}
		(cast target:LevelEngine).SetProperty(START_ENERGY, value);
	}

	public static var RECHARGE_SPEED:PropertyMeta<Float> = new PropertyMeta<Float>("rechargeSpeed");
	public static function GetRechargeSpeed(level:LevelEngine):Float
	{
		return level.GetProperty(RECHARGE_SPEED);
	}
	// PORT-NOTE: 同 SetStartEnergy，合并 LevelEngine / StageDefinition 两个重载。
	public static function SetRechargeSpeed(target:Dynamic, value:Float):Void
	{
		if (Std.isOfType(target, StageDefinition))
		{
			(cast target:StageDefinition).SetProperty(RECHARGE_SPEED, value);
			return;
		}
		(cast target:LevelEngine).SetProperty(RECHARGE_SPEED, value);
	}
}
