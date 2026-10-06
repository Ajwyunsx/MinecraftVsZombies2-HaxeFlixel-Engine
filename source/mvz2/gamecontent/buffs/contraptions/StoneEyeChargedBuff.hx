// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter6/StoneEyeChargedBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Contraption_stoneEyeCharged)
class StoneEyeChargedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, PROP_COLOR_OFFSET));
    }

    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        UpdateColorOffset(buff);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var time = buff.GetProperty(PROP_TIME);
        time = (time + 1) % MAX_TIME;
        buff.SetProperty(PROP_TIME, time);
        UpdateColorOffset(buff);
    }
    function UpdateColorOffset(buff:Buff):Void
    {
        var time = buff.GetProperty(PROP_TIME);
        var alpha = 1 - time / MAX_TIME;
        buff.SetProperty(PROP_COLOR_OFFSET, new Color(1, 1, 1, alpha));
    }
    public static inline var MAX_TIME:Int = 30;
    public static var PROP_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Time");
    public static var PROP_COLOR_OFFSET:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("ColorOffset");
}
