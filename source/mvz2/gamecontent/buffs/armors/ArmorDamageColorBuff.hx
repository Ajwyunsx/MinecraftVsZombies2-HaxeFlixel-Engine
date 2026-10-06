// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Armor/Core/ArmorDamageColorBuff.cs
package mvz2.gamecontent.buffs.armors;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.armors.EngineArmorProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Armor_armorDamageColor)
class ArmorDamageColorBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineArmorProps.COLOR_OFFSET, new Color(1, 0, 0, 0.5)));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMEOUT, 2);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);
        if (timeout > 0)
            return;
        buff.Remove();
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
}
