// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/SkeletonHorse.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.detections.SkeletonHorseBlocksJumpDetector;
import mvz2.gamecontent.detections.SkeletonHorseJumpDetector;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.FrameTimer;
import unity.Vector3;
using mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
using mvz2.vanilla.enemies.VanillaEnemyExt;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.skeletonHorse)
class SkeletonHorse extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new SkeletonHorseJumpDetector();
        blocksJumpDetector = new SkeletonHorseBlocksJumpDetector();
        AddModifier(new FloatModifier(VanillaEnemyProps.SPEED, NumberOperator.Multiply, PROP_SPEED_MULTIPLIER));
    }

    //region 回调
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetLandTimer(entity, new FrameTimer(15));
        var jumpTimes = entity.Level.GetSkeletonHorseJumpTimes();
        SetGallopTime(entity, jumpTimes);
    }
    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        if (entity.State == STATE_JUMP)
        {
            var stateTimer = GetLandTimer(entity);
            if (stateTimer != null)
                stateTimer.Reset();
            SetJumpState(entity, JUMP_STATE_LAND);
            entity.PlaySound(VanillaSoundID.horseGallop);
        }
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        entity.SetProperty(PROP_SPEED_MULTIPLIER, entity.State == STATE_GALLOP ? 2 : 1);

        switch (entity.State)
        {
            case STATE_GALLOP:
                UpdateStateGallop(entity);
            case STATE_JUMP:
                UpdateStateJump(entity);
            case STATE_LAND:
                UpdateStateLand(entity);
        }
    }
    function UpdateStateGallop(entity:Entity):Void
    {
        if (detector.DetectExists(DetectionParams.fromEntity(entity)))
        {
            AddGallopTime(entity, -1);
            var vel = entity.Velocity;
            vel.x = entity.GetFacingX() * 5;
            vel.y = 12;
            entity.Velocity = vel;
            SetJumpState(entity, JUMP_STATE_JUMP);
            entity.PlaySound(VanillaSoundID.horseGallop);
        }

        entity.UpdateWalkVelocity();

        var soundTimer = GetGallopSoundTimer(entity);
        if (soundTimer == null)
        {
            soundTimer = new FrameTimer(GALLOP_SOUND_INTERVAL);
            SetGallopSoundTimer(entity, soundTimer);
        }
        if (soundTimer.RunToExpired(entity.GetSpeed() * 0.5))
        {
            soundTimer.Reset();
            entity.PlaySound(VanillaSoundID.horseGallop);
        }
    }
    function UpdateStateJump(entity:Entity):Void
    {
        if (blocksJumpDetector.DetectExists(DetectionParams.fromEntity(entity)))
        {
            var vel = entity.Velocity;
            vel.x = 0;
            vel.y = 0;
            entity.Velocity = vel;
            SetJumpState(entity, JUMP_STATE_NONE);
            entity.Stun(30);
            entity.PlaySound(VanillaSoundID.bonk);
        }
    }
    function UpdateStateLand(entity:Entity):Void
    {
        var stateTimer = GetLandTimer(entity);
        if (stateTimer.RunToExpiredAndNotNull())
        {
            stateTimer.Reset();
            SetJumpState(entity, JUMP_STATE_NONE);
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        var stateTimer = GetLandTimer(entity);
        if (stateTimer != null)
            stateTimer.Reset();
        SetJumpState(entity, JUMP_STATE_NONE);
    }
    //endregion

    //region 字段
    public static function GetJumpState(entity:Entity):Int return entity.GetBehaviourField(FIELD_JUMP_STATE);
    public static function SetJumpState(entity:Entity, value:Int):Void entity.SetBehaviourField(FIELD_JUMP_STATE, value);

    public static function GetLandTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(FIELD_LAND_TIMER);
    public static function SetLandTimer(entity:Entity, value:FrameTimer):Void entity.SetBehaviourField(FIELD_LAND_TIMER, value);

    public static function GetGallopTime(entity:Entity):Int return entity.GetBehaviourField(FIELD_GALLOP_TIME);
    public static function SetGallopTime(entity:Entity, value:Int):Void entity.SetBehaviourField(FIELD_GALLOP_TIME, value);
    public static function AddGallopTime(entity:Entity, value:Int):Void SetGallopTime(entity, GetGallopTime(entity) + value);

    public static function GetGallopSoundTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(FIELD_GALLOP_SOUND_TIMER);
    public static function SetGallopSoundTimer(entity:Entity, value:Null<FrameTimer>):Void entity.SetBehaviourField(FIELD_GALLOP_SOUND_TIMER, value);
    //endregion

    public static var FIELD_GALLOP_TIME:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("GallopTime");
    public static var FIELD_GALLOP_SOUND_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("GallopSoundTimer");
    public static var FIELD_JUMP_STATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("JumpState");
    public static var FIELD_LAND_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("LandTimer");
    public static var PROP_SPEED_MULTIPLIER:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("SpeedMultiplier");
    public static inline var GALLOP_SOUND_INTERVAL:Int = 15;
    public static inline var JUMP_STATE_NONE:Int = 0;
    public static inline var JUMP_STATE_JUMP:Int = 1;
    public static inline var JUMP_STATE_LAND:Int = 2;
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_MELEE_ATTACK:Int = LogicEnemyStates.MELEE_ATTACK;
    public static inline var STATE_GALLOP:Int = VanillaEnemyStates.SKELETON_HORSE_GALLOP;
    public static inline var STATE_JUMP:Int = VanillaEnemyStates.SKELETON_HORSE_JUMP;
    public static inline var STATE_LAND:Int = VanillaEnemyStates.SKELETON_HORSE_LAND;
    var detector:Detector;
    var blocksJumpDetector:Detector;
}
