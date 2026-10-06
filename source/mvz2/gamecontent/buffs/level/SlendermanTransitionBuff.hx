// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter2/SlendermanTransitionBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.progressbars.VanillaProgressBarID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicAreaProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Level_slendermanTransition)
class SlendermanTransitionBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(LogicAreaProps.BACKGROUND_TINT, PROP_BACKGROUND_TINT));
        AddModifier(new BooleanModifier(LogicLevelProps.PAUSE_DISABLED, true));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMEOUT, MAX_TIMEOUT);
        buff.SetProperty(PROP_BACKGROUND_TINT, Color.white);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);

        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);

        var level = buff.Level;
        if (timeout > CREATE_DARKNESS_TIMEOUT)
        {
            // 让眼睛闭眼。
            for (eye in level.FindEntities(VanillaEffectID.nightmareWatchingEye))
            {
                if (eye.Timeout <= 0)
                {
                    eye.Timeout = 30;
                }
            }
            // 音乐放缓。
            LogicLevelExt.SetMusicVolume(level, Mathf.Clamp01(LogicLevelExt.GetMusicVolume(level) - (1 / 30)));
        }
        if (timeout == CREATE_DARKNESS_TIMEOUT)
        {
            level.Spawn(VanillaEffectID.nightmareDarkness, new Vector3(0, 0, 0), null);
            // 音乐。
            LogicLevelExt.PlayMusic(level, VanillaMusicID.nightmareBoss);
            LogicLevelExt.SetMusicVolume(level, 1);
        }
        else if (timeout <= 0)
        {
            var pos = new Vector3(level.GetEntityColumnX(4), 0, level.GetEntityLaneZ(2));
            // C#: level.Spawn(...)?.Let(e => { ... });
            var boss = level.Spawn(VanillaBossID.slenderman, pos, null);
            if (boss != null)
            {
                boss.Velocity = Vector3.up * 5;
                LogicEntityExt.PlaySound(boss, VanillaSoundID.splashBig);
                LogicEntityExt.PlaySound(boss, VanillaSoundID.glassBreakBig);
                boss.Spawn(VanillaEffectID.nightmareaperSplash, pos);
                VanillaBossExt.ApplyBuffForBossRevenge(boss);
            }
            level.ShakeScreen(30, 0, 30);

            LogicLevelExt.SetProgressBarToBoss(level, VanillaProgressBarID.nightmare);

            buff.Remove();
        }

        var multiplier = buff.GetProperty(PROP_BACKGROUND_TINT);
        var lightSpeed = -LIGHT_SPEED;
        if (timeout < FADEOUT_TIMEOUT)
        {
            lightSpeed = LIGHT_SPEED;
        }
        multiplier.r = Mathf.Clamp01(multiplier.r + lightSpeed);
        multiplier.g = Mathf.Clamp01(multiplier.g + lightSpeed);
        multiplier.b = Mathf.Clamp01(multiplier.b + lightSpeed);
        buff.SetProperty(PROP_BACKGROUND_TINT, multiplier);
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static var PROP_BACKGROUND_TINT:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("background_tint");
    public static inline var LIGHT_SPEED:Float = 0.07;
    public static inline var MAX_TIMEOUT:Int = CREATE_DARKNESS_TIMEOUT + 90;
    public static inline var CREATE_DARKNESS_TIMEOUT:Int = FADEOUT_TIMEOUT + 165;
    public static inline var FADEOUT_TIMEOUT:Int = 15;
}
