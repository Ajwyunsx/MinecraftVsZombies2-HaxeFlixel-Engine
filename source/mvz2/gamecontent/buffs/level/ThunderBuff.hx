// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter1/ThunderBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicAreaProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Level_thunder)
class ThunderBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(LogicAreaProps.BACKGROUND_LIGHT, PROP_LIGHT_BLEND));
        AddModifier(new ColorModifier(LogicAreaProps.GLOBAL_LIGHT, PROP_LIGHT_BLEND));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_LIGHT_BLEND, new Color(1, 1, 1, 1));
        buff.SetProperty(PROP_TIMEOUT, MAX_TIMEOUT);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);
        var light = timeout / MAX_TIMEOUT;
        buff.SetProperty(PROP_LIGHT_BLEND, new Color(1, 1, 1, light));
        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    public static var PROP_LIGHT_BLEND:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("LightBlend");
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var MAX_TIMEOUT:Int = 30;
}
