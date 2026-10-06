// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter4/SpiritUniverseNightBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicAreaProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Level_spiritUniverseNight)
class SpiritUniverseNightBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(LogicAreaProps.BACKGROUND_TINT, PROP_BACKGROUND_TINT_MULTIPLIER));
    }
    public static function SetBackgroundLightMultiplier(buff:Buff, color:Color):Void
    {
        buff.SetProperty(PROP_BACKGROUND_TINT_MULTIPLIER, color);
    }
    public static var PROP_BACKGROUND_TINT_MULTIPLIER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("background_tint_multiplier");
}
