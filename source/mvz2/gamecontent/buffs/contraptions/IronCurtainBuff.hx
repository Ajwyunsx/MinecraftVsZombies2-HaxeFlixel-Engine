// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter3/IronCurtainBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Contraption_ironCurtain)
class IronCurtainBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_TINT));
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

        var comp = Mathf.Cos(Mathf.Deg2Rad * timeout * 24) * 0.25 + 0.5;
        var tint = new Color(comp, 0, 0, 1);
        buff.SetProperty(PROP_TINT, tint);

        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static var PROP_TINT:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("Tint");
    public static inline var MAX_TIMEOUT:Int = 150;
}
