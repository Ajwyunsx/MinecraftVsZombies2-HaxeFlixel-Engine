// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter3/WitherTransitionBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.progressbars.VanillaProgressBarID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.ColorModifier;
import tools.FrameTimer;
import unity.Color;
import unity.Mathf;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Level_witherTransition)
class WitherTransitionBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(LogicLevelProps.SCREEN_COVER, PROP_SCREEN_COVER));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(MAX_TIMEOUT));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);

        var timer = buff.GetProperty(PROP_TIMER);
        if (timer != null)
            timer.Run();

        var level = buff.Level;
        var state = buff.GetProperty(PROP_STATE);
        switch (state)
        {
            case STATE_START:
                // 让辉光消失。
                for (eye in level.FindEntities(VanillaEffectID.castleTwilight))
                {
                    if (eye.Timeout <= 0)
                    {
                        eye.Timeout = 30;
                    }
                }
                // 音乐放缓。
                LogicLevelExt.SetMusicVolume(level, Mathf.Clamp01(LogicLevelExt.GetMusicVolume(level) - (1 / 30)));
                if (timer != null && timer.Expired)
                {
                    var column = Std.int(level.GetMaxColumnCount() / 2);
                    var lane = Std.int(level.GetMaxLaneCount() / 2);
                    var x = level.GetEntityColumnX(column);
                    var z = level.GetEntityLaneZ(lane);
                    var y = level.GetGroundY(x, z) + 80;
                    level.Spawn(VanillaEffectID.witherSummoners, new Vector3(x, y, z), null);
                    LogicLevelExt.SetMusicVolume(level, 1);
                    LogicLevelExt.PlayMusic(level, VanillaMusicID.witherBoss);

                    buff.SetProperty(PROP_STATE, STATE_SUMMONING);
                }
            case STATE_SUMMONING:
                if (level.EntityExists(function(e) return e.Type == EntityTypes.BOSS && LogicEntityExt.IsHostileEntity(e) && !e.IsDead))
                {
                    // 凋灵出现
                    LogicLevelExt.SetProgressBarToBoss(level, VanillaProgressBarID.wither);
                    level.ShakeScreen(30, 0, 30);

                    buff.SetProperty(PROP_STATE, STATE_SUMMONED);
                    buff.SetProperty(PROP_SCREEN_COVER, Color.white);
                    if (timer != null)
                        timer.ResetTime(2);
                }
            case STATE_SUMMONED:
                if (timer != null && timer.Expired)
                {
                    buff.Remove();
                }
        }
    }
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("Timer");
    public static var PROP_STATE:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("State");
    public static var PROP_SCREEN_COVER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("ScreenCover");
    public static inline var STATE_START:Int = 0;
    public static inline var STATE_SUMMONING:Int = 1;
    public static inline var STATE_SUMMONED:Int = 2;
    public static inline var MAX_TIMEOUT:Int = 90;
}
