// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/ElasticCloud/ElasticCloud_Projectile.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.elasticCloud_Projectile)
class ElasticCloud_Projectile extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.PRE_PROJECTILE_HIT, PreProjectileHitCallback);
    }
    function PreProjectileHitCallback(param:PreProjectileHitParams, result:CallbackResult):Void
    {
        var hit = param.hit;
        var proj = hit.Projectile;
        var target = hit.Other;
        if (!target.Definition.HasBehaviour(this)) // 被击中的实体必须有该Behaviour
            return;
        if (!target.IsHostile(proj)) // 实体和射弹必须是敌对的
            return;
        // 弹回射弹，并将阵营改为该实体的阵营。
        var velocity = target.GetFacingDirection() * proj.Velocity.magnitude;
        proj.Velocity = velocity;
        proj.SetFaction(target.GetFaction());
        target.TakeDamage(BOUNCE_DAMAGE, new DamageEffectList([]), target);
        ElasticCloud.PlayBounceEffect(target);
        result.SetFinalValue(false);
    }
    public static inline var BOUNCE_DAMAGE:Float = 20;
}
