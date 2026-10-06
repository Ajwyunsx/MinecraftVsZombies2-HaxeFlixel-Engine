// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter4/Devourer.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.bosses.TheGiant;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.contraptions.DevourerInvincibleBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.DevourerEvokedDetector;
import mvz2.gamecontent.obstacles.VanillaObstacleID;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.grids.VanillaGridLayers;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.contraptions.VanillaContraptionProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.devourer)
class Devourer extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        evokedDetector = new DevourerEvokedDetector();
    }
    public override function Init(devourer:Entity):Void
    {
        super.Init(devourer);
        SetDevourTimer(devourer, new FrameTimer(DEVOUR_TIME));
        devourer.Level.AddLoopSoundEntity(VanillaSoundID.metalSaw, devourer.ID);
        devourer.Target = GetMillTarget(devourer);
        if (!devourer.Target.ExistsAndAlive())
        {
            devourer.Die(new DamageEffectList([VanillaDamageEffects.SELF_DAMAGE]), devourer);
            return;
        }
        UpdateDevourerPosition(devourer);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        entity.AddBuff(DevourerInvincibleBuff);
        entity.PlaySound(VanillaSoundID.pacmanStart);
        entity.Level.RemoveLoopSoundEntity(VanillaSoundID.metalSaw, entity.ID);
        entity.Level.AddLoopSoundEntity(VanillaSoundID.pacmanGhost, entity.ID);
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;

        var devourer = collision.Entity;
        if (!IsPacmanGhost(devourer))
            return;
        var other = collision.Other;
        if (!devourer.IsHostile(other))
            return;
        var level = devourer.Level;
        var output = other.TakeDamage(devourer.GetDamage() * EVOKED_DAMAGE_MULTIPLIER, new DamageEffectList([VanillaDamageEffects.MUTE, VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.REMOVE_ON_DEATH, VanillaDamageEffects.NO_DEATH_EFFECTS]), devourer);
        if (output != null)
        {
            if (output.HasAnyFatal())
            {
                level.PlaySound(VanillaSoundID.pacmanKill);
            }
            if (!level.IsPlayingSound(VanillaSoundID.pacmanAttack))
            {
                level.PlaySound(VanillaSoundID.pacmanAttack);
            }
        }
    }
    //region 更新
    override function UpdateLogic(devourer:Entity):Void
    {
        super.UpdateLogic(devourer);
        if (devourer.IsEvoked())
        {
            UpdateEvoked(devourer);
        }
        else
        {
            UpdateNotEvoked(devourer);
        }
        devourer.SetModelProperty("Mill", !IsPacmanGhost(devourer));
    }
    function UpdateEvoked(devourer:Entity):Void
    {
        if (!IsPacmanGhost(devourer))
        {
            UpdateEvokedDevour(devourer);
        }
        else
        {
            UpdateEvokedGhost(devourer);
        }
    }
    function UpdateEvokedDevour(devourer:Entity):Void
    {
        var devourTimer = GetDevourTimer(devourer);
        var target = devourer.Target;
        if (!target.ExistsAndAlive())
        {
            StartPacmanGhost(devourer);
        }
        else
        {
            if (devourTimer != null)
                devourTimer.Run(27);
            if (devourTimer == null || devourTimer.Expired)
            {
                FinishDevour(devourer, target);
                StartPacmanGhost(devourer);
            }
        }
        UpdateDevourerPosition(devourer);
    }
    function UpdateEvokedGhost(devourer:Entity):Void
    {
        var level = devourer.Level;

        var targetGridIndex = GetTargetGridIndex(devourer);
        var reached = devourer.MoveOrthogonally(targetGridIndex, EVOKED_MOVE_SPEED);

        // 垂直移动。
        var vel = devourer.Velocity;
        var groundY = devourer.GetGroundY();
        var yDistance = Mathf.Abs(groundY - devourer.Position.y);
        var yDirection = Mathf.Sign(groundY - devourer.Position.y);
        vel.y = yDirection * Mathf.Min(EVOKED_MOVE_SPEED, yDistance);
        devourer.Velocity = vel;

        if (reached)
        {
            FindPacmanGhostTarget(devourer);
        }

        var timer = GetDevourTimer(devourer);
        if (timer != null)
            timer.Run();
        if (timer == null || timer.Expired)
        {
            devourer.Die(new DamageEffectList([VanillaDamageEffects.SELF_DAMAGE]), devourer);
        }
    }
    function FindPacmanGhostTarget(devourer:Entity):Void
    {
        var level = devourer.Level;
        var giant = level.FindFirstEntity(e -> e.IsEntityOf(VanillaBossID.theGiant) && TheGiant.IsPacman(e));
        if (giant != null)
        {
            devourer.Target = giant;
        }
        else
        {
            var target = evokedDetector.DetectEntityWithTheLeast(DetectionParams.fromEntity(devourer), e -> (e.Position - devourer.Position).sqrMagnitude);
            devourer.Target = target;
        }
        var grid = devourer.GetChaseTargetGridDefaultValidator(devourer.Target);
        if (grid != null)
            SetTargetGridIndex(devourer, grid.GetIndex());
    }
    function StartPacmanGhost(devourer:Entity):Void
    {
        var devourTimer = GetDevourTimer(devourer);
        if (devourTimer != null)
            devourTimer.ResetTime(EVOCATION_DURATION);
        devourer.State = STATE_GHOST;
        FindPacmanGhostTarget(devourer);
        devourer.CollisionMaskHostile |= EntityCollisionHelper.MASK_VULNERABLE;
    }
    function UpdateNotEvoked(devourer:Entity):Void
    {
        if (!devourer.Target.ExistsAndAlive())
        {
            devourer.Die(new DamageEffectList([VanillaDamageEffects.SELF_DAMAGE]), devourer);
            return;
        }
        UpdateDevourerPosition(devourer);

        var devourTimer = GetDevourTimer(devourer);
        if (devourTimer != null)
            devourTimer.Run();
        if (devourTimer == null || devourTimer.Expired)
        {
            var target = devourer.Target;
            FinishDevour(devourer, target);
            devourer.Remove();
        }
    }
    function FinishDevour(devourer:Entity, target:Entity):Void
    {
        if (!target.ExistsAndAlive())
            return;

        if (target.IsEntityOf(VanillaObstacleID.monsterSpawner))
        {
            target.Remove();
            devourer.Produce(VanillaPickupID.emerald);
        }
        else
        {
            var effects = new DamageEffectList([VanillaDamageEffects.NO_BROKEN_LOCK, VanillaDamageEffects.REMOVE_ON_DEATH, VanillaDamageEffects.NO_DEATH_EFFECTS]);
            target.Die(effects, devourer);
            var spawnParams = devourer.GetSpawnParams();
            var entityID = target.GetDefinitionID();
            var blueprintID = LogicBlueprintID.FromEntity(entityID);
            spawnParams.SetProperty(VanillaPickupProps.CONTENT_ID, blueprintID);
            devourer.Produce(VanillaPickupID.blueprintPickup, spawnParams);
        }
    }
    function UpdateDevourerPosition(devourer:Entity):Void
    {
        if (!IsPacmanGhost(devourer))
        {
            if (devourer.Target != null)
            {
                var timer = GetDevourTimer(devourer);
                var percent = timer != null ? timer.GetTimeoutPercentage() : 0;
                var pos = devourer.Target.Position;
                pos.y += percent * DEVOUR_START_HEIGHT;
                pos.z -= 0.01;
                devourer.Position = pos;
            }
        }
    }
    //endregion

    //region 目标
    public static function GetMillTarget(devourer:Entity):Null<Entity>
    {
        var grid = devourer.GetGrid();
        if (grid == null)
            return null;

        var gridEntities = grid.GetEntities();
        var spawner = Lambda.find(gridEntities, e -> e.IsEntityOf(VanillaObstacleID.monsterSpawner));
        if (spawner.ExistsAndAlive())
            return spawner;

        var layers = grid.GetLayers();
        var orderedLayers = VanillaGridLayers.devourerLayers;
        for (layer in orderedLayers)
        {
            var entity = grid.GetLayerEntity(layer);
            if (entity == devourer || entity == null)
                continue;
            if (!CanMill(entity))
                continue;
            return entity;
        }
        return null;
    }
    public static function CanMill(entity:Entity):Bool
    {
        if (!entity.ExistsAndAlive())
            return false;
        if (!entity.IsEntityOf(VanillaObstacleID.monsterSpawner) && entity.Type != EntityTypes.PLANT)
            return false;
        if (entity.IsNoDevourer())
            return false;
        return true;
    }
    //endregion

    //region 属性
    public static function GetDevourTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_DEVOUR_TIMER);
    public static function SetDevourTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_DEVOUR_TIMER, timer);
    public static function GetTargetGridIndex(entity:Entity):Int return entity.GetBehaviourField(PROP_TARGET_GRID_INDEX);
    public static function SetTargetGridIndex(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_TARGET_GRID_INDEX, value);
    //endregion

    public static function IsPacmanGhost(entity:Entity):Bool
    {
        return entity.State == STATE_GHOST;
    }

    public static var PROP_DEVOUR_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("devourTimer");
    public static var PROP_TARGET_GRID_INDEX:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("targetGridIndex");
    public var evokedDetector:Detector;
    public static inline var STATE_IDLE:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_GHOST:Int = VanillaContraptionStates.DEVOURER_GHOST;
    public static inline var DEVOUR_TIME:Int = 135;
    public static inline var EVOCATION_DURATION:Int = 450;
    public static inline var EVOKED_MOVE_SPEED:Float = 4;
    public static inline var EVOKED_DAMAGE_MULTIPLIER:Float = 0.05;
    public static inline var DEVOUR_START_HEIGHT:Float = 48;
}
