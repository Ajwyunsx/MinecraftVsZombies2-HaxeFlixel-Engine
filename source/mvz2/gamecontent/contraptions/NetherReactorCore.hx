// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/NetherReactorCore.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.FrameTimer;
import tools.TimerHelper;
import unity.Mathf;
import unity.Vector2Int;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.blueprints.LogicSeedOptionProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;
using pvzengine.seedpacks.EngineSeedProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.netherReactorCore)
class NetherReactorCore extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.PRODUCE_SPEED, NumberOperator.Multiply, PROP_PRODUCE_SPEED_MULTIPLIER));
        AddModifier(new BooleanModifier(LogicEntityProps.IS_LIGHT_SOURCE, PROP_WORKING));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var maxSeconds = entity.GetProperty(PROP_MAX_PRODUCE_TIME);
        SetProductionTimer(entity, TimerHelper.NewSecondTimer(maxSeconds));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.IsSecondsInterval(CHECK_INTERVAL_SECONDS))
        {
            Check(entity);
        }
        if (IsWorking(entity))
        {
            Work(entity);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var productionTimer = GetProductionTimer(entity);
        entity.SetAnimationBool("Working", IsWorking(entity));
        entity.SetAnimationFloat("Progress", productionTimer != null ? productionTimer.GetPassedPercentage() : 0);
    }

    function Check(entity:Entity):Void
    {
        var diagnoalID = CheckDiagnoalID(entity);
        var straightID = CheckStraightID(entity);
        if (IsValidPair(diagnoalID, straightID))
        {
            var multiplier = CalculateProduceSpeedMultiplier(entity, diagnoalID, straightID);
            SetProduceSpeedMultiplier(entity, multiplier);
            if (!IsWorking(entity))
            {
                entity.PlaySound(VanillaSoundID.ironCurtain);
            }
            SetWorking(entity, true);
        }
        else
        {
            SetProduceSpeedMultiplier(entity, 1);
            SetWorking(entity, false);
        }
    }
    function CheckDiagnoalID(entity:Entity):Null<NamespaceID>
    {
        return CheckID(entity, diagnoalOffsets);
    }
    function CheckStraightID(entity:Entity):Null<NamespaceID>
    {
        return CheckID(entity, straightOffsets);
    }
    function CheckID(entity:Entity, offsets:Array<Vector2Int>):Null<NamespaceID>
    {
        var grid = entity.GetGrid();
        if (grid == null)
            return null;
        var level = entity.Level;
        var column = grid.Column;
        var lane = grid.Lane;
        var entityID:Null<NamespaceID> = null;
        var entityRefs:Map<haxe.Int64, Bool> = new Map();
        for (i in 0...offsets.length)
        {
            var offset = offsets[i];
            var targetGrid = level.GetGrid(column + offset.x, lane + offset.y);
            var ent = targetGrid != null ? targetGrid.GetMainEntity() : null;
            if (ent == null || entityRefs.exists(ent.ID))
                return null;
            var entID = ent.GetDefinitionID();
            if (entityID == null)
            {
                entityID = entID;
            }
            else if (entID != entityID)
            {
                return null;
            }
            entityRefs.set(ent.ID, true);
        }
        return entityID;
    }
    // C#: private bool IsValidPair([NotNullWhen(true)] NamespaceID? id1, [NotNullWhen(true)] NamespaceID? id2)
    function IsValidPair(id1:Null<NamespaceID>, id2:Null<NamespaceID>):Bool
    {
        if (id1 == null || id2 == null)
            return false;
        if (id1 == id2)
            return false;
        return true;
    }
    function CalculateProduceSpeedMultiplier(entity:Entity, id1:NamespaceID, id2:NamespaceID):Float
    {
        var level = entity.Level;
        var def1 = level.Content.GetEntityDefinition(id1);
        if (def1 == null)
            return 1;
        var def2 = level.Content.GetEntityDefinition(id2);
        if (def2 == null)
            return 1;
        var rechargeID1 = LogicEntityProps.GetRechargeIDOfDefinition(def1);
        var recharge1 = level.Content.GetRechargeDefinition(rechargeID1);
        if (recharge1 == null)
            return 1;
        var rechargeID2 = LogicEntityProps.GetRechargeIDOfDefinition(def2);
        var recharge2 = level.Content.GetRechargeDefinition(rechargeID2);
        if (recharge2 == null)
            return 1;
        var cost1 = LogicEntityProps.GetCostOfDefinition(def1);
        var cost2 = LogicEntityProps.GetCostOfDefinition(def2);
        var t1 = cost1 * recharge1.GetQuality();
        var t2 = cost2 * recharge2.GetQuality();
        var divisor = entity.GetProperty(PROP_QUALITY_DIVISOR);
        var t = (t1 + t2) / divisor;

        var minSeconds = entity.GetProperty(PROP_MIN_PRODUCE_TIME);
        var maxSeconds = entity.GetProperty(PROP_MAX_PRODUCE_TIME);
        var maxSpeedMultiplier = maxSeconds / minSeconds;
        return Mathf.Lerp(1, maxSpeedMultiplier, t);
    }
    function Work(entity:Entity):Void
    {
        var productionTimer = GetProductionTimer(entity);
        if (productionTimer.RunToExpiredAndNotNull(entity.GetProduceSpeed()))
        {
            productionTimer.Reset();
            entity.Spawn(VanillaPickupID.starshard, entity.GetCenter());
        }
    }
    public static function GetProductionTimer(entity:Entity):Null<FrameTimer> return entity.GetProperty(PROP_PRODUCTION_TIMER);
    public static function SetProductionTimer(entity:Entity, timer:Null<FrameTimer>):Void entity.SetProperty(PROP_PRODUCTION_TIMER, timer);
    public static function IsWorking(entity:Entity):Bool return entity.GetProperty(PROP_WORKING);
    public static function SetWorking(entity:Entity, value:Bool):Void entity.SetProperty(PROP_WORKING, value);
    public static function GetProduceSpeedMultiplier(entity:Entity):Float return entity.GetProperty(PROP_PRODUCE_SPEED_MULTIPLIER);
    public static function SetProduceSpeedMultiplier(entity:Entity, value:Float):Void entity.SetProperty(PROP_PRODUCE_SPEED_MULTIPLIER, value);

    static var PROP_PRODUCTION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("production_timer");
    public static var PROP_MIN_PRODUCE_TIME:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("min_produce_time", 15);
    public static var PROP_MAX_PRODUCE_TIME:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("max_produce_time", 90);
    public static var PROP_QUALITY_DIVISOR:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("quality_divisor", 2000);
    public static var PROP_PRODUCE_SPEED_MULTIPLIER:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("production_speed_multiplier", 1);
    public static var PROP_WORKING:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("working");

    public static var diagnoalOffsets:Array<Vector2Int> = [
        new Vector2Int(-1, -1),
        new Vector2Int(1, -1),
        new Vector2Int(-1, 1),
        new Vector2Int(1, 1),
    ];
    public static var straightOffsets:Array<Vector2Int> = [
        new Vector2Int(-1, 0),
        new Vector2Int(0, -1),
        new Vector2Int(1, 0),
        new Vector2Int(0, 1),
    ];
    public static inline var CHECK_INTERVAL_SECONDS:Float = 1;
}
