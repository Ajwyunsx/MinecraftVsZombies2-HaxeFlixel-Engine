// Ported from: Assets/Scripts/Logic/Contents/Buffs/Enemies/BeingRidenBuff.cs
package mvz2logic.contents.buffs.enemies;

import mvz2logic.contents.buffs.FrameworksBuffNames;
import pvzengine.PropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityID;
using mvz2logic.contents.enemies.LogicEnemyExt;
using pvzengine.buffs.BuffTargetExt;
using pvzengine.entities.EngineEntityExt;

@:autoBuffDefinition(FrameworksBuffNames.Enemy_beingRiden)
class BeingRidenBuff extends BuffDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function PostUpdate(buff:Buff):Void
	{
		super.PostUpdate(buff);
		var horse = buff.GetEntity();
		if (horse == null)
			return;
		var passenger = GetPassenger(buff);
		if (!passenger.ExistsAndAlive() || passenger.IsHostile(horse))
		{
			horse.GetOffHorse();
		}
	}
	public static function GetPassenger(buff:Buff):Null<Entity>
	{
		var entityID = buff.GetProperty(PROP_TARGET);
		return entityID == null ? null : entityID.GetEntity(buff.Level);
	}
	public static function SetPassenger(buff:Buff, value:Entity):Void
	{
		buff.SetProperty(PROP_TARGET, new EntityID(value));
	}
	public static var PROP_TARGET:PropertyMeta<EntityID> = new PropertyMeta<EntityID>("Target");
}
