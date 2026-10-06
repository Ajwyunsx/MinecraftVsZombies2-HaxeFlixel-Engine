// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/BoatBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.entities.WaterInteraction;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import unity.Vector3;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;

@:autoBuffDefinition(VanillaBuffNames.Enemy_boat)
class BoatBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(VanillaEntityProps.WATER_INTERACTION, IntegerOperator.Set, WaterInteraction.FLOAT));
        AddModifier(new IntModifier(VanillaEntityProps.AIR_INTERACTION, IntegerOperator.Set, WaterInteraction.FLOAT));
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostDeathCallback);
    }
    private function PostDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (!entity.HasBuff(BoatBuff))
            return;
        // 掉出船体残骸
        // C#: entity.Level.Spawn(...)?.Let(e => { ... });
        var broken = entity.Level.Spawn(VanillaEffectID.brokenArmor, entity.GetCenter(), entity);
        if (broken != null)
        {
            broken.Velocity = new Vector3(broken.RNG.NextFloat() * 20 - 10, 5, 0);
            broken.ChangeModel(VanillaModelID.boatItem);
            broken.SetDisplayScale(entity.GetDisplayScale());
        }
        entity.RemoveBuffs(BoatBuff);
    }
}
