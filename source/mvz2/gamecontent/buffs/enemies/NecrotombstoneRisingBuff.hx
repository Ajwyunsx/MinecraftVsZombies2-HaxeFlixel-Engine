// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter4/NecrotombstoneRisingBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.FrameTimer;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Enemy_necrotombstoneRising)
class NecrotombstoneRisingBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineEntityProps.GROUND_LIMIT_OFFSET, NumberOperator.Add, PROP_GROUND_LIMIT_OFFSET));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_GROUND_LIMIT_OFFSET, -100.0);
        buff.SetProperty(PROP_TIMER, new FrameTimer(MAX_TIME));
        var entity = buff.GetEntity();
        if (entity != null)
        {
            entity.SetModelProperty("Rising", true);
        }
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer == null || timer.Expired)
        {
            buff.Remove();
            return;
        }

        timer.Run();

        var entity = buff.GetEntity();
        if (entity != null)
        {
            if (entity.IsDead)
            {
                buff.Remove();
                return;
            }
            buff.SetProperty(PROP_GROUND_LIMIT_OFFSET, Mathf.Lerp(-100, 0, timer.GetPassedPercentage()));
            entity.SetModelProperty("Rising", true);
        }
    }
    public override function PostRemove(buff:Buff):Void
    {
        super.PostRemove(buff);
        var entity = buff.GetEntity();
        if (entity != null)
        {
            entity.SetModelProperty("Rising", false);
        }
    }
    public static inline var MAX_TIME:Int = 30;
    public static var PROP_GROUND_LIMIT_OFFSET:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("groundLimitOffset");
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
}
