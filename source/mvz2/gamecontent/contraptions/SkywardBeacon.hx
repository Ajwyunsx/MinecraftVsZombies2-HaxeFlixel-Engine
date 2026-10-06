// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/SkywardBeacon.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.detections.SkywardBeaconDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EntityID;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import tools.FrameTimer;
import tools.TimerHelper;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.skywardBeacon)
class SkywardBeacon extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new SkywardBeaconDetector();
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetShootTimer(entity, TimerHelper.NewSecondTimer(ATTACK_INTERVAL_SECONDS));
        UpdateModel(entity);
    }

    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        var shootTimer = GetShootTimer(entity);
        if (shootTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
        {
            if (detector.DetectExists(DetectionParams.fromEntity(entity)))
            {
                OnShootTick(entity);
            }
            shootTimer.Reset();
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        UpdateModel(entity);

        var level = entity.Level;
        var strikeGrid = GetStrikeGrid(entity);
        var targetID = GetTargetEntity(entity);
        if (strikeGrid != null)
        {
            var target = targetID != null ? targetID.GetEntity(level) : null;
            var position = strikeGrid.GetEntityPosition();
            if (!target.ExistsAndAlive())
            {
                var param = entity.GetSpawnParams();
                param.EntityParent = entity;
                target = entity.Spawn(VanillaEffectID.skywardBeaconTarget, position, param);
                SetTargetEntity(entity, new EntityID(target));
            }
            else
            {
                target.Position = position;
            }
        }
        else
        {
            if (targetID != null)
            {
                var target = targetID.GetEntity(level);
                if (target.ExistsAndAlive())
                {
                    target.Remove();
                }
                SetTargetEntity(entity, null);
            }
        }
    }
    function UpdateModel(entity:Entity):Void
    {
        var night = !entity.Level.IsDay();
        entity.SetModelProperty("Night", night);

        var buffID = VanillaBuffID.Contraption.skywardBeaconNight;
        if (night)
        {
            if (!entity.HasBuff(buffID))
            {
                entity.AddBuff(buffID);
            }
        }
        else
        {
            if (entity.HasBuff(buffID))
            {
                entity.RemoveBuffs(buffID);
            }
        }
    }
    public function OnShootTick(entity:Entity):Void
    {
        var position = GetStrikePosition(entity);
        var param = entity.GetSpawnParams();
        param.SetProperty(VanillaEntityProps.DAMAGE, entity.GetDamage());
        entity.Spawn(VanillaEffectID.skywardBeam, position, param);
        entity.TriggerAnimation("Shoot");
    }
    public static function GetStrikeGrid(entity:Entity):Null<LawnGrid>
    {
        var targetColumn = GetTargetColumn(entity);
        var targetLane = GetTargetLane(entity);
        return entity.Level.GetGrid(targetColumn, targetLane);
    }
    public static function GetStrikePosition(entity:Entity):Vector3
    {
        var targetColumn = GetTargetColumn(entity);
        var targetLane = GetTargetLane(entity);
        var grid = entity.Level.GetGrid(targetColumn, targetLane);
        if (grid == null)
        {
            var position = entity.Position;
            position.y = entity.GetGroundY();
            return position;
        }
        else
        {
            return entity.Level.GetEntityGridPosition(targetColumn, targetLane);
        }
    }
    public static function GetShootTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_SHOOT_TIMER);
    public static function SetShootTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_SHOOT_TIMER, timer);
    public static function GetTargetEntity(entity:Entity):Null<EntityID> return entity.GetBehaviourField(PROP_TARGET_ENTITY);
    public static function SetTargetEntity(entity:Entity, value:Null<EntityID>):Void entity.SetBehaviourField(PROP_TARGET_ENTITY, value);
    public static function GetTargetColumn(entity:Entity):Int return entity.GetBehaviourField(PROP_TARGET_COLUMN);
    public static function SetTargetColumn(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_TARGET_COLUMN, value);
    public static function GetTargetLane(entity:Entity):Int return entity.GetBehaviourField(PROP_TARGET_LANE);
    public static function SetTargetLane(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_TARGET_LANE, value);

    var detector:Detector;
    static inline var ATTACK_INTERVAL_SECONDS:Float = 3;

    public static var PROP_SHOOT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("shoot_timer");
    public static var PROP_TARGET_ENTITY:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("target_entity");
    public static var PROP_TARGET_COLUMN:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("target_column", -1);
    public static var PROP_TARGET_LANE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("target_lane", -1);
}
