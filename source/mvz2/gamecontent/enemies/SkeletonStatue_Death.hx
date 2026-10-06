// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/SkeletonStatue_Death.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import tools.TimerHelper;
using mvz2.vanilla.effects.FragmentExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skeletonStatue_Death)
class SkeletonStatue_Death extends EnemyDeathDisappearBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PreDeath(entity:Entity, deathInfo:DeathInfo, result:CallbackResult):Void
    {
        super.PreDeath(entity, deathInfo, result);
        if (deathInfo.HasEffect(VanillaDamageEffects.DROWN) || deathInfo.HasEffect(VanillaDamageEffects.FALL_OFF))
            return;
        if (deathInfo.HasEffect(VanillaDamageEffects.NO_REVIVAL))
            return;
        if (!SkeletonStatue.IsReviving(entity) && !entity.WillRemoveOnDeath(deathInfo))
        {
            entity.Health = entity.GetMaxHealth();
            SkeletonStatue.SetReviving(entity, true);
            var timer = SkeletonStatue.GetReviveTimer(entity);
            if (timer != null)
            {
                timer.ResetSeconds(timer.GetMaxSeconds() + SkeletonStatue.REVIVE_SECONDS_PER_DEATH);
            }
            else
            {
                timer = TimerHelper.NewSecondTimer(SkeletonStatue.REVIVE_SECONDS);
            }
            entity.AddFragmentTickDamage(500);
            entity.PlayDeathSound();
            result.SetValue(false);
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (info.HasEffect(VanillaDamageEffects.DROWN) || info.HasEffect(VanillaDamageEffects.FALL_OFF))
            return;
        entity.Remove();
    }
}
