// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter1/GlowstoneEvokeBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BlendOperator;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.FrameTimer;
import unity.Color;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Contraption_glowstoneEvoke)
class GlowstoneEvokeBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(LogicEntityProps.LIGHT_RANGE, NumberOperator.Multiply, PROP_RANGE_MULTIPLIER));
        AddModifier(new ColorModifier(LogicEntityProps.LIGHT_COLOR, BlendOperator.One, BlendOperator.One, PROP_COLOR_MULTIPLIER));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(15));
        UpdateMultipliers(buff);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        UpdateMultipliers(buff);

        var timer = buff.GetProperty(PROP_TIMER);
        if (timer == null)
        {
            buff.Remove();
            return;
        }
        timer.Run();
        if (timer.Expired)
        {
            buff.Remove();
        }
    }
    function UpdateMultipliers(buff:Buff):Void
    {
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer != null)
        {
            var percentage = timer.Frame / timer.MaxFrame;
            buff.SetProperty(PROP_RANGE_MULTIPLIER, Vector3.one * percentage * 10);
            buff.SetProperty(PROP_COLOR_MULTIPLIER, new Color(percentage, percentage, percentage, percentage));
        }
    }
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("Timer");
    public static var PROP_RANGE_MULTIPLIER:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("RangeMultiplier");
    public static var PROP_COLOR_MULTIPLIER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("ColorMultiplier");
}
