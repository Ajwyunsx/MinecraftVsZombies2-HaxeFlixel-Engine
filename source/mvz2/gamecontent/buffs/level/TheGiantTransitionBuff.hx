// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter4/Boss/TheGiantTransitionBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.bosses.TheGiant;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.progressbars.VanillaProgressBarID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Level_theGiantTransition)
class TheGiantTransitionBuff extends BuffDefinition
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
        if (timeout >= STATE_1_TIMEOUT)
        {
            // 消除小神灵宇宙。
            for (eye in level.FindEntities(VanillaEffectID.spiritUniverse))
            {
                if (eye.Timeout <= 0)
                {
                    eye.Timeout = 30;
                }
            }
            // 音乐放缓。
            LogicLevelExt.SetMusicVolume(level, Mathf.Clamp01(LogicLevelExt.GetMusicVolume(level) - (1 / 30)));
            if (timeout == SHAKE_TIMEOUT)
            {
                LogicLevelExt.PlaySound(level, VanillaSoundID.smallExplosion);
                level.ShakeScreen(5, 0, 5);
            }
        }
        else if (timeout >= STATE_2_TIMEOUT)
        {
            if (timeout == BIG_SHAKE_TIMEOUT)
            {
                LogicLevelExt.PlaySound(level, VanillaSoundID.explosion);
                LogicLevelExt.PlaySound(level, VanillaSoundID.giantSpike);
                level.ShakeScreen(15, 0, 30);
            }
            else if (timeout == ROAR_TIMEOUT)
            {
                LogicLevelExt.PlaySound(level, VanillaSoundID.giantRoar);
                level.ShakeScreen(15, 0, 90);
                level.Spawn(VanillaEffectID.amplifiedRoar, new Vector3(LevelPositions.LEVEL_WIDTH, 0, level.GetLawnCenterZ()), null);
            }
            if (timeout == STATE_2_TIMEOUT)
            {
                // C#: level.Spawn(...)?.Let(e => { ... });
                var giant = level.Spawn(VanillaBossID.theGiant, new Vector3(LevelPositions.LEVEL_WIDTH, 0, level.GetLawnCenterZ()), null);
                if (giant != null)
                {
                    TheGiant.SetAppear(giant);
                    VanillaBossExt.ApplyBuffForBossRevenge(giant, 0.8);
                }
                // 音乐。
                LogicLevelExt.PlayMusic(level, VanillaMusicID.mausoleumBoss);
                LogicLevelExt.SetMusicVolume(level, 1);
                LogicLevelExt.SetSubtrackWeight(level, 0);
                LogicLevelExt.SetProgressBarToBoss(level, VanillaProgressBarID.theGiant);
                buff.Remove();
            }
        }
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var MAX_TIMEOUT:Int = STATE_1_TIMEOUT + 60;

    public static inline var STATE_1_TIMEOUT:Int = SHAKE_TIMEOUT;
    public static inline var SHAKE_TIMEOUT:Int = BIG_SHAKE_TIMEOUT + 30;

    public static inline var BIG_SHAKE_TIMEOUT:Int = ROAR_TIMEOUT + 30;
    public static inline var ROAR_TIMEOUT:Int = STATE_2_TIMEOUT + 100;
    public static inline var STATE_2_TIMEOUT:Int = 0;
}
