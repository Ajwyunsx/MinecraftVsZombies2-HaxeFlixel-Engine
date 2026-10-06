// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Behaviours/ContraptionCommonBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.NocturnalBuff;
import mvz2.gamecontent.buffs.contraptions.SacrificedBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.contraptionCommon)
class ContraptionCommonBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        if (entity.IsNocturnal() && entity.Level.IsDay())
        {
            entity.AddBuff(NocturnalBuff);
        }
    }
    public override function PostDeath(entity:Entity, damageInfo:DeathInfo):Void
    {
        super.PostDeath(entity, damageInfo);
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.SACRIFICE))
        {
            entity.AddBuff(SacrificedBuff);
        }
        else if (entity.WillRemoveOnDeath(damageInfo))
        {
            entity.Remove();
        }
        else
        {
            entity.PlayDeathSound();
            entity.Remove();
        }
        if (!damageInfo.Effects.HasEffect(VanillaDamageEffects.PICKAXE))
        {
            entity.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_CONTRAPTION_DESTROY, new EntityCallbackParams(entity), entity.GetDefinitionID());
        }
    }
}
