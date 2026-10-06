// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter2/Dart.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.shells.VanillaShellID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import pvzengine.entities.EntityTypes;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.dart)
class Dart extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_HIT, PostHitEntityCallback);
    }
    function PostHitEntityCallback(param:PostProjectileHitParams, result:CallbackResult):Void
    {
        var hitResult = param.hit;
        var projectile = hitResult.Projectile;
        if (!projectile.Definition.HasBehaviour(this))
            return;
        var enemy = hitResult.Other;
        if (enemy.Type != EntityTypes.ENEMY)
            return;
        var damage = param.damage;
        if (damage == null || damage.BodyResult == null)
            return;
        if (enemy.GetShellID() != VanillaShellID.flesh)
            return;
        enemy.InflictWeakness(150, new EntitySourceReference(projectile));
    }
}
