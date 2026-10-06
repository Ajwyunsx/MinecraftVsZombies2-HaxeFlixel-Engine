// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter2/TaintedSunBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicAreaProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Level_taintedSun)
class TaintedSunBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(LogicAreaProps.GLOBAL_LIGHT, PROP_LIGHT_MULTIPLIER));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_LIGHT_MULTIPLIER, Color.black);
        buff.SetProperty(PROP_TIMEOUT, MAX_TIMEOUT);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);
        var light = Mathf.Clamp01(1 - timeout / FADE_MAX_TIMEOUT);
        buff.SetProperty(PROP_LIGHT_MULTIPLIER, new Color(light, light, light, 1));
        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    public static var PROP_LIGHT_MULTIPLIER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("LightMultiplier");
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var MAX_TIMEOUT:Int = 330;
    public static inline var FADE_MAX_TIMEOUT:Int = 30;
}
