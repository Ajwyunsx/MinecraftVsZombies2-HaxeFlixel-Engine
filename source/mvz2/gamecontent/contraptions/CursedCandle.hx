// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/CursedCandle.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.entities.CursedCandleBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.cursedCandle)
class CursedCandle extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_ENEMY_MELEE_ATTACK, PostEnemyMeleeAttackCallback);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetModelProperty("Evoked", entity.IsEvoked());
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        entity.PlaySound(VanillaSoundID.happyBirthday);
    }
    function PostEnemyMeleeAttackCallback(param:EnemyMeleeAttackParams, result:CallbackResult):Void
    {
        var enemy = param.enemy;
        var target = param.target;
        if (!target.Definition.HasBehaviour(this))
            return;
        if (!target.IsHostile(enemy))
            return;
        if (target.IsAIFrozen())
            return;
        var evoked = target.IsEvoked();
        var evokedMultiplier = evoked ? 2 : 1;
        var buff = enemy.NewBuff(CursedCandleBuff);
        CursedCandleBuff.SetFireDamage(buff, target.GetDamage());
        CursedCandleBuff.SetExplosionDamage(buff, target.GetDamage() * EXPLOSION_DAMAGE_MULTIPLIER * evokedMultiplier);
        CursedCandleBuff.SetExplosionRange(buff, target.GetRange() * evokedMultiplier);
        CursedCandleBuff.SetEvoked(buff, evoked);
        enemy.AddBuff(buff);
        enemy.Spawn(VanillaEffectID.cursedFireParticles, enemy.GetCenter());
        target.PlaySound(VanillaSoundID.odd);
        target.PlaySound(VanillaSoundID.biohazard);

        if (enemy.IsEntityOf(VanillaEnemyID.emperorZombie) && evoked)
        {
            Global.Saves.Unlock(VanillaUnlockID.letThemEatCake);
        }

        target.Remove();
    }
    public static inline var EXPLOSION_DAMAGE_MULTIPLIER:Float = 45;
}
