// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/Infectenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.entities.ParabotBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import unity.Mathf;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.infectenser)
class Infectenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            ShootTick(entity);
            return;
        }
    }
    public override function Shoot(entity:Entity):Null<Entity>
    {
        var projectile = super.Shoot(entity);
        if (projectile != null)
        {
            projectile.Timeout = Mathf.CeilToInt(entity.GetRange() / entity.GetShotVelocity().magnitude);
        }
        return projectile;
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var playSound = false;
        for (target in entity.Level.FindEntities(e -> e.HasBuff(ParabotBuff)))
        {
            var buffs = target.GetBuffs(ParabotBuff);
            for (buff in buffs)
            {
                if (entity.IsFriendly(buff.GetProperty(ParabotBuff.PROP_FACTION)))
                {
                    buff.SetProperty(ParabotBuff.PROP_EXPLODE_TIME, MAX_EXPLOSION_TIMEOUT);
                    playSound = true;
                }
            }
        }
        if (playSound)
        {
            entity.PlaySound(VanillaSoundID.parabotTick);
        }
    }
    public static inline var MAX_EXPLOSION_TIMEOUT:Int = 24;
}
