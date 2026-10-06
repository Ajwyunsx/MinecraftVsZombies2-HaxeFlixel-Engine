// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Prologue/Miner.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2logic.entities.LogicEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.miner)
class Miner extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var timer = new FrameTimer(START_TIME);
        SetProductTimer(entity, timer);
        entity.SetShadowHidden(false);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (!entity.Level.IsNoEnergy() && (entity.Level.IsDay() || WorksAllDay(entity)))
        {
            var timer = GetProductTimer(entity);
            if (timer.RunToExpiredAndNotNull())
            {
                entity.Produce(VanillaPickupID.redstone);
                entity.PlaySound(VanillaSoundID.throwSound);
                timer.ResetTime(PRODUCE_TIME);
            }
            entity.SetAnimationBool("Open", true);
        }
        else
        {
            entity.SetAnimationBool("Open", false);
        }
    }
    public static function GetProductTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourField(PROP_PRODUCE_TIMER);
    }
    public static function SetProductTimer(entity:Entity, value:FrameTimer):Void
    {
        entity.SetBehaviourField(PROP_PRODUCE_TIMER, value);
    }
    public static function WorksAllDay(entity:Entity):Bool
    {
        return entity.GetBehaviourField(PROP_WORKS_ALL_DAY);
    }
    public static function SetWorksAllDay(entity:Entity, value:Bool):Void
    {
        entity.SetBehaviourField(PROP_WORKS_ALL_DAY, value);
    }
    // #endregion

    // #region 属性字段
    public static var PROP_WORKS_ALL_DAY:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("works_all_day");
    public static var PROP_PRODUCE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("produceTimer");
    public static inline var START_TIME:Int = 120;
    public static inline var PRODUCE_TIME:Int = 300;
    // #endregion
}
