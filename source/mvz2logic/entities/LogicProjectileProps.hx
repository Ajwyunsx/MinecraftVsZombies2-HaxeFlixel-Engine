// Ported from: Assets/Scripts/Logic/Entities/LogicProjectileProps.cs
package mvz2logic.entities;

import pvzengine.PropertyMeta;
import pvzengine.PropertyRegions;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityID;

@:propertyRegistryRegion(PropertyRegions.entity)
class LogicProjectileProps
{
	static function Get<T>(name:String, ?defaultValue:T, ?obsoleteNames:Array<String>):PropertyMeta<T>
	{
		return new PropertyMeta<T>(name, defaultValue, obsoleteNames);
	}

	//region 锁定目标
	public static var LOCKED_TARGET_ID:PropertyMeta<EntityID> = Get("locked_target_id");
	public static function GetLockedTargetID(entity:Entity):Null<EntityID>
	{
		return entity.GetProperty(LOCKED_TARGET_ID);
	}
	public static function SetLockedTarget(entity:Entity, value:Null<EntityID>):Void
	{
		entity.SetProperty(LOCKED_TARGET_ID, value);
	}
	//endregion

	private function new() {}
}
