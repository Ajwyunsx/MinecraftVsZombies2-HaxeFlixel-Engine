// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/Pistenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.DispenserDetector;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionProps;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.EntityID;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.pistenser)
class Pistenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(VanillaEntityProps.SHOT_OFFSET, NumberOperator.Add, PROP_EXTEND_SHOOT_OFFSET));
        AddModifier(new Vector3Modifier(EngineEntityProps.SIZE, NumberOperator.Add, PROP_EXTEND_SHOOT_OFFSET));
        AddModifier(new BooleanModifier(VanillaContraptionProps.BLOCKS_JUMP, PROP_BLOCKS_JUMP));
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
        SetEvocationTimer(entity, new FrameTimer(EVOCATION_TIME));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            ExtendUpdate(entity);
            ShootTick(entity);
        }
        else
        {
            EvokedUpdate(entity);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var extend = GetExtend(entity);
        entity.SetAnimationFloat("Extend", extend);
        entity.SetProperty(PROP_EXTEND_SHOOT_OFFSET, Vector3.up * extend);
        entity.SetProperty(PROP_BLOCKS_JUMP, extend > 0);
    }

    override function GetDetector():Detector
    {
        return new DispenserDetector();
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        entity.State = STATE_SEED;
        var evocationTimer = GetEvocationTimer(entity);
        evocationTimer.Reset();
        entity.PlaySound(VanillaSoundID.pistonIn);
        entity.SetAnimationBool("HatchOn", true);
    }
    function ExtendUpdate(pistenser:Entity):Void
    {
        // 检查目标。
        if (pistenser.IsTimeInterval(DETECT_INTERVAL))
        {
            var collider = detector.DetectWithTheMost(DetectionParams.fromEntity(pistenser), e -> e.Entity.GetRelativeY());
            SetExtendTarget(pistenser, collider != null ? collider.Entity : null);
        }

        var target = GetExtendTarget(pistenser);
        // 存在目标，并且目标的最底部大于活塞发射器的基础子弹高度，则延长。
        if (target != null && target.Position.y > pistenser.Position.y + BASE_SHOT_HEIGHT)
        {
            // 目标延长高度为目标的中心点减去活塞发射器的基础子弹高度。
            var targetExtend = target.GetCenter().y - (pistenser.Position.y + BASE_SHOT_HEIGHT);
            var extend = GetExtend(pistenser);

            // 目标延长高度和当前高度的差值必须大于或等于10。
            if (Mathf.Abs(targetExtend - extend) >= 10)
            {
                ExtendToTargetHeight(pistenser, targetExtend);
            }
        }
        else
        {
            // 没有目标，或者目标不高，收回
            ExtendToTargetHeight(pistenser, 0);
        }
    }

    function ExtendToTargetHeight(pistenser:Entity, targetHeight:Float):Void
    {
        // 切换伸缩方向并播放音效。
        var direction = GetExtendDirection(pistenser);
        var height = GetExtend(pistenser);
        if (targetHeight > height)
        {
            if (direction != 1)
            {
                pistenser.PlaySound(VanillaSoundID.pistonOut);
                direction = 1;
            }
        }
        else if (targetHeight < height)
        {
            if (direction != -1)
            {
                pistenser.PlaySound(VanillaSoundID.pistonIn);
                direction = -1;
            }
        }
        else
        {
            direction = 0;
        }
        SetExtendDirection(pistenser, direction);

        // 伸缩。
        // 如果这次伸缩越过了目标高度，直接把高度修改为目标高度。
        var nextHeight = height + EXTEND_SPEED * direction;
        if ((targetHeight - nextHeight) * direction < 0)
        {
            height = targetHeight;
        }
        else
        {
            height = nextHeight;
        }

        height = Mathf.Max(0, height);
        SetExtend(pistenser, height);
    }

    function EvokedUpdate(entity:Entity):Void
    {
        var evocationTimer = GetEvocationTimer(entity);
        evocationTimer.Run();
        if (entity.State == STATE_SEED)
        {
            if (evocationTimer.Frame <= 15)
            {
                SeedSpikeBalls(entity);
                entity.State = STATE_IDLE;
            }
        }
        else
        {
            if (evocationTimer.Expired)
            {
                entity.SetAnimationBool("HatchOn", false);
                entity.SetEvoked(false);
                entity.PlaySound(VanillaSoundID.pistonOut);
            }
        }
    }

    function SeedSpikeBalls(entity:Entity):Void
    {
        var soundPlayed = false;
        var extend = GetExtend(entity);
        var spikeBallPos = entity.Position + (extend + 54) * Vector3.up;

        var projectileID = VanillaProjectileID.spikeBall;
        var projectileDefinition = entity.Level.Content.GetEntityDefinition(projectileID);
        var projectileGravity = projectileDefinition != null ? projectileDefinition.GetGravity() : 0;
        // C#: entity.Level.FindEntities(...).OrderByDescending(e => e.GetRelativeY()).Take(MAX_EVOCATION_TARGET)
        // PORT-NOTE: LINQ 的 OrderByDescending/Take 改为 Array.sort + slice。
        var targets = entity.Level.FindEntities(e -> IsEvocationTarget(entity, e));
        targets.sort((a, b) -> Reflect.compare(b.GetRelativeY(), a.GetRelativeY()));
        for (target in targets.slice(0, MAX_EVOCATION_TARGET))
        {
            if (!soundPlayed)
            {
                entity.PlaySound(VanillaSoundID.smallExplosion);
                soundPlayed = true;
            }

            var targetPos = target.Position;
            targetPos.y = target.GetGroundY();

            var shotParams = entity.GetShootParams();
            shotParams.position = spikeBallPos;
            shotParams.soundID = null;
            shotParams.projectileID = projectileID;
            shotParams.velocity = VanillaProjectileExt.GetLobVelocityByTime(spikeBallPos, targetPos, 24, projectileGravity);
            shotParams.damage = entity.GetDamage() * 9;
            entity.ShootProjectile(shotParams);
        }
    }
    static function IsEvocationTarget(self:Entity, target:Entity):Bool
    {
        if (target == null)
            return false;
        if (target.IsDead)
            return false;
        if (!target.IsVulnerableEntity())
            return false;
        if (!self.IsHostile(target))
            return false;
        if (!Detection.CanDetect(target))
            return false;
        return true;
    }
    public static function GetExtendTarget(entity:Entity):Null<Entity>
    {
        var id = entity.GetBehaviourField(PROP_EXTEND_TARGET);
        if (id == null)
            return null;
        return id.GetEntity(entity.Level);
    }
    public static function SetExtendTarget(entity:Entity, value:Null<Entity>):Void
    {
        entity.SetBehaviourField(PROP_EXTEND_TARGET, value != null ? new EntityID(value) : null);
    }
    public static function GetEvocationTimer(entity:Entity):FrameTimer return entity.GetOrCreateTimerProperty(PROP_EVOCATION_TIMER, EVOCATION_TIME);
    public static function SetEvocationTimer(entity:Entity, value:FrameTimer):Void entity.SetBehaviourField(PROP_EVOCATION_TIMER, value);
    public static function GetExtend(entity:Entity):Float return entity.GetBehaviourField(PROP_EXTEND);
    public static function SetExtend(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_EXTEND, value);
    public static function GetExtendDirection(entity:Entity):Int return entity.GetBehaviourField(PROP_EXTEND_DIRECTION);
    public static function SetExtendDirection(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_EXTEND_DIRECTION, value);
    public static var PROP_EXTEND:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("Extend");
    public static var PROP_EXTEND_SHOOT_OFFSET:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("ExtendShootOffset");
    public static var PROP_BLOCKS_JUMP:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("BlocksJump");
    public static var PROP_EXTEND_DIRECTION:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("ExtendDirection");
    public static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
    public static var PROP_EXTEND_TARGET:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("ExtendTarget");
    public static inline var STATE_IDLE:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_SEED:Int = VanillaContraptionStates.PISTENSER_SEED;
    public static inline var BASE_SHOT_HEIGHT:Float = 30;
    public static inline var EXTEND_SPEED:Float = 10;
    public static inline var EVOCATION_TIME:Int = 30;
    public static inline var DETECT_INTERVAL:Int = 8;
    public static inline var MAX_EVOCATION_TARGET:Int = 10;
}
