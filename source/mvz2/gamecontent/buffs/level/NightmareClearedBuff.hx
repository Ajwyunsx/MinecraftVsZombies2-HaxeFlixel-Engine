// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter2/NightmareClearedBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.areas.Dream;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.level.LogicStageProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Level_nightmareCleared)
class NightmareClearedBuff extends BuffDefinition
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

        if (timeout > LIGHT_TIMEOUT)
        {
            // 屏幕逐渐变黑
            var cover = buff.GetProperty(PROP_SCREEN_COVER);
            var t = (timeout - LIGHT_TIMEOUT) / (MAX_TIMEOUT - LIGHT_TIMEOUT);
            t = t * 2 - 1;
            cover = Color.Lerp(Color.black, Color.clear, t);
            buff.SetProperty(PROP_SCREEN_COVER, cover);
        }
        else if (timeout > LIGHT_FADE_TIMEOUT)
        {
            if (timeout == LIGHT_TIMEOUT)
            {
                Dream.SetToDream(level);
            }
            // 屏幕变白
            var cover = buff.GetProperty(PROP_SCREEN_COVER);
            cover = Color.Lerp(Color.white, Color.black, (timeout - LIGHT_FADE_TIMEOUT) / (LIGHT_TIMEOUT - LIGHT_FADE_TIMEOUT));
            buff.SetProperty(PROP_SCREEN_COVER, cover);
        }
        else
        {
            if (timeout == LIGHT_FADE_TIMEOUT)
            {
                Global.Saves.Relock(VanillaUnlockID.dreamIsNightmare);
                level.Clear();
            }
            // 屏幕恢复
            var cover = buff.GetProperty(PROP_SCREEN_COVER);
            cover = Color.Lerp(new Color(1, 1, 1, 0), Color.white, timeout / LIGHT_FADE_TIMEOUT);
            buff.SetProperty(PROP_SCREEN_COVER, cover);
            if (timeout <= 0)
            {
                buff.Remove();
            }
        }
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static var PROP_SCREEN_COVER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("ScreenCover");
    public static inline var BLACK_SCREEN_SPEED:Float = 1 / 180;
    public static inline var MAX_TIMEOUT:Int = LIGHT_TIMEOUT + 120;
    public static inline var LIGHT_TIMEOUT:Int = LIGHT_FADE_TIMEOUT + 30;
    public static inline var LIGHT_FADE_TIMEOUT:Int = 60;
}
