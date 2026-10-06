// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter4/LightningOrb.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.LightningOrbEvokedBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.lightningOrb)
class LightningOrb extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.PRE_PROJECTILE_HIT, PreProjectileHitCallback);
    }
    override function UpdateLogic(contraption:Entity):Void
    {
        super.UpdateLogic(contraption);
        contraption.SetAnimationFloat("Damaged", 1 - contraption.Health / contraption.GetMaxHealth());
        contraption.SetAnimationBool("Absorbing", contraption.HasBuff(LightningOrbEvokedBuff));
    }
    function PreProjectileHitCallback(param:PreProjectileHitParams, result:CallbackResult):Void
    {
        var hit = param.hit;
        var damage = param.damage;
        if (NamespaceID.IsValid(damage.ShieldTarget))
            return;
        var orb = hit.Other;
        if (!orb.Definition.HasBehaviour(this))
            return;

        var projectile = hit.Projectile;

        orb.HealEffects(HEAL_AMOUNT, projectile);
        for (buff in orb.GetBuffs(LightningOrbEvokedBuff))
        {
            LightningOrbEvokedBuff.AddTakenDamage(buff, damage.Amount);
        }
        projectile.Remove();
        result.SetFinalValue(false);
        orb.PlaySound(VanillaSoundID.energyShieldHit);
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        if (entity.HasBuff(LightningOrbEvokedBuff))
            return false;
        return super.CanEvoke(entity);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.PlaySound(VanillaSoundID.lightningAttack);
        entity.AddBuff(LightningOrbEvokedBuff);
    }
    public static inline var HEAL_AMOUNT:Float = 100;
}
