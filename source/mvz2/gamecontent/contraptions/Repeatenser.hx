// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/Repeatenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.repeatenser)
class Repeatenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
        SetEvocationTimer(entity, new FrameTimer(120));
        SetRepeatTimer(entity, new FrameTimer(15));
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
    public override function OnShootTick(entity:Entity):Void
    {
        var count = REPEAT_COUNT;
        SetRepeatCount(entity, count);
        var repeatTimer = GetRepeatTimer(entity);
        if (repeatTimer != null)
        {
            repeatTimer.ResetTime(Mathf.FloorToInt(15 / count));
            repeatTimer.Frame = 0;
        }
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer != null)
            evocationTimer.Reset();
        entity.SetEvoked(true);
    }
    function EvokedUpdate(entity:Entity):Void
    {
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer == null)
            return;
        evocationTimer.Run();
        if (evocationTimer.PassedInterval(2))
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

        return entity != null ? entity.ShootProjectile(param) : null;
    }
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_EVOCATION_TIMER, timer);
    public static function GetRepeatTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_REPEAT_TIMER);
    public static function SetRepeatTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_REPEAT_TIMER, timer);

    public static function GetRepeatCount(entity:Entity):Int return entity.GetBehaviourField(PROP_REPEAT_COUNT);
    public static function SetRepeatCount(entity:Entity, count:Int):Void entity.SetBehaviourField(PROP_REPEAT_COUNT, count);

    public static inline var REPEAT_COUNT:Int = 2;
    public static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
    public static var PROP_REPEAT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("RepeatTimer");
    public static var PROP_REPEAT_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("RepeatCount");
}
