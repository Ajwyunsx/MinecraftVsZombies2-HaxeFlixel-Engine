// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter3/WitherClearedBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.level.LogicStageProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Level_witherCleared)
class WitherClearedBuff extends BuffDefinition
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

        if (timeout > FADEOUT_TIMEOUT)
        {
            // 屏幕变白
            var t = 1 - (timeout - FADEOUT_TIMEOUT) / (MAX_TIMEOUT - FADEOUT_TIMEOUT);
            t = t * 2;
            var cover = Color.Lerp(Color.clear, Color.white, t);
            buff.SetProperty(PROP_SCREEN_COVER, cover);
        }
        else if (timeout > 0)
        {
            // 屏幕淡出
            var t = 1 - timeout / FADEOUT_TIMEOUT;
            var cover = Color.Lerp(Color.white, Color.clear, t);
            buff.SetProperty(PROP_SCREEN_COVER, cover);
        }
        else
        {
            level.Clear();
            buff.Remove();
        }
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static var PROP_SCREEN_COVER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("ScreenCover");
    public static inline var BLACK_SCREEN_SPEED:Float = 1 / 180;
    public static inline var MAX_TIMEOUT:Int = FADEOUT_TIMEOUT + 30;
    public static inline var FADEOUT_TIMEOUT:Int = 60;
}
