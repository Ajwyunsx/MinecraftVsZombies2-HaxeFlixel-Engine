// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter1/FrankensteinStageBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicAreaProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Level_frankensteinStage)
class FrankensteinStageBuff extends BuffDefinition
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
        buff.SetProperty(PROP_THUNDER_TIMEOUT, MAX_THUNDER_TIMEOUT);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeout = buff.GetProperty(PROP_THUNDER_TIMEOUT);
        timeout--;
        if (timeout <= 0)
        {
            timeout = MAX_THUNDER_TIMEOUT;
            VanillaLevelExt.Thunder(buff.Level);
        }
        buff.SetProperty(PROP_THUNDER_TIMEOUT, timeout);


        var time = buff.GetProperty(PROP_TIME);
        if (time < MAX_TIME)
        {
            time++;
            buff.SetProperty(PROP_TIME, time);
        }
        var colorComp = 1 - time / MAX_TIME * 0.5;
        buff.SetProperty(PROP_LIGHT_MULTIPLIER, new Color(colorComp, colorComp, colorComp, 1));
    }
    public static var PROP_LIGHT_MULTIPLIER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("LightMultiplier");
    public static var PROP_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Time");
    public static var PROP_THUNDER_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("ThunderTimeout");
    public static inline var MAX_THUNDER_TIMEOUT:Int = 150;
    public static inline var MAX_TIME:Int = 30;
}
