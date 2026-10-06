// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter4/SlowBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.FrameTimer;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Enemy_slow)
class SlowBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, new Color(0.5, 0.5, 1, 1)));
        AddModifier(new FloatModifier(VanillaEnemyProps.SPEED, NumberOperator.Multiply, 0.5));
        AddModifier(new FloatModifier(VanillaEntityProps.ATTACK_SPEED, NumberOperator.Multiply, 0.5));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(300));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
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
    public static function SetTimeout(buff:Buff, value:Int):Void
    {
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer == null)
        {
            timer = new FrameTimer(value);
            buff.SetProperty(PROP_TIMER, timer);
        }
        timer.ResetTime(value);
    }

    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("Timer");
}
