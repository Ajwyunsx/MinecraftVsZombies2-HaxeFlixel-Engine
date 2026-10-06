// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter2/LilyPadEvocationBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.FrameTimer;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Contraption_lilyPadEvocation)
class LilyPadEvocationBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.SIZE, NumberOperator.Multiply, PROP_SIZE_MULTIPLIER));
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_SIZE_MULTIPLIER));
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
        if (timer == null || timer.RunToExpired())
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
            buff.SetProperty(PROP_SIZE_MULTIPLIER, Vector3.one * (1 - percentage));
        }
    }
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("Timer");
    public static var PROP_SIZE_MULTIPLIER:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("SizeMultiplier");
}
