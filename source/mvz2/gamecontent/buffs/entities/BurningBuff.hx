// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter6/BurningBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.models.LogicModelHelper;
import pvzengine.buffs.Buff;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import tools.FrameTimer;
import tools.TimerHelper;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Entity_burning)
class BurningBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.burning, VanillaModelID.burning);
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        SetTimer(buff, TimerHelper.NewSecondTimer(SECONDS));
        SetIntervalTimer(buff, TimerHelper.NewSecondTimer(DAMAGE_INTERVAL_SECONDS));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity != null)
        {
            var intervalTimer = GetIntervalTimer(buff);
            if (intervalTimer.RunToExpiredAndNotNull())
            {
                var damageEffects = new DamageEffectList([VanillaDamageEffects.FIRE, VanillaDamageEffects.IGNORE_ARMOR]);
                entity.TakeDamage(GetFireDamage(buff), damageEffects, entity);
                entity.Spawn(VanillaEffectID.fireburn, entity.GetCenter());
                intervalTimer.Reset();
            }

            if (VanillaEntityExt.IsInWater(entity))
            {
                LogicEntityExt.PlaySound(entity, VanillaSoundID.fizz);
                buff.Remove();
            }
        }
        var timer = GetTimer(buff);
        if (timer.RunToExpiredOrNull())
        {
            buff.Remove();
        }
    }
    public static function MaxTime(buff:Buff, frames:Int):Void
    {
        var timer = GetTimer(buff);
        if (timer == null || timer.Frame >= frames)
            return;
        timer.ResetTime(frames);
    }
    public static function MaxDamage(buff:Buff, value:Float):Void
    {
        var damage = GetFireDamage(buff);
        if (damage >= value)
            return;
        SetFireDamage(buff, value);
    }
    public static function GetFireDamage(buff:Buff):Float return buff.GetProperty(PROP_FIRE_DAMAGE);
    public static function SetFireDamage(buff:Buff, value:Float):Void buff.SetProperty(PROP_FIRE_DAMAGE, value);
    public static function GetIntervalTimer(buff:Buff):Null<FrameTimer> return buff.GetProperty(PROP_INTERVAL_TIMER);
    public static function SetIntervalTimer(buff:Buff, value:Null<FrameTimer>):Void buff.SetProperty(PROP_INTERVAL_TIMER, value);
    public static function GetTimer(buff:Buff):Null<FrameTimer> return buff.GetProperty(PROP_TIMER);
    public static function SetTimer(buff:Buff, value:Null<FrameTimer>):Void buff.SetProperty(PROP_TIMER, value);
    public static inline var DAMAGE_INTERVAL_SECONDS:Float = 1;
    public static inline var SECONDS:Float = 0;
    public static var PROP_INTERVAL_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("interval_timer");
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
    public static var PROP_FIRE_DAMAGE:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("fire_damage", 20);
}
