// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter3/LittleZombieBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.buffs.armors.LittleZombieArmorBuff;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEnemyProps;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.MaxHealthModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Enemy_littleZombie)
class LittleZombieBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.SCALE, NumberOperator.Multiply, new Vector3(0.5, 0.5, 0.5)));
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, new Vector3(0.5, 0.5, 0.5)));
        AddModifier(new Vector3Modifier(LogicEntityProps.SHADOW_SCALE, NumberOperator.Multiply, new Vector3(0.5, 0.5, 0.5)));
        AddModifier(new MaxHealthModifier(NumberOperator.Multiply, 0.25));
        AddModifier(new FloatModifier(LogicEnemyProps.CRY_PITCH, NumberOperator.Multiply, 2));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var armor = VanillaEntityExt.GetMainArmor(entity);
        if (armor == null)
            return;
        if (armor.HasBuff(LittleZombieArmorBuff))
            return;
        armor.AddBuff(LittleZombieArmorBuff);
    }
}
