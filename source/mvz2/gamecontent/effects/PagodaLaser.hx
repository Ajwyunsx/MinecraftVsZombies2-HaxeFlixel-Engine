// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/PagodaLaser.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.contraptions.JeweledPagoda;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.effects.VanillaEffectStates;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2.vanilla.statemachine.EntityStateMachineState;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Mathf;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.pagodaLaser)
class PagodaLaser extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_SCALE_MULTIPLIER));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.PlaySound(VanillaSoundID.sweepingBeam);
        stateMachine.Init(entity);
        stateMachine.StartState(entity, STATE_EXPAND);
        var lane = entity.GetLane();
        var column = 0;
        var x = entity.Level.GetColumnCenterX(column);
        var z = entity.Level.GetLaneCenterZ(lane);
        var y = entity.Level.GetGroundY(x, z);
        SetDestination(entity, new Vector3(x, y, z));
        entity.SetModelProperty("Dest", GetDestination(entity));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var parent = entity.Parent;
        if (!parent.ExistsAndAlive())
        {
            entity.Remove();
            return;
        }
        entity.Position = parent.Position + POSITION_OFFSET;
        stateMachine.UpdateAI(entity);
        stateMachine.UpdateLogic(entity);
        entity.SetModelProperty("Dest", GetDestination(entity));
    }
    public static function CanDisableGrid(grid:LawnGrid):Bool
    {
        if (!grid.IsEmpty())
            return false;
        if (grid.IsDisabled())
            return false;
        return true;
    }
    public static function DisableGrid(grid:LawnGrid):Void
    {
        grid.AddBuff(VanillaBuffID.Grid.goldenGrid);
    }
    public static function SetDestination(entity:Entity, value:Vector3):Void entity.SetProperty(PROP_DESTINATION, value);
    public static function GetDestination(entity:Entity):Vector3 return entity.GetProperty(PROP_DESTINATION);
    public static inline var STATE_EXPAND:Int = VanillaEffectStates.PAGODA_LASER_EXPAND;
    public static inline var STATE_SWIPE:Int = VanillaEffectStates.PAGODA_LASER_SWIPE;
    public static inline var STATE_SUBTRACT:Int = VanillaEffectStates.PAGODA_LASER_SUBTRACT;
    public static var POSITION_OFFSET:Vector3 = new Vector3(0, 16, 0);
    public var stateMachine:EntityStateMachine = new PagodaLaserStateMachine();
    public static var PROP_SCALE_MULTIPLIER:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("scale_multiplier", Vector3.zero);
    public static var PROP_DESTINATION:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("dest");
}

// PORT-NOTE: C# 的嵌套类 PagodaLaser.PagodaLaserStateMachine 提升为模块级类（Haxe 不支持嵌套类）。
class PagodaLaserStateMachine extends EntityStateMachine
{
    public function new()
    {
        super();
        AddState(new PagodaLaserExpandState());
        AddState(new PagodaLaserSwipeState());
        AddState(new PagodaLaserSubstractState());
    }
}

// PORT-NOTE: C# 的嵌套类 PagodaLaser.ExpandState 提升为模块级类。
class PagodaLaserExpandState extends EntityStateMachineState
{
    public function new()
    {
        super(PagodaLaser.STATE_EXPAND);
    }

    public override function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.ResetTime(5);
    }

    public override function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.Run(machine.GetSpeed(entity));

        var scaleMultiplier = new Vector3(1, timer.GetPassedPercentage(), 1);
        entity.SetProperty(PagodaLaser.PROP_SCALE_MULTIPLIER, scaleMultiplier);

        if (timer.Expired)
        {
            machine.StartState(entity, PagodaLaser.STATE_SWIPE);
        }
    }
}

// PORT-NOTE: C# 的嵌套类 PagodaLaser.SwipeState 提升为模块级类。
class PagodaLaserSwipeState extends EntityStateMachineState
{
    public function new()
    {
        super(PagodaLaser.STATE_SWIPE);
    }

    public override function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.ResetTime(10);
    }

    public override function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.Run(machine.GetSpeed(entity));

        var level = entity.Level;

        // 移动激光照射区域。
        var speed = Mathf.Lerp(10, 40, timer.GetPassedPercentage());
        var startDestination = PagodaLaser.GetDestination(entity);
        var destination = startDestination;
        destination += Vector3.right * speed;
        var maxX = level.GetColumnCenterX(level.GetMaxColumnCount() - 1);
        destination.x = Mathf.Min(destination.x, maxX);
        destination.y = level.GetGroundY(destination.x, destination.z);
        PagodaLaser.SetDestination(entity, destination);

        // 点金地格。
        var column = level.GetColumn(destination.x);
        var lane = level.GetLane(destination.z);
        var grid = level.GetGrid(column, lane);
        if (grid != null)
        {
            if (PagodaLaser.CanDisableGrid(grid))
            {
                PagodaLaser.DisableGrid(grid);
                entity.Level.PlaySoundAt(VanillaSoundID.gold, grid.GetEntityPosition(), grid.Column / 9 * 0.5 + 1);
                var parent = entity.Parent;
                if (parent.ExistsAndAlive())
                {
                    JeweledPagoda.AddDisabledGridCount(parent, 1);
                }
            }
        }


        if (destination.x >= maxX)
        {
            machine.StartState(entity, PagodaLaser.STATE_SUBTRACT);
        }
    }
}

// PORT-NOTE: C# 的嵌套类 PagodaLaser.SubstractState 提升为模块级类。
class PagodaLaserSubstractState extends EntityStateMachineState
{
    public function new()
    {
        super(PagodaLaser.STATE_SUBTRACT);
    }

    public override function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.ResetTime(5);
    }

    public override function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.Run(machine.GetSpeed(entity));

        var scaleMultiplier = new Vector3(1, timer.GetTimeoutPercentage(), 1);
        entity.SetProperty(PagodaLaser.PROP_SCALE_MULTIPLIER, scaleMultiplier);

        if (timer.Expired)
        {
            entity.Remove();
        }
    }
}
