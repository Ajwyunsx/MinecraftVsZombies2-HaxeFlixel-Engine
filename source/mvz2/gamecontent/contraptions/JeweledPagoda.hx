// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/JeweledPagoda.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.effects.PagodaLaser;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2.vanilla.statemachine.EntityStateMachineState;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.EngineEntityProps;
import pvzengine.EntityID;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import unity.Color;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.jeweledPagoda)
class JeweledPagoda extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Set, PROP_GRAVITY));
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_TINT_MULTIPLIER));
        AddModifier(ColorModifier.Multiply(LogicEntityProps.LIGHT_COLOR, PROP_TINT_MULTIPLIER));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        stateMachine.Init(entity);
        stateMachine.StartState(entity, STATE_ASCENT);
    }
    override function UpdateAI(pagoda:Entity):Void
    {
        super.UpdateAI(pagoda);
        stateMachine.UpdateAI(pagoda);
    }
    override function UpdateLogic(pagoda:Entity):Void
    {
        super.UpdateLogic(pagoda);
        stateMachine.UpdateLogic(pagoda);
    }
    public static function SpawnLaser(pagoda:Entity):Null<Entity>
    {
        // C#: pagoda.Spawn(...)?.Let(laser => { ... })
        var laser = pagoda.Spawn(VanillaEffectID.pagodaLaser, pagoda.Position + PagodaLaser.POSITION_OFFSET);
        if (laser != null)
        {
            laser.SetParent(pagoda);
            SetLaser(pagoda, new EntityID(laser));
        }
        return laser;
    }
    public static function SetLaser(pagoda:Entity, laser:EntityID):Void pagoda.SetProperty(PROP_LASER, laser);
    public static function GetLaser(pagoda:Entity):Null<EntityID> return pagoda.GetProperty(PROP_LASER);
    public static function AddDisabledGridCount(pagoda:Entity, value:Int):Void SetDisabledGridCount(pagoda, GetDisabledGridCount(pagoda) + value);
    public static function SetDisabledGridCount(pagoda:Entity, value:Int):Void pagoda.SetProperty(PROP_DISABLED_GRID_COUNT, value);
    public static function GetDisabledGridCount(pagoda:Entity):Int return pagoda.GetProperty(PROP_DISABLED_GRID_COUNT);
    public static inline var STATE_ASCENT:Int = VanillaContraptionStates.JEWELED_PAGODA_ASCENT;
    public static inline var STATE_LASER:Int = VanillaContraptionStates.JEWELED_PAGODA_LASER;
    public static inline var STATE_DISAPPEAR:Int = VanillaContraptionStates.JEWELED_PAGODA_DISAPPEAR;
    public static inline var TARGET_RELATIVE_Y:Float = 64;
    public static inline var GRIDS_PER_STARSHARD:Int = 3;
    public var stateMachine:EntityStateMachine = new PagodaStateMachine();
    public static var PROP_GRAVITY:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("gravity");
    public static var PROP_DISABLED_GRID_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("disabled_grid_count");
    public static var PROP_TINT_MULTIPLIER:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("tint_multiplier", Color.white);
    public static var PROP_LASER:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("laser");
}

class PagodaStateMachine extends EntityStateMachine
{
    public function new()
    {
        super();
        AddState(new AscentState());
        AddState(new LaserState());
        AddState(new DisappearState());
    }
}

class AscentState extends EntityStateMachineState
{
    public function new()
    {
        super(JeweledPagoda.STATE_ASCENT);
    }

    public override function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.ResetTime(15);
    }

    public override function OnUpdateAI(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.Run(machine.GetSpeed(entity));

        var position = entity.Position;
        var targetY = entity.GetGroundY() + JeweledPagoda.TARGET_RELATIVE_Y;
        position.y = position.y * 0.5 + targetY * 0.5;
        entity.Position = position;
        if (timer.Expired)
        {
            machine.StartState(entity, JeweledPagoda.STATE_LASER);
        }
    }
}

class LaserState extends EntityStateMachineState
{
    public function new()
    {
        super(JeweledPagoda.STATE_LASER);
    }

    public override function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        JeweledPagoda.SpawnLaser(entity);
    }

    public override function OnUpdateAI(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(machine, entity);
        var laserID = JeweledPagoda.GetLaser(entity);
        var laser = laserID != null ? laserID.GetEntity(entity.Level) : null;
        if (!laser.ExistsAndAlive())
        {
            var count = JeweledPagoda.GetDisabledGridCount(entity);
            var starshardCount = Std.int(count / JeweledPagoda.GRIDS_PER_STARSHARD);
            for (i in 0...starshardCount)
            {
                entity.Spawn(VanillaPickupID.starshard, entity.GetCenter());
            }
            machine.StartState(entity, JeweledPagoda.STATE_DISAPPEAR);
        }
    }
}

class DisappearState extends EntityStateMachineState
{
    public function new()
    {
        super(JeweledPagoda.STATE_DISAPPEAR);
    }

    public override function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.ResetTime(30);
    }

    public override function OnUpdateAI(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(machine, entity);
        var timer = machine.GetStateTimer(entity);
        timer.Run(machine.GetSpeed(entity));

        var tintMultiplier = new Color(1, 1, 1, timer.GetTimeoutPercentage());
        entity.SetProperty(JeweledPagoda.PROP_GRAVITY, -0.5);
        entity.SetProperty(JeweledPagoda.PROP_TINT_MULTIPLIER, tintMultiplier);
        if (timer.Expired)
        {
            entity.Remove();
        }
    }
}
