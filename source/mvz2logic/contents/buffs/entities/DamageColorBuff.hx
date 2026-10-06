// Ported from: Assets/Scripts/Logic/Contents/Buffs/Entities/DamageColorBuff.cs
package mvz2logic.contents.buffs.entities;

import mvz2logic.contents.buffs.FrameworksBuffNames;
import pvzengine.PropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EntityTypes;
import pvzengine.level.EngineEntityProps;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(FrameworksBuffNames.Entity_damageColor)
class DamageColorBuff extends BuffDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
		AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, new Color(1, 0, 0, 0.5)));
	}
	public override function PostAdd(buff:Buff):Void
	{
		super.PostAdd(buff);
		buff.SetProperty(PROP_TIMEOUT, 2);
	}
	public override function PostUpdate(buff:Buff):Void
	{
		super.PostUpdate(buff);
		var timeout = buff.GetProperty(PROP_TIMEOUT);
		timeout--;
		buff.SetProperty(PROP_TIMEOUT, timeout);
		if (timeout > 0)
			return;
		var entity = buff.GetEntity();
		if (entity == null || !entity.IsDead || entity.Type == EntityTypes.BOSS)
		{
			buff.Remove();
		}
	}
	public static var PROP_TIMEOUT:PropertyMeta<Int> = new PropertyMeta<Int>("Timeout");
}
