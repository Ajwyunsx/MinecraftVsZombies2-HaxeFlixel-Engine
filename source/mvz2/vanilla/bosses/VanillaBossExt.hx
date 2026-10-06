// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/VanillaBossExt.cs
package mvz2.vanilla.bosses;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.bosses.BossRevengeBuff;
import mvz2.gamecontent.buffs.contraptions.NoteBlockChargedBuff;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicStageProps;
import pvzengine.buffs.Buff;
import pvzengine.entities.Entity;

// PORT-NOTE: C# 的扩展方法在本移植中为静态方法；调用点沿用扩展方法风格，故以 `using` 引入对应模块。
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

class VanillaBossExt
{
    // C#: extension method ApplyBuffForBossRevenge(this Entity entity, float healthMultiplier = 1.5f)
    public static function ApplyBuffForBossRevenge(entity:Entity, healthMultiplier:Float = 1.5):Void
    {
        // PORT-NOTE: C# 为扩展方法 entity.Level.IsBossRevenge()，移植后位于 LogicStageProps。
        if (!LogicStageProps.IsBossRevenge(entity.Level))
            return;
        var buff = entity.AddBuff(VanillaBuffID.Boss.bossRevenge);
        if (buff != null)
        {
            buff.SetProperty(BossRevengeBuff.PROP_HEALTH_MULTIPLIER, healthMultiplier);
        }
    }
    // C#: extension method IsBossRevengeVersion(this Entity entity)
    public static function IsBossRevengeVersion(entity:Entity):Bool
    {
        return entity.HasBuff(VanillaBuffID.Boss.bossRevenge);
    }
    // C#: extension method BossRoar(this Entity entity, int stunTime)
    public static function BossRoar(entity:Entity, stunTime:Int):Void
    {
        for (ent in entity.Level.FindEntities(function(e) return CanBossRoarStun(entity, e)))
        {
            if (ent.IsEntityOf(VanillaContraptionID.lightningOrb))
                continue;
            if (ent.IsEntityOf(VanillaContraptionID.noteBlock))
            {
                if (!ent.HasBuff(NoteBlockChargedBuff))
                {
                    ent.AddBuff(NoteBlockChargedBuff);
                    ent.PlaySound(VanillaSoundID.growBig);
                }
                continue;
            }
            ent.Stun(stunTime);
        }
    }
    // C#: extension method CanBossRoarStun(this Entity entity, Entity target)
    public static function CanBossRoarStun(entity:Entity, target:Entity):Bool
    {
        return (target.Type == EntityTypes.PLANT || target.Type == EntityTypes.ENEMY) && target.IsHostile(entity) && VanillaEntityProps.CanDeactive(target);
    }
}
