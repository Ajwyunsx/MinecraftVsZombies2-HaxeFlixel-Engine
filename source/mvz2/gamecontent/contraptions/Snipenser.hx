// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Tokens/Snipenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.Global;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.FrameTimer;
import tools.Ticks;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using tools.VectorExt;
import tools.Ref;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.snipenser)
class Snipenser extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.ATTACK_SPEED, NumberOperator.AddMultiple, PROP_ATTACK_SPEED_ADDITION));
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var shootTimer = new FrameTimer(10);
        SetShootTimer(entity, shootTimer);
    }

    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);

        // PORT-NOTE: C# 的 out 参数在 Haxe 侧用 tools.Ref<T> 表达（IGlobalInput.TryGetPointerScreenPosition）。
        var screenPositionRef = new Ref<Vector2>(Vector2.zero);
        if (Global.Input.TryGetPointerScreenPosition(screenPositionRef))
        {
            var screenPosition = screenPositionRef.value;
            var levelPosition = entity.Level.ScreenToLawnPositionByY(screenPosition, entity.Position.y);
            var distanceVector = new Vector2(levelPosition.x - entity.Position.x, levelPosition.z - entity.Position.z);
            var angle = Mathf.Repeat(Vector2.SignedAngle(distanceVector, Vector2.right), 360);
            SetDirection(entity, angle);
        }


        var shootTimer = GetShootTimer(entity);
        if (shootTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
        {
            if (Global.Input.IsPointerHolding(PointerTypes.MOUSE, 0) || Global.Input.IsPointerHolding(PointerTypes.TOUCH, 0))
            {
                Shoot(entity);
                shootTimer.Reset();
            }
        }


        var headOffset = GetHeadOffset(entity);
        // PORT-NOTE: tools.Ticks 只有 Float / Vector3 两个 SmoothDamp 重载（C# 另有 Vector2 版本），这里用等价的 Vector3 版本计算再取回 x/y。
        var smoothedOffset = Ticks.SmoothDampVector(new Vector3(headOffset.x, headOffset.y, 0), new Vector3(0, 0, 0), 0.5);
        headOffset = new Vector2(smoothedOffset.x, smoothedOffset.y);
        SetHeadOffset(entity, headOffset);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var headSpritePercentage = 0.0;
        var headOffset = GetHeadOffset(entity);
        var direction = GetDirection(entity);
        var spriteDirection = direction;
        if (entity.IsFacingLeft())
        {
            spriteDirection = 180 - direction - SPRITE_ANGLE_OFFSET;
        }
        else
        {
            spriteDirection = direction - SPRITE_ANGLE_OFFSET;
        }
        headSpritePercentage = Mathf.Repeat(spriteDirection, 360) / 360;
        entity.SetAnimationFloat("HeadOffsetX", headOffset.x);
        entity.SetAnimationFloat("HeadOffsetY", headOffset.y);
        entity.SetAnimationFloat("HeadSprite", headSpritePercentage);

        entity.SetProperty(PROP_ATTACK_SPEED_ADDITION, GetRapidLevel(entity) * ATTACK_SPEED_PER_RAPID_LEVEL);
    }
    public function Shoot(entity:Entity):Void
    {
        var direction = GetDirection(entity);
        var directionVector2 = Vector2.right.RotateClockwise(direction);
        var headOffset = -directionVector2;
        SetHeadOffset(entity, headOffset);

        var shotOffset = entity.GetShotOffset();
        var shotOffset2D = new Vector2(shotOffset.x, shotOffset.z);
        shotOffset2D = shotOffset2D.RotateClockwise(direction);
        shotOffset = new Vector3(shotOffset2D.x, shotOffset.y, shotOffset2D.y);
        var position = entity.Position + shotOffset;

        var velocity = entity.GetShotVelocity();
        var speed = velocity.magnitude;

        var spawnParam = entity.GetSpawnParams();
        spawnParam.SetProperty(EngineEntityProps.SIZE, Vector3.one * 32);

        var spreadCount = GetSpreadLevel(entity) + 1;
        var startAngleOffset = -ANGLE_PER_SPREAD * ((spreadCount - 1) / 2);
        for (i in 0...spreadCount)
        {
            var angleOffset = i * ANGLE_PER_SPREAD + startAngleOffset;
            var velDirection = directionVector2.RotateClockwise(angleOffset);
            var vel = speed * new Vector3(velDirection.x, 0, velDirection.y);

            var param = entity.GetShootParams();
            param.position = position;
            param.velocity = vel;
            param.spawnParam = spawnParam;
            entity.ShootProjectile(param);
        }
    }
    public static function CanUpgradeRapid(entity:Entity):Bool
    {
        return GetRapidLevel(entity) < MAX_RAPID_LEVEL;
    }
    public static function UpgradeRapid(entity:Entity):Void
    {
        SetRapidLevel(entity, GetRapidLevel(entity) + 1);
    }
    public static function CanUpgradeSpread(entity:Entity):Bool
    {
        return GetSpreadLevel(entity) < MAX_SPREAD_LEVEL;
    }
    public static function UpgradeSpread(entity:Entity):Void
    {
        SetSpreadLevel(entity, GetSpreadLevel(entity) + 1);
    }
    public static function GetShootTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_SHOOT_TIMER);
    public static function SetShootTimer(entity:Entity, value:FrameTimer):Void entity.SetBehaviourField(PROP_SHOOT_TIMER, value);
    public static function GetDirection(entity:Entity):Float return entity.GetBehaviourField(PROP_DIRECTION);
    public static function SetDirection(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_DIRECTION, value);
    public static function GetRapidLevel(entity:Entity):Int return entity.GetBehaviourField(PROP_RAPID_LEVEL);
    public static function SetRapidLevel(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_RAPID_LEVEL, value);
    public static function GetSpreadLevel(entity:Entity):Int return entity.GetBehaviourField(PROP_SPREAD_LEVEL);
    public static function SetSpreadLevel(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_SPREAD_LEVEL, value);
    public static function GetHeadOffset(entity:Entity):Vector2 return entity.GetBehaviourField(PROP_HEAD_OFFSET);
    public static function SetHeadOffset(entity:Entity, value:Vector2):Void entity.SetBehaviourField(PROP_HEAD_OFFSET, value);
    public static inline var FRAME_COUNT:Float = 24;
    public static inline var SPRITE_ANGLE_OFFSET:Float = 360 / FRAME_COUNT / 2;
    public static inline var ATTACK_SPEED_PER_RAPID_LEVEL:Float = 0.25;
    public static inline var ANGLE_PER_SPREAD:Float = 5;
    public static inline var MAX_RAPID_LEVEL:Int = 4;
    public static inline var MAX_SPREAD_LEVEL:Int = 4;
    public static var PROP_SHOOT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("shoot_timer");
    public static var PROP_DIRECTION:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("direction");
    public static var PROP_RAPID_LEVEL:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("rapid_level");
    public static var PROP_ATTACK_SPEED_ADDITION:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("attack_speed_addition");
    public static var PROP_SPREAD_LEVEL:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("spread_level");
    public static var PROP_HEAD_OFFSET:VanillaEntityPropertyMeta<Vector2> = new VanillaEntityPropertyMeta<Vector2>("head_offset");
}
