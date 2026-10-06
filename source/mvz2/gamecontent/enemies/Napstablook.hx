// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter1/Napstablook.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.buffs.enemies.GhostBuff;
import mvz2.gamecontent.buffs.enemies.NapstablookAngryBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.gamecontent.helditems.SwordHeldItemBehaviour;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageInput;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.napstablook)
class Napstablook extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        if (!entity.HasBuff(GhostBuff))
        {
            entity.AddBuff(GhostBuff);
        }
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 1);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.State == STATE_ANGRY)
        {
            var ghostBuff = entity.GetBuffs(GhostBuff);
            for (buff in ghostBuff)
            {
                GhostBuff.Illuminate(buff);
            }
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        if (!entity.HasBuff(GhostBuff))
        {
            entity.AddBuff(GhostBuff);
        }
    }
    public override function PreTakeDamage(input:DamageInput, result:CallbackResult):Void
    {
        super.PreTakeDamage(input, result);
        var entity = input.Entity;
        if (entity == null)
            return;
        if (input.Effects.HasEffect(VanillaDamageEffects.WHACK))
        {
            Enrage(entity);
            SwordHeldItemBehaviour.Paralyze(entity.Level);
        }
        result.SetFinalValue(false);
    }
    public static function Enrage(entity:Entity):Void
    {
        entity.AddBuff(NapstablookAngryBuff);
    }
    public static function IsAngry(entity:Entity):Bool
    {
        return entity.HasBuff(NapstablookAngryBuff);
    }
    public static inline var STATE_ANGRY:Int = VanillaEnemyStates.NAPSTABLOOK_ANGRY;
}
