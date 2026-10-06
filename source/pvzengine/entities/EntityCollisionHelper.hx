// Ported from: Assets/Scripts/Engine/Level/Entities/EntityCollisionHelper.cs
package pvzengine.entities;

// PORT-NOTE: 上层同时存在 `import pvzengine.entities.EntityCollisionHelper;`（45 处）与
//   `import pvzengine.collisions.EntityCollisionHelper;`（27 处）两种写法；
//   本类按 C# 命名空间（PVZEngine.Entities）放在 pvzengine.entities，
//   并在 pvzengine/collisions/EntityCollisionHelper.hx 提供同名 typedef 别名。
class EntityCollisionHelper
{
	public static inline var DETECTION_ENABLED:Int = 0;
	public static inline var DETECTION_NO_OVERLAP:Int = 1; // Hitbox overlap disabled.
	public static inline var DETECTION_NO_COLLISION:Int = 2; // Ignore Collision but hitbox can be overlapped.
	public static inline var DETECTION_DISABLED:Int = 3; // Collision and hitbox overlap disabled.

	public static inline var NAME_MAIN:String = "main";

	public static inline var MASK_PLANT:Int = 1 << 0;
	public static inline var MASK_ENEMY:Int = 1 << 1;
	public static inline var MASK_OBSTACLE:Int = 1 << 2;
	public static inline var MASK_BOSS:Int = 1 << 3;
	public static inline var MASK_CART:Int = 1 << 4;
	public static inline var MASK_PICKUP:Int = 1 << 5;
	public static inline var MASK_PROJECTILE:Int = 1 << 6;
	public static inline var MASK_EFFECT:Int = 1 << 7;
	public static inline var MASK_VULNERABLE:Int = MASK_PLANT | MASK_ENEMY | MASK_OBSTACLE | MASK_BOSS;
	public static inline var MASK_ALL:Int = MASK_VULNERABLE | MASK_CART | MASK_PICKUP | MASK_PROJECTILE | MASK_EFFECT;

	public static inline var STATE_ENTER:Int = 0;
	public static inline var STATE_STAY:Int = 1;
	public static inline var STATE_EXIT:Int = 2;

	public static function CanCollide(collisionMask:Int, entity:Entity):Bool
	{
		return (collisionMask & entity.TypeCollisionFlag) > 0;
	}
	public static function CanCollideFaction(hostileMask:Int, friendlyMask:Int, faction:Int, entity:Entity):Bool
	{
		var faction2 = entity.GetFaction();
		if ((hostileMask & entity.TypeCollisionFlag) > 0 && EngineEntityExt.IsHostile(faction, faction2))
		{
			return true;
		}
		if ((friendlyMask & entity.TypeCollisionFlag) > 0 && EngineEntityExt.IsFriendly(faction, faction2))
		{
			return true;
		}
		return false;
	}
	public static function GetTypeMask(type:Int):Int
	{
		if (typeMaskDict.exists(type))
			return typeMaskDict.get(type);
		return 0;
	}
	private static var typeMaskDict:Map<Int, Int> = [
		EntityTypes.PLANT => MASK_PLANT,
		EntityTypes.ENEMY => MASK_ENEMY,
		EntityTypes.OBSTACLE => MASK_OBSTACLE,
		EntityTypes.BOSS => MASK_BOSS,
		EntityTypes.CART => MASK_CART,
		EntityTypes.PICKUP => MASK_PICKUP,
		EntityTypes.PROJECTILE => MASK_PROJECTILE,
		EntityTypes.EFFECT => MASK_EFFECT,
	];
}
