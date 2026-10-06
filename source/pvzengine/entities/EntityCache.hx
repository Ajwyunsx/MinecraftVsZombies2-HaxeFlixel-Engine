// Ported from: Assets/Scripts/Engine/Level/Entities/EntityCache.cs
package pvzengine.entities;

import pvzengine.IPropertyKey;
import tools.GenericHelper;
import unity.Vector3;

class EntityCache
{
	public function new()
	{
	}

	public function UpdateAll(entity:Entity):Void
	{
		Faction = entity.GetProperty(EngineEntityProps.FACTION);
		Gravity = entity.GetGravity();
		Friction = entity.GetFriction();
		GroundLimitOffset = entity.GetGroundLimitOffset();
		GridPivotOffset = entity.GetGridPivotOffset();
		VelocityDampen = entity.GetVelocityDampen();
		Size = entity.GetSize();
		Scale = entity.GetScale();
		FlipX = entity.IsFlipX();
		BoundsPivot = entity.GetBoundsPivot();
		BoundsOffset = entity.GetBoundsOffset();
		CollisionDetection = entity.GetCollisionDetection();
		CollisionInterval = entity.GetCollisionInterval();
		entity.UpdateCollision();
	}
	public function UpdateProperty(entity:Entity, name:IPropertyKey, beforeValue:Dynamic, afterValue:Dynamic):Void
	{
		if (EngineEntityProps.FACTION.Equals(name))
		{
			Faction = GenericHelper.ToGeneric(afterValue);
		}
		else if (EngineEntityProps.GRAVITY.Equals(name))
		{
			Gravity = GenericHelper.ToGeneric(afterValue);
		}
		else if (EngineEntityProps.FRICTION.Equals(name))
		{
			Friction = GenericHelper.ToGeneric(afterValue);
		}
		else if (EngineEntityProps.GROUND_LIMIT_OFFSET.Equals(name))
		{
			GroundLimitOffset = GenericHelper.ToGeneric(afterValue);
		}
		else if (EngineEntityProps.GRID_PIVOT_OFFSET.Equals(name))
		{
			GridPivotOffset = GenericHelper.ToGeneric(afterValue);
		}
		else if (EngineEntityProps.VELOCITY_DAMPEN.Equals(name))
		{
			VelocityDampen = GenericHelper.ToGeneric(afterValue);
		}
		else if (EngineEntityProps.SIZE.Equals(name))
		{
			Size = GenericHelper.ToGeneric(afterValue);
			entity.UpdateCollisionSize();
		}
		else if (EngineEntityProps.SCALE.Equals(name))
		{
			Scale = GenericHelper.ToGeneric(afterValue);
			entity.UpdateCollisionSize();
		}
		else if (EngineEntityProps.FLIP_X.Equals(name))
		{
			FlipX = GenericHelper.ToGeneric(afterValue);
			entity.UpdateCollisionSize();
		}
		else if (EngineEntityProps.BOUNDS_PIVOT.Equals(name))
		{
			BoundsPivot = GenericHelper.ToGeneric(afterValue);
			entity.UpdateCollisionSize();
		}
		else if (EngineEntityProps.BOUNDS_OFFSET.Equals(name))
		{
			BoundsOffset = GenericHelper.ToGeneric(afterValue);
			entity.UpdateCollisionSize();
		}
		else if (EngineEntityProps.COLLISION_DETECTION.Equals(name))
		{
			CollisionDetection = GenericHelper.ToGeneric(afterValue);
			entity.UpdateCollisionDetection();
		}
		else if (EngineEntityProps.COLLISION_INTERVAL.Equals(name))
		{
			CollisionInterval = GenericHelper.ToGeneric(afterValue);
		}
	}
	public function GetFinalScale():Vector3
	{
		// PORT-NOTE: C# Vector3 是值类型，`var scale = Scale; scale.x *= ...` 不会改动缓存；
		//   Haxe 的 unity.Vector3 为引用语义，故显式构造新值。
		return new Vector3(Scale.x * (FlipX ? -1 : 1), Scale.y, Scale.z);
	}

	public var Faction(default, null):Int;
	public var FlipX(default, null):Bool;
	public var Gravity(default, null):Float;
	public var Friction(default, null):Float;
	public var GroundLimitOffset(default, null):Float;
	public var GridPivotOffset(default, null):Vector3;
	public var VelocityDampen(default, null):Vector3;
	public var Size(default, null):Vector3;
	public var Scale(default, null):Vector3;
	public var BoundsPivot(default, null):Vector3;
	public var BoundsOffset(default, null):Vector3;
	public var CollisionDetection(default, null):Int;
	public var CollisionInterval(default, null):Int;
}
