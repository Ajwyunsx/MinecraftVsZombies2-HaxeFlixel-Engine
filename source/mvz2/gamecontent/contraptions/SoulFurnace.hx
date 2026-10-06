// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter1/SoulFurnace.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.SoulFurnaceEvocationDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.projectiles.SoulfireBall;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.grids.VanillaGridLayers;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;
using tools.EnumerableExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.soulFurnace)
class SoulFurnace extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        evocationDetector = new SoulFurnaceEvocationDetector();
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
        var fuel = 0;
        if (entity.Level.IsIZombie())
        {
            fuel = I_ZOMBIE_FUEL;
        }
        SetFuel(entity, fuel);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        var fuel = GetFuel(entity);
        if (fuel > 0)
        {
            if (!entity.IsEvoked())
            {
                ShootTick(entity);
            }
            else
            {
                EvokedUpdate(entity);
            }
        }

        UpdateSacrifice(entity);
        var percentage = fuel / MAX_FUEL;
        var light = 0.0;
        if (fuel > 0)
        {
            light = Mathf.Lerp(0.5, 1, percentage);
        }
        var bar = GetDisplayFuel(entity);
        bar = bar * 0.5 + (percentage) * 0.5;
        SetDisplayFuel(entity, bar);

        entity.SetAnimationFloat("Light", light);
        entity.SetAnimationFloat("Bar", bar);

        entity.SetIsFire(fuel > 0);
        entity.SetLightSource(fuel > 0);
        entity.SetLightRange(Vector3.one * (240 * light));
    }
    public override function Shoot(entity:Entity):Null<Entity>
    {
        var projectile = super.Shoot(entity);
        SpendFuel(entity, 1);
        return projectile;
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var fuel = GetFuel(entity);
        fuel = Std.int(Mathf.Max(REFUEL_THRESOLD, fuel));
        SetFuel(entity, fuel);
        entity.SetEvoked(true);
    }

    public function GetFuel(entity:Entity):Int return entity.GetBehaviourFieldNS(ID, PROP_FUEL);
    public function SetFuel(entity:Entity, value:Int):Void entity.SetBehaviourFieldNS(ID, PROP_FUEL, Mathf.ClampInt(value, 0, MAX_FUEL));
    public function AddFuel(entity:Entity, value:Int):Void
    {
        SetFuel(entity, GetFuel(entity) + value);
    }
    public function SpendFuel(entity:Entity, value:Int):Void
    {
        var fuelBefore = GetFuel(entity);
        AddFuel(entity, -value);
        var fuelAfter = GetFuel(entity);
        if (fuelAfter <= 0 && fuelBefore > 0)
        {
            entity.PlaySound(VanillaSoundID.fizz);
        }
    }
    public function GetDisplayFuel(entity:Entity):Float return entity.GetBehaviourFieldNS(ID, PROP_DISPLAY_FUEL);
    public function SetDisplayFuel(entity:Entity, value:Float):Void entity.SetBehaviourFieldNS(ID, PROP_DISPLAY_FUEL, value);
    public function CanSacrifice(entity:Entity, soulFurnace:Entity):Bool
    {
        var canSacrifice = entity.Type == EntityTypes.PLANT && !entity.IsDead && GetFuel(soulFurnace) <= REFUEL_THRESOLD;
        var result = new CallbackResult(canSacrifice);
        entity.Level.Triggers.RunCallbackWithResultFiltered(VanillaLevelCallbacks.CAN_CONTRAPTION_SACRIFICE, new ContraptionSacrificeValueParams(entity, soulFurnace), result, entity.GetDefinitionID());
        return result.GetValue();
    }
    public static function GetSacrificeFuel(entity:Entity, soulFurnace:Entity):Int
    {
        var fuel = 10;

        var game = Global.Game;

        var fuelMultiplier = 1.0;

        var cost = entity.GetCost();
        var rechargeID = entity.GetRechargeID();
        if (rechargeID != null)
        {
            var rechargeDef = game.GetRechargeDefinition(rechargeID);
            if (rechargeDef != null)
            {
                fuelMultiplier = rechargeDef.GetQuality();
            }
        }

        fuel = Mathf.CeilToInt((fuel + cost / 3) * fuelMultiplier);
        var result = new CallbackResult(fuel);
        entity.Level.Triggers.RunCallbackWithResult(VanillaLevelCallbacks.GET_CONTRAPTION_SACRIFICE_FUEL, new ContraptionSacrificeValueParams(entity, soulFurnace), result);
        return result.GetValue();
    }
    public function Sacrifice(entity:Entity, soulFurnace:Entity, fuel:Int):Void
    {
        var result = new CallbackResult(true);
        Global.Game.RunCallbackWithResultFiltered(VanillaLevelCallbacks.PRE_CONTRAPTION_SACRIFICE, new ContraptionSacrificeParams(entity, soulFurnace, fuel), result, entity.GetDefinitionID());
        if (!result.GetValue())
            return;

        var effects = new DamageEffectList([VanillaDamageEffects.SACRIFICE]);
        entity.Die(effects, soulFurnace);
        AddFuel(soulFurnace, fuel);
        entity.Level.Spawn(VanillaEffectID.soulfireBurn, entity.GetCenter(), soulFurnace);
        entity.PlaySound(VanillaSoundID.refuel);

        Global.Game.RunCallbackFiltered(VanillaLevelCallbacks.POST_CONTRAPTION_SACRIFICE, new ContraptionSacrificeParams(entity, soulFurnace, fuel), entity.GetDefinitionID());
    }
    function UpdateSacrifice(furnace:Entity):Void
    {
        if (furnace.IsDead)
            return;
        var column = furnace.GetColumn();
        var lane = furnace.GetLane();
        var targetGrid = furnace.Level.GetGrid(column + 1 * furnace.GetFacingX(), lane);
        if (targetGrid == null)
            return;
        var layers = targetGrid.GetLayers();
        var orderedLayers = VanillaGridLayers.sacrificeLayers;
        for (layer in orderedLayers)
        {
            var ent = targetGrid.GetLayerEntity(layer);
            if (ent == null || !CanSacrifice(ent, furnace))
                continue;
            var fuel = GetSacrificeFuel(ent, furnace);
            Sacrifice(ent, furnace, fuel);
            break;
        }
    }
    function EvokedUpdate(entity:Entity):Void
    {
        detectBuffer = [];
        evocationDetector.DetectMultiple(DetectionParams.fromEntity(entity), detectBuffer);
        var shootPoint = entity.GetShootPoint();
        var shootDir:Vector3;
        if (detectBuffer.length <= 0)
        {
            shootDir = entity.GetFacingDirection();
        }
        else
        {
            var targetCollider = detectBuffer.Random(entity.RNG);
            var target = targetCollider.Entity;
            shootDir = (target.Position - shootPoint).normalized;
            shootDir.y = 0;
        }
        var shotspeed = entity.GetShotVelocity().magnitude * 2;
        var velocity = shotspeed * shootDir;
        var projectile = entity.ShootProjectile(entity.GetProjectileID(), velocity);

        if (projectile != null)
        {
            SoulfireBall.SetBlast(projectile, true);
            entity.PlaySound(VanillaSoundID.darkSkiesCast);
        }

        SpendFuel(entity, 1);

        if (GetFuel(entity) <= 0)
        {
            entity.SetEvoked(false);
        }
    }

    static var ID:NamespaceID = VanillaContraptionID.soulFurnace;
    public static var PROP_FUEL:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("Fuel");
    public static var PROP_DISPLAY_FUEL:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("DisplayFuel");
    public static inline var MAX_FUEL:Int = 120;
    public static inline var REFUEL_THRESOLD:Int = 20;
    public static inline var I_ZOMBIE_FUEL:Int = REFUEL_THRESOLD + 5;
    var evocationDetector:Detector;
    var detectBuffer:Array<IEntityCollider> = [];
}
