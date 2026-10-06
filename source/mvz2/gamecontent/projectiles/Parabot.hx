// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter2/Parabot.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.buffs.entities.ParabotBuff;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityBehaviourDefinition;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.parabot)
class Parabot extends EntityBehaviourDefinition
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
        var damage = param.damage;
        if (hitResult.Shield != null)
            return;
        var other = hitResult.Other;
        var buff = other.GetFirstBuff(ParabotBuff);
        if (buff == null)
        {
            buff = other.AddBuff(ParabotBuff);
        }
        buff.SetProperty(ParabotBuff.PROP_FACTION, projectile.GetFaction());
        buff.SetProperty(ParabotBuff.PROP_TIMEOUT, MAX_TIMEOUT);
    }
    public static inline var MAX_TIMEOUT:Int = 180;
}
