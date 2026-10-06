// Ported from: Assets/Scripts/Logic/HeldItems/HeldTargetFlag.cs (class HeldTargetFlagHelper)
package mvz2logic.helditems;

import pvzengine.entities.EntityTypes;

class HeldTargetFlagHelper
{
	public static function GetHeldTargetFlagByType(type:Int):HeldTargetFlag
	{
		return typeFlagDict.exists(type) ? typeFlagDict.get(type) : HeldTargetFlag.None;
	}
	private static var typeFlagDict:Map<Int, HeldTargetFlag> = [
		EntityTypes.PLANT => HeldTargetFlag.Plant,
		EntityTypes.ENEMY => HeldTargetFlag.Enemy,
		EntityTypes.OBSTACLE => HeldTargetFlag.Obstacle,
		EntityTypes.BOSS => HeldTargetFlag.Boss,
		EntityTypes.CART => HeldTargetFlag.Cart,
		EntityTypes.PICKUP => HeldTargetFlag.Pickup,
		EntityTypes.PROJECTILE => HeldTargetFlag.Projectile,
		EntityTypes.EFFECT => HeldTargetFlag.Effect
	];

	private function new() {}
}
