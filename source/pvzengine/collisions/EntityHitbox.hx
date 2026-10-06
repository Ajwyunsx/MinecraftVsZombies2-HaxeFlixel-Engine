// Ported from: Assets/Scripts/Engine/Level/Entities/Hitboxes/EntityHitbox.cs
package pvzengine.collisions;

import pvzengine.entities.Entity;
import unity.Vector3;

class EntityHitbox extends Hitbox
{
	public function new(entity:Entity)
	{
		super(entity);
	}
	override public function GetSize():Vector3
	{
		return Entity.Cache.Size;
	}
	override public function GetPivot():Vector3
	{
		return Entity.Cache.BoundsPivot;
	}
	override public function GetOffset():Vector3
	{
		return Entity.Cache.BoundsOffset;
	}
}
