// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter2/NightmareaperTransitionBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.bosses.Nightmareaper;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossExt;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.level.LogicStageProps;
import mvz2logic.localization.LogicStrings;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Level_nightmareaperTransition)
class NightmareaperTransitionBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(LogicLevelProps.SCREEN_COVER, PROP_SCREEN_COVER));
        AddModifier(new BooleanModifier(LogicLevelProps.PAUSE_DISABLED, true));
        AddModifier(new BooleanModifier(LogicStageProps.AUTO_COLLECT_ALL, true));
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

        if (timeout == CREATE_GLASS_TIMEOUT)
        {
            // 创建梦魇玻璃
            level.Spawn(VanillaEffectID.nightmareGlass, new Vector3(0, 0, 0), null);
            // Play Sound.
            LogicLevelExt.PlaySound(level, VanillaSoundID.dialogJudge);
        }
        else if (timeout <= 0)
        {
            // 梦魇收割者出现
            LogicLevelExt.PlayMusic(level, VanillaMusicID.nightmareBoss2);
            // Create Boss
            var pos = new Vector3(level.GetEntityColumnX(4), 0, level.GetEntityLaneZ(2));
            // C#: level.Spawn(...)?.Let(e => { ... });
            var boss = level.Spawn(VanillaBossID.nightmareaper, pos, null);
            if (boss != null)
            {
                Nightmareaper.Appear(boss);
                VanillaBossExt.ApplyBuffForBossRevenge(boss);
            }

            level.ShowAdvice(LogicStrings.CONTEXT_ADVICE, VanillaStrings.ADVICE_CLICK_TO_DRAG_CRUSHING_WALLS, 100, 120, []);

            buff.Remove();
        }
        var blackScreen = buff.GetProperty(PROP_SCREEN_COVER);
        blackScreen.a = Mathf.Clamp01(blackScreen.a + BLACK_SCREEN_SPEED);
        buff.SetProperty(PROP_SCREEN_COVER, blackScreen);
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static var PROP_SCREEN_COVER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("ScreenCover");
    public static inline var BLACK_SCREEN_SPEED:Float = 1 / 180;
    public static inline var MAX_TIMEOUT:Int = 270;
    public static inline var CREATE_GLASS_TIMEOUT:Int = 60;
}
