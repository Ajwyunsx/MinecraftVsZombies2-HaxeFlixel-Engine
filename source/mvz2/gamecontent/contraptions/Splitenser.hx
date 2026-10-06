// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter4/Splitenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.DispenserDetector;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
import mvz2.gamecontent.contraptions.DispenserFamily;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.splitenser)
class Splitenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        // PORT-NOTE: C# 用对象初始化器（new DispenserDetector() { ignoreHighEnemy = true, reversed = true }）
        // 给 DispenserDetector 的专属字段赋值；detectorBack 声明为基类 Detector，故先取具体类型再赋值。
        var back = new DispenserDetector();
        back.ignoreHighEnemy = true;
        back.reversed = true;
        detectorBack = back;
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
        SetEvocationTimer(entity, new FrameTimer(120));
        SetRepeatTimer(entity, new FrameTimer(REPEAT_INTERVAL));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            ShootTickSplit(entity);
            var repeatCount = GetRepeatCount(entity);
            if (repeatCount > 0)
            {
                var repeatTimer = GetRepeatTimer(entity);
                if (repeatTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
                {
                    ShootBack(entity);
                    SetRepeatCount(entity, repeatCount - 1);
                    repeatTimer.Reset();
                }
            }
            return;
        }

        EvokedUpdate(entity);
    }
    public function ShootTickSplit(entity:Entity):Void
    {
        var shootTimer = DispenserFamily.GetShootTimer(entity);
        if (shootTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
        {
            var frontTarget = detector.Detect(DetectionParams.fromEntity(entity));
            if (frontTarget != null)
            {
                ShootFront(entity);
            }
            var backTarget = detectorBack.Detect(DetectionParams.fromEntity(entity));
            if (backTarget != null)
            {
                RepeatShootBack(entity);
            }
            shootTimer.ResetTime(GetTimerTime(entity));
        }
    }
    public function ShootFront(entity:Entity):Null<Entity>
    {
        entity.TriggerAnimation("ShootFront");
        return entity.ShootProjectile();
    }
    public function ShootBack(entity:Entity):Null<Entity>
    {
        entity.TriggerAnimation("ShootBack");

        var param = entity.GetShootParams();

        var offset = entity.GetShotOffset();
        offset.x *= -1;
        offset = entity.ModifyShotOffset(offset);
        param.position = entity.Position + offset;

        var vel = param.velocity;
        vel.x *= -1;
        param.velocity = vel;

        return entity.ShootProjectile(param);
    }
    public function ShootLargeArrowBack(entity:Entity):Null<Entity>
    {
        entity.TriggerAnimation("ShootBack");

        var param = entity.GetShootParams();

        var offset = entity.GetShotOffset();
        offset.x *= -1;
        offset = entity.ModifyShotOffset(offset);
        param.position = entity.Position + offset;

        var vel = param.velocity;
        vel.x *= -1;
        param.velocity = vel.normalized;

        param.projectileID = VanillaProjectileID.largeArrow;
        param.damage = entity.GetDamage() * 30;
        param.soundID = VanillaSoundID.spellCard;

        return entity.ShootProjectile(param);
    }
    public function RepeatShootBack(entity:Entity):Void
    {
        SetRepeatCount(entity, 2);
        var repeatTimer = GetRepeatTimer(entity);
        if (repeatTimer != null)
        {
            repeatTimer.ResetTime(REPEAT_INTERVAL);
            repeatTimer.Frame = 0;
        }
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer != null)
        {
            evocationTimer.Reset();
        }
        entity.SetEvoked(true);
    }
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_EVOCATION_TIMER, timer);
    public static function GetRepeatTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_REPEAT_TIMER);
    public static function SetRepeatTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_REPEAT_TIMER, timer);
    public static function GetRepeatCount(entity:Entity):Int return entity.GetBehaviourField(PROP_REPEAT_COUNT);
    public static function SetRepeatCount(entity:Entity, timer:Int):Void entity.SetBehaviourField(PROP_REPEAT_COUNT, timer);
    function EvokedUpdate(entity:Entity):Void
    {
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer == null)
            return;
        evocationTimer.Run();
        if (evocationTimer.PassedInterval(2))
        {
            var frontProjectile = ShootFront(entity);
            if (frontProjectile != null)
                frontProjectile.Velocity *= 2;

            var backProjectile = ShootBack(entity);
            if (backProjectile != null)
                backProjectile.Velocity *= 2;
        }
        if (evocationTimer.Expired)
        {
            ShootLargeArrowBack(entity);
            entity.SetEvoked(false);
            var shootTimer = DispenserFamily.GetShootTimer(entity);
            if (shootTimer != null)
                shootTimer.Reset();
        }
    }
    var detectorBack:Detector;
    public static inline var REPEAT_INTERVAL:Int = 5;
    public static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
    public static var PROP_REPEAT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("RepeatTimer");
    public static var PROP_REPEAT_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("RepeatCount");
}
