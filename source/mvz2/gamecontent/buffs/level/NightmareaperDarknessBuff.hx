// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter2/NightmareaperDarknessBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicAreaProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Level_nightmareaperDarkness)
class NightmareaperDarknessBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(LogicAreaProps.GLOBAL_LIGHT, PROP_LIGHT_MULTIPLIER));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_LIGHT_MULTIPLIER, Color.white);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);

        var time = buff.GetProperty(PROP_TIME);
        time++;
        buff.SetProperty(PROP_TIME, time);

        var light = Mathf.Clamp01(1 - Mathf.Min(time, timeout) / FADE_TIME);

        buff.SetProperty(PROP_LIGHT_MULTIPLIER, new Color(light, light, light, 1));

        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    public static function CancelDarkness(buff:Buff):Void
    {
        buff.SetProperty(PROP_TIMEOUT, FADE_TIME);
    }
    public static var PROP_LIGHT_MULTIPLIER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("LightMultiplier");
    public static var PROP_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Time");
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var MAX_DARKNESS:Float = 1;
    public static inline var FADE_TIME:Int = 30;
}
