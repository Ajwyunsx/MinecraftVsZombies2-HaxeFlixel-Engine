// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter6/SpectralArrow.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.spectralArrow)
class SpectralArrow extends EntityBehaviourDefinition
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
        var damage = param.damage;
        var enemy = hitResult.Other;
        // C#: damage?.BodyResult == null && damage?.ArmorResult == null
        if ((damage == null || damage.BodyResult == null) && (damage == null || damage.ArmorResult == null))
            return;
        enemy.InflictGlowing(150, new EntitySourceReference(projectile));
    }
}
