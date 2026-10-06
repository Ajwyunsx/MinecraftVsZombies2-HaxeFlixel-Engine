// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter3/ThunderDrum.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaFactions;
import mvz2.vanilla.enemies.VanillaMass;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.projectiles.VanillaProjectileProps;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.NamespaceID;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import tools.FrameTimer;
import tools.Ticks;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;
using tools.VectorExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.thunderDrum)
class ThunderDrum extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetRestoreTimer(entity, new FrameTimer(RESTORE_TIME));
        SetEvocationTimer(entity, new FrameTimer(EVOCATION_DURATION));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.IsEvoked())
        {
            var evocationTimer = GetEvocationTimer(entity);
            if (evocationTimer != null)
            {
                evocationTimer.Run();

                detectBuffer = [];
                entity.Level.FindEntitiesNonAlloc(e -> IsValidTarget(entity, e), detectBuffer);
                for (target in detectBuffer)
                {
                    if (target.Type == EntityTypes.BOSS)
                        continue;
                    target.TakeDamage(target.GetMaxHealth() * TOTAL_HP_LOSS / EVOCATION_DURATION, new DamageEffectList([VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.MUTE]), entity);
                }
                entity.Level.ShakeScreen(3, 0, 3);

                if (evocationTimer.Expired)
                {
                    entity.SetEvoked(false);
                    entity.Level.RemoveLoopSoundEntity(VanillaSoundID.earthquake, entity.ID);
                }
            }
        }
        else if (IsBroken(entity))
        {
            var restoreTimer = GetRestoreTimer(entity);
            if (restoreTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
            {
                SetBroken(entity, false);
            }
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetAnimationBool("Broken", IsBroken(entity));
        entity.SetAnimationBool("Evoked", entity.IsEvoked());
        entity.SetAnimationFloat("ChargeBlend", GetChargeBlend(entity));
    }
    public override function CanTrigger(entity:Entity):Bool
    {
        return super.CanTrigger(entity) && !entity.IsEvoked() && !IsBroken(entity);
    }
    override function OnTrigger(entity:Entity):Void
    {
        super.OnTrigger(entity);
        Quake(entity);
        SetBroken(entity, true);
        var restoreTimer = GetRestoreTimer(entity);
        if (restoreTimer != null)
            restoreTimer.ResetTime(RESTORE_TIME);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        SetBroken(entity, false);

        entity.Level.AddLoopSoundEntity(VanillaSoundID.earthquake, entity.ID);

        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer != null)
            evocationTimer.ResetTime(EVOCATION_DURATION);

        if (entity.Level.AreaID == VanillaAreaID.palace)
        {
            PalaceEarthQuake(entity.Level);
        }
    }
    function IsValidTarget(self:Entity, target:Entity):Bool
    {
        if (!target.IsVulnerableEntity() || !self.IsHostile(target))
            return false;
        if (target.IsDead)
            return false;
        if (!target.IsOnGround)
            return false;
        if (!target.IsAboveLand())
            return false;
        return true;
    }
    function Quake(self:Entity):Void
    {
        detectBuffer = [];
        self.Level.FindEntitiesNonAlloc(e -> IsValidTarget(self, e), detectBuffer);
        for (target in detectBuffer)
        {
            if (target.Type != EntityTypes.ENEMY)
                continue;
            var knockbackMultiplier = target.GetStrongKnockbackMultiplier();

            var vel = target.Velocity;
            vel.x = 4 * knockbackMultiplier;
            vel.y = 15 * knockbackMultiplier;
            target.Velocity = vel;

            if (target.GetMass() <= VanillaMass.MEDIUM)
            {
                target.RandomChangeAdjacentLane(self.RNG);
            }

            target.ApplyStrongImpact();
        }
        self.Level.ShakeScreen(15, 0, 30);
        self.PlaySound(VanillaSoundID.lightningAttack);
    }
    function GetChargeBlend(self:Entity):Float
    {
        if (!IsBroken(self))
            return 0;
        var restoreTimer = GetRestoreTimer(self);
        return restoreTimer != null ? restoreTimer.GetPassedPercentage() : 0;
    }
    public static function PalaceEarthQuake(level:LevelEngine):Void
    {
        var center = level.GetLawnCenter();
        var artifactPos = center + Vector3.up * 600;
        level.SpawnUnlockArtifactPickup(VanillaAreaID.palace, VanillaUnlockID.magmaStone, VanillaArtifactID.magmaStone, artifactPos, null);

        var rng = level.CreateRNG();
        var xSize = level.GetGridWidth() * level.GetMaxColumnCount();
        var ySize = 600.0;
        var zSize = level.GetGridHeight() * level.GetMaxLaneCount();
        var xStart = -xSize * 0.5;
        var yStart = 0;
        var zStart = -zSize * 0.5;

        var spawnParam = new SpawnParams();
        spawnParam.SetProperty(EngineEntityProps.FACTION, VanillaFactions.NEUTRAL);
        spawnParam.SetProperty(VanillaEntityProps.MAX_TIMEOUT, Ticks.FromSeconds(5));
        spawnParam.SetProperty(VanillaEntityProps.DAMAGE, 80);
        spawnParam.SetProperty(VanillaProjectileProps.NO_DESTROY_OUTSIDE_LAWN, true);
        for (i in 0...BOULDER_COUNT_IN_PALACE)
        {
            var x = rng.NextFloat() * xSize + xStart;
            var y = rng.NextFloat() * ySize + yStart;
            var z = rng.NextFloat() * zSize + zStart;
            var pos = artifactPos + new Vector3(x, y, z);
            // C#: level.Spawn(...)?.Let(boulder => { ... })
            var boulder = level.Spawn(VanillaProjectileID.boulder, pos, null, spawnParam);
            if (boulder != null)
            {
                var angle = rng.NextFloat() * 360;
                var length = rng.NextFloat() * 5 + 5;
                var speed2D = (Vector2.right * length).RotateClockwise(angle);
                boulder.Velocity = new Vector3(speed2D.x, 0, speed2D.y);
            }
        }
    }
    public static function IsBroken(entity:Entity):Bool return entity.GetBehaviourFieldNS(ID, FIELD_BROKEN);
    public static function SetBroken(entity:Entity, value:Bool):Void entity.SetBehaviourFieldNS(ID, FIELD_BROKEN, value);
    public static function GetRestoreTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourFieldNS(ID, FIELD_RESTORE_TIMER);
    public static function SetRestoreTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourFieldNS(ID, FIELD_RESTORE_TIMER, timer);
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourFieldNS(ID, FIELD_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourFieldNS(ID, FIELD_EVOCATION_TIMER, timer);

    public static inline var BOULDER_COUNT_IN_PALACE:Int = 30;
    public static inline var RESTORE_TIME:Int = 1800;
    public static inline var EVOCATION_DURATION:Int = 120;
    public static inline var TOTAL_HP_LOSS:Float = 0.25;
    public static var FIELD_BROKEN:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("Broken");
    public static var FIELD_RESTORE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("RestoreTimer");
    public static var FIELD_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
    static var ID:NamespaceID = VanillaContraptionID.thunderDrum;
    var detectBuffer:Array<Entity> = [];
}
