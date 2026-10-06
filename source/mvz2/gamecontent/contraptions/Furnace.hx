// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Prologue/Furnace.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.BooleanOperator;
import pvzengine.modifiers.ColorModifier;
import tools.FrameTimer;
import unity.Color;
import unity.Mathf;
using mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;
import mvz2.vanilla.pickups.VanillaPickupProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.furnace)
class Furnace extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, PROP_COLOR_OFFSET));
        AddModifier(new BooleanModifier(VanillaEntityProps.IS_FIRE, BooleanOperator.And, PROP_BURNING));
        AddModifier(new BooleanModifier(LogicEntityProps.IS_LIGHT_SOURCE, BooleanOperator.And, PROP_BURNING));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);

        var productionTimer = new FrameTimer(entity.RNG.Next(90, 375));
        SetProductionTimer(entity, productionTimer);

        var evocationTimer = new FrameTimer(EVOCATION_DURATION);
        SetEvocationTimer(entity, evocationTimer);

        if (entity.Level.IsIZombie())
        {
            entity.SetCanDeactive(false);
        }
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.IsEvoked())
        {
            EvokedUpdate(entity);
        }
        else if (entity.Level.IsIZombie())
        {
            IZombieUpdate(entity);
        }
        else
        {
            ProductionUpdate(entity);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var frozen = entity.IsAIFrozen();
        if (entity.Level.IsIZombie())
        {
            if (GetDroppedRedstones(entity) >= GetRedstonesToDrop(entity, 0))
            {
                frozen = true;
            }
        }
        if (frozen)
        {
            entity.SetProperty(PROP_COLOR_OFFSET, Color.clear);
        }
        entity.SetProperty(PROP_BURNING, !frozen);
        entity.SetAnimationBool("Frozen", frozen);
    }

    public override function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);
        if (entity.Level.IsIZombie())
        {
            var redstonesToDrop = GetRedstonesToDrop(entity, 0);
            DropRedstones(entity, redstonesToDrop);
        }
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer != null)
            evocationTimer.Reset();
        entity.SetEvoked(true);
    }
    public static function GetProductionTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_PRODUCTION_TIMER);
    public static function SetProductionTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_PRODUCTION_TIMER, timer);
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_EVOCATION_TIMER, timer);
    public static function GetDroppedRedstones(entity:Entity):Int return entity.GetBehaviourField(PROP_DROPPED_REDSTONES);
    public static function SetDroppedRedstones(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_DROPPED_REDSTONES, value);
    function ProductionUpdate(entity:Entity):Void
    {
        var productionTimer = GetProductionTimer(entity);
        if (productionTimer == null)
            return;
        productionTimer.Run(entity.GetProduceSpeed());
        if (entity.Level.IsNoEnergy())
        {
            productionTimer.Frame = productionTimer.MaxFrame;
        }

        var color = entity.GetProperty(PROP_COLOR_OFFSET);
        var colorValue = color.a;
        if (productionTimer.Frame < 30)
        {
            colorValue = Mathf.Lerp(1, 0, productionTimer.Frame / 30);
        }
        else
        {
            colorValue = Mathf.Max(0, colorValue - 1 / 30);
        }
        color.r = 1;
        color.g = 1;
        color.b = 1;
        color.a = colorValue;
        entity.SetProperty(PROP_COLOR_OFFSET, color);

        if (productionTimer.Expired)
        {
            if (entity.IsFriendlyEntity())
            {
                entity.Produce(VanillaPickupID.redstone);
                entity.PlaySound(VanillaSoundID.throwSound);
            }
            else
            {
                var redstoneDefinition = entity.Level.Content.GetEntityDefinition(VanillaPickupID.redstone);
                var energyValue = redstoneDefinition != null ? VanillaPickupProps.GetEnergyValueOfDefinition(redstoneDefinition) : 25;
                entity.Level.AddEnergy(-energyValue);
            }
            productionTimer.ResetTime(720);
        }
    }

    //region 我是僵尸
    function IZombieUpdate(entity:Entity):Void
    {
        var hp = entity.Health;
        if (!entity.IsFriendlyEntity())
        {
            hp = 0;
        }
        var redstonesToDrop = GetRedstonesToDrop(entity, hp);
        DropRedstones(entity, redstonesToDrop);
    }
    function DropRedstones(entity:Entity, targetCount:Int):Void
    {
        var droppedRedstones = GetDroppedRedstones(entity);
        var count = targetCount - droppedRedstones;
        if (count <= 0)
            return;
        for (i in 0...count)
        {
            entity.Produce(VanillaPickupID.redstone);
        }
        SetDroppedRedstones(entity, targetCount);
    }
    function GetRedstonesToDrop(entity:Entity, hp:Float):Int
    {
        var totalCount = entity.Level.GetIZFurnaceRedstoneCount();
        var hpPerRedstone = entity.GetMaxHealth() / totalCount;
        return Mathf.FloorToInt(totalCount - hp / hpPerRedstone);
    }
    //endregion
    function EvokedUpdate(entity:Entity):Void
    {
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer == null)
            return;
        evocationTimer.Run();
        if (evocationTimer.PassedInterval(EVOCATION_INTERVAL))
        {
            entity.Produce(VanillaPickupID.redstone);
            entity.PlaySound(VanillaSoundID.potion);
        }
        if (evocationTimer.Expired)
        {
            entity.SetEvoked(false);
        }
    }
    public static inline var EVOCATION_INTERVAL:Int = 5;
    public static inline var EVOCATION_REDSTONES:Int = 6;
    public static inline var EVOCATION_DURATION:Int = EVOCATION_INTERVAL * EVOCATION_REDSTONES;
    static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
    static var PROP_PRODUCTION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("ProductionTimer");
    static var PROP_DROPPED_REDSTONES:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("LastRemaionRedstones");
    public static var PROP_BURNING:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("burning", true);
    public static var PROP_COLOR_OFFSET:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("color_offset");
}
