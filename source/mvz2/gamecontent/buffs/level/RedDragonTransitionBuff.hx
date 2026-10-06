// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter5/Boss/RedDragonTransitionBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.bosses.RedDragon;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.progressbars.VanillaProgressBarID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import unity.Mathf;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Level_redDragonTransition)
class RedDragonTransitionBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMEOUT, MAX_TIMEOUT);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);

        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);

        var level = buff.Level;
        if (timeout > FINISH_TIMEOUT)
        {
            // 音乐放缓。
            LogicLevelExt.SetMusicVolume(level, Mathf.Clamp01(LogicLevelExt.GetMusicVolume(level) - (1 / 30)));
            if (timeout == ROAR_1_TIMEOUT)
            {
                level.ShakeScreen(10, 0, 15);
                LogicLevelExt.PlaySound(level, VanillaSoundID.dragonGrowl);
            }
            if (timeout == ROAR_2_TIMEOUT)
            {
                level.ShakeScreen(15, 0, 20);
                LogicLevelExt.PlaySound(level, VanillaSoundID.dragonGrowl);
            }
        }
        else if (timeout == FINISH_TIMEOUT)
        {
            level.ShakeScreen(20, 0, 30);
            // C#: level.Spawn(...)?.Let(e => { ... });
            var dragon = level.Spawn(VanillaBossID.redDragon, new Vector3(RedDragon.APPEAR_START_X, RedDragon.APPEAR_START_Y, level.GetLawnCenterZ()), null);
            if (dragon != null)
            {
                RedDragon.SetAppear(dragon);
                VanillaBossExt.ApplyBuffForBossRevenge(dragon, 0.8);
            }
        }
        else
        {
            if (level.EntityExists(function(e) return e.IsEntityOf(VanillaBossID.redDragon) && e.State == RedDragon.STATE_IDLE))
            {
                // 音乐。
                LogicLevelExt.PlayMusic(level, VanillaMusicID.shipBoss);
                LogicLevelExt.SetMusicVolume(level, 1);
                LogicLevelExt.SetSubtrackWeight(level, 0);
                LogicLevelExt.SetProgressBarToBoss(level, VanillaProgressBarID.redDragon);
                buff.Remove();
            }
        }
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var MAX_TIMEOUT:Int = ROAR_1_TIMEOUT + 60;

    public static inline var ROAR_1_TIMEOUT:Int = ROAR_2_TIMEOUT + 90;
    public static inline var ROAR_2_TIMEOUT:Int = FINISH_TIMEOUT + 90;
    public static inline var FINISH_TIMEOUT:Int = 0;
}
