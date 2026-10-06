// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter6/Gravel.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.fragments.VanillaFragmentID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.effects.FragmentExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import pvzengine.entities.EntityTypes;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.gravel)
class Gravel extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_HIT, PostHitEntityCallback);
    }
    private function PostHitEntityCallback(param:PostProjectileHitParams, result:CallbackResult):Void
    {
        var hitResult = param.hit;
        var projectile = hitResult.Projectile;
        if (!projectile.Definition.HasBehaviour(this))
            return;
        if (hitResult.Pierce)
            return;
        var damage = param.damage;
        var enemy = hitResult.Other;
        // C#: damage?.BodyResult == null && damage?.ArmorResult == null
        if ((damage == null || damage.BodyResult == null) && (damage == null || damage.ArmorResult == null))
            return;
        if (enemy.Type != EntityTypes.ENEMY || !enemy.CanDeactive())
            return;
        enemy.InflictGravel(150, new EntitySourceReference(projectile));
    }
    public override function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);
        if (entity.WillRemoveOnDeath(deathInfo))
            return;
        FragmentExt.CreateFragmentAndPlay(entity, VanillaFragmentID.gravelpult, 50);
        entity.PlaySound(VanillaSoundID.butter);
    }
}
