// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Common/ExplodeOnFireDeathBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.explodeOnFireDeath)
class ExplodeOnFireDeathBehaviour extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEntityDeathCallback, EntityTypes.PLANT);
    }
    function PostEntityDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (!entity.Definition.HasBehaviour(this))
            return;
        if (!info.HasEffect(VanillaDamageEffects.SACRIFICE) &&
            !info.HasEffect(VanillaDamageEffects.FIRE) &&
            !info.HasEffect(VanillaDamageEffects.EXPLOSION))
            return;
        if (entity.NoExplosion())
            return;
        var range = entity.GetRange();
        var damage = entity.GetDamage();
        entity.BehaviourExplode(range, damage);
        entity.Remove();
    }
}
