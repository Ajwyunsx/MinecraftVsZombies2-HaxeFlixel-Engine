// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter1/Knife.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityBehaviourDefinition;
using mvz2.vanilla.shells.VanillaShellProps;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.knife)
class Knife extends EntityBehaviourDefinition
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
        var damageOutput = param.damage;
        if (damageOutput == null)
            return;
        // C#: damageOutput.GetAllResults().Any(e => e?.ShellDefinition?.BlocksSlice() ?? false)
        var blocksSlice = Lambda.exists(damageOutput.GetAllResults(), e -> e != null && e.ShellDefinition != null && e.ShellDefinition.BlocksSlice());
        if (!blocksSlice)
        {
            hitResult.Pierce = true;
        }
    }
}
