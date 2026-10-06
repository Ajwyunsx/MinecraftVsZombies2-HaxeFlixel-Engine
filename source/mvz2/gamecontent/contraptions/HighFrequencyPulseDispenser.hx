// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/HighFrequencyPulseDispenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.HFPDUpgradedBuff;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.hfpd)
class HighFrequencyPulseDispenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
        SetEvocationTimer(entity, new FrameTimer(EVOCATION_TIME));
        SetRepeatTimer(entity, new FrameTimer(REPEAT_INVERVAL));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            ShootTick(entity);
            var repeatCount = GetRepeatCount(entity);
            if (repeatCount > 0)
            {
                var repeatTimer = GetRepeatTimer(entity);
                if (repeatTimer != null && repeatTimer.RunToExpired(entity.GetAttackSpeed()))
                {
                    Shoot(entity);
                    SetRepeatCount(entity, repeatCount - 1);
                    repeatTimer.Reset();
                }
            }
        }
        else
        {
            EvokedUpdate(entity);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetModelProperty("Upgraded", IsUpgraded(entity));
        entity.SetModelProperty("GatlinAlt", IsGatlinAlt(entity));
    }
    public override function OnShootTick(entity:Entity):Void
    {
        var count = IsUpgraded(entity) ? REPEAT_COUNT_UPGRADED : REPEAT_COUNT;
        SetRepeatCount(entity, count);
        var repeatTimer = GetRepeatTimer(entity);
        if (repeatTimer != null)
        {
            repeatTimer.ResetTime(Mathf.FloorToInt(15 / count));
            repeatTimer.Frame = 0;
        }
    }
    public override function Shoot(entity:Entity):Null<Entity>
    {
        SetGatlinAlt(entity, !IsGatlinAlt(entity));
        return super.Shoot(entity);
    }

    public override function CanEvoke(entity:Entity):Bool
    {
        if (IsUpgraded(entity))
            return false;
        return super.CanEvoke(entity);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.AddBuff(HFPDUpgradedBuff);
        //var evocationTimer = GetEvocationTimer(entity);
        //evocationTimer.Reset();
        //entity.SetEvoked(true);
        entity.PlaySound(VanillaSoundID.gunReload);
        entity.PlaySound(VanillaSoundID.powerUp);
        entity.PlaySound(VanillaSoundID.motor);
    }
    function EvokedUpdate(entity:Entity):Void
    {
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer == null)
            return;
        evocationTimer.Run();
        if (evocationTimer.PassedInterval(15))
        {
            var projectile = Shoot(entity);
            if (projectile != null)
                projectile.Velocity *= 2;
        }
        if (evocationTimer.Expired)
        {
            ShootLargeArrow(entity);
            entity.SetEvoked(false);
            var shootTimer = DispenserFamily.GetShootTimer(entity);
            if (shootTimer != null)
                shootTimer.Reset();
        }
    }
    function ShootLargeArrow(entity:Entity):Null<Entity>
    {
        entity.TriggerAnimation("Shoot");

        var param = entity.GetShootParams();

        var offset = entity.GetShotOffset();
        offset = entity.ModifyShotOffset(offset);
        param.position = entity.Position + offset;
        param.velocity = param.velocity.normalized;

        param.projectileID = VanillaProjectileID.largeArrow;
        param.damage = entity.GetDamage() * 30;
        param.soundID = VanillaSoundID.spellCard;

        return entity.ShootProjectile(param);
    }
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_EVOCATION_TIMER, timer);
    public static function GetRepeatTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_REPEAT_TIMER);
    public static function SetRepeatTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_REPEAT_TIMER, timer);

    public static function IsGatlinAlt(entity:Entity):Bool return entity.GetBehaviourField(PROP_GATLIN_ALT);
    public static function SetGatlinAlt(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_GATLIN_ALT, value);
    public static function IsUpgraded(entity:Entity):Bool return entity.HasBuff(HFPDUpgradedBuff);
    public static function GetRepeatCount(entity:Entity):Int return entity.GetBehaviourField(PROP_REPEAT_COUNT);
    public static function SetRepeatCount(entity:Entity, count:Int):Void entity.SetBehaviourField(PROP_REPEAT_COUNT, count);

    public static inline var REPEAT_INVERVAL:Int = 7;
    public static inline var EVOCATION_TIME:Int = 60;
    public static inline var REPEAT_COUNT:Int = 4;
    public static inline var REPEAT_COUNT_UPGRADED:Int = 6;
    public static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
    public static var PROP_REPEAT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("RepeatTimer");
    public static var PROP_REPEAT_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("RepeatCount");
    public static var PROP_GATLIN_ALT:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("gatlin_alt");
}
