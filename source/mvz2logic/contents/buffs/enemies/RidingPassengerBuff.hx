// Ported from: Assets/Scripts/Logic/Contents/Buffs/Enemies/RidingPassengerBuff.cs
package mvz2logic.contents.buffs.enemies;

import mvz2logic.contents.buffs.FrameworksBuffNames;
import mvz2logic.entities.LogicEnemyProps;
import pvzengine.PropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityID;
import pvzengine.modifiers.BooleanModifier;
import unity.Vector3;
using mvz2logic.contents.enemies.LogicEnemyExt;
using pvzengine.buffs.BuffTargetExt;
using pvzengine.entities.EngineEntityExt;

@:autoBuffDefinition(FrameworksBuffNames.Enemy_ridingPassenger)
class RidingPassengerBuff extends BuffDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
		AddModifier(new BooleanModifier(LogicEnemyProps.HARMLESS, true));
	}
	public override function PostUpdate(buff:Buff):Void
	{
		super.PostUpdate(buff);
		var passenger = buff.GetEntity();
		if (passenger == null)
			return;
		var horse = GetRidingEntity(buff);
		if (!horse.ExistsAndAlive() || horse.IsHostile(passenger))
		{
			passenger.GetOffPassenger();
		}
		else
		{
			passenger.UpdatePassengerPosition(horse);
			passenger.Velocity = Vector3.zero;
		}
	}
	public static function GetRidingEntity(buff:Buff):Null<Entity>
	{
		var entityID = buff.GetProperty(PROP_TARGET);
		return entityID == null ? null : entityID.GetEntity(buff.Level);
	}
	public static function SetRidingEntity(buff:Buff, value:Entity):Void
	{
		buff.SetProperty(PROP_TARGET, new EntityID(value));
	}
	public static var PROP_TARGET:PropertyMeta<EntityID> = new PropertyMeta<EntityID>("Target");
}
