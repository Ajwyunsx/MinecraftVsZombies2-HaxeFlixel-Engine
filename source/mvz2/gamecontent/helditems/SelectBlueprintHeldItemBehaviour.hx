// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/SelectBlueprintHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.pickups.BlueprintPickup;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.Global;
import mvz2logic.blueprints.LogicBlueprintErrors;
import mvz2logic.blueprints.LogicSeedExt;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemBuilder;
import mvz2logic.helditems.HeldItemTargetBlueprint;
import mvz2logic.helditems.HeldItemTargetEntity;
import mvz2logic.helditems.HeldTargetFlag;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.helditems.LogicHeldTypes;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.level.LogicHeldItemProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.options.LogicOptionExt;
import mvz2logic.saves.LogicSaveExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.ClassicSeedPack;
import pvzengine.seedpacks.ConveyorSeedPack;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;
using mvz2logic.games.LogicGameDefinitionsExt;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.selectBlueprint)
class SelectBlueprintHeldItemBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
    {
        return HeldTargetFlag.Pickup;
    }
    public override function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointerInteraction:PointerInteractionData):Bool
    {
        var pointer = pointerInteraction.pointer;
        if (Std.isOfType(target, HeldItemTargetBlueprint))
        {
            return true;
        }
        else if (Std.isOfType(target, HeldItemTargetEntity))
        {
            var entityTarget = cast(target, HeldItemTargetEntity);
            return VanillaEntityExt.IsBlueprintPickup(entityTarget.Target);
        }
        return false;
    }
    public override function GetHighlight(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):HeldHighlight
    {
        return HeldHighlight.None;
    }
    public override function OnPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (PointerHelper.IsInvalidClickButton(pointerParams))
            return;
        OnMainPointerEvent(target, data, pointerParams);
    }
    private function OnMainPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (Std.isOfType(target, HeldItemTargetBlueprint))
        {
            OnPointerEventBlueprint(cast(target, HeldItemTargetBlueprint), data, pointerParams);
        }
        else if (Std.isOfType(target, HeldItemTargetEntity))
        {
            OnPointerEventEntity(cast(target, HeldItemTargetEntity), data, pointerParams);
        }
    }
    private function GetBlueprintPickData(level:LevelEngine, canInstantEvoke:Bool, canInstantTrigger:Bool):PickData
    {
        // 进行激发检测。
        var holdingStarshard = LogicLevelExt.IsHoldingStarshard(level);
        var willEvoke = holdingStarshard && canInstantEvoke;

        // 进行立即触发检测。
        var holdingTrigger = LogicLevelExt.IsHoldingTrigger(level);
        var willTrigger = holdingTrigger && canInstantTrigger;
        var swapped = IsTriggerSwapped();
        var triggerValue = canInstantTrigger && holdingTrigger != swapped;

        return new PickData(willEvoke, willTrigger, triggerValue);
    }

    // 蓝图
    private function OnPointerEventBlueprint(target:HeldItemTargetBlueprint, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (!IsValidPointer(pointerParams))
            return;
        var level = target.Level;
        var seedPack = target.GetSeedPack();
        if (seedPack == null)
            return;

        var pickData = GetBlueprintPickDataFromPack(seedPack);

        var enchanted = pickData.IsEnchanted();
        if (pointerParams.interaction == PointerInteraction.Release && !enchanted)
            return;
        PickupBlueprint(seedPack, pickData);
    }
    // TODO-PORT: C# 重载 GetBlueprintPickData(SeedPack) 与 GetBlueprintPickData(LevelEngine, SeedDefinition)，
    // Haxe 不支持重载，分别重命名为 GetBlueprintPickDataFromPack / GetBlueprintPickDataFromDefinition。
    private function GetBlueprintPickDataFromPack(seedPack:SeedPack):PickData
    {
        var canInstantEvoke = LogicSeedExt.WillInstantEvokeOfPack(seedPack);
        var canInstantTrigger = LogicSeedExt.CanInstantTrigger(seedPack);
        return GetBlueprintPickData(seedPack.Level, canInstantEvoke, canInstantTrigger);
    }
    private function PickupBlueprint(blueprint:SeedPack, pickData:PickData):Void
    {
        var level = blueprint.Level;
        // 先取消已经手持的物品。
        if (!pickData.IsEnchanted() && LogicLevelExt.IsHoldingExclusiveItem(level))
        {
            if (LogicLevelExt.CancelHeldItem(level))
            {
                LogicLevelExt.PlaySound(level, VanillaSoundID.tap);
            }
            return;
        }
        // 无法拾取蓝图。
        var blueprintError = LogicSeedExt.GetPickError(blueprint);
        if (NamespaceID.IsValid(blueprintError))
        {
            if (blueprintError == LogicBlueprintErrors.notEnoughEnergy)
            {
                LogicLevelExt.FlickerEnergy(level);
            }
            LogicLevelExt.PlaySound(level, VanillaSoundID.buzzer);
            return;
        }
        var seedType = LogicSeedProps.GetSeedTypeOfPack(blueprint);
        switch (seedType)
        {
            case SeedTypes.ENTITY:
                var type = LogicHeldTypes.blueprint;
                var index = -1;
                if (Std.isOfType(blueprint, ClassicSeedPack))
                {
                    index = level.GetSeedPackIndex(cast(blueprint, ClassicSeedPack));
                }
                else if (Std.isOfType(blueprint, ConveyorSeedPack))
                {
                    type = LogicHeldTypes.conveyor;
                    index = level.GetConveyorSeedPackIndex(cast(blueprint, ConveyorSeedPack));
                }

                // 设置当前手持物品。
                var builder = new HeldItemBuilder(type, 0);
                LogicHeldItemProps.SetSeedPackIndex(builder, index);
                LogicHeldItemProps.SetInstantTrigger(builder, pickData.triggerValue);
                LogicHeldItemProps.SetInstantEvoke(builder, pickData.instantEvoke);
                LogicLevelExt.SetHeldItem(level, builder);
                LogicLevelExt.PlaySound(level, VanillaSoundID.pick);

            case SeedTypes.OPTION:
                var optionID = LogicSeedProps.GetSeedOptionIDOfPack(blueprint);
                if (optionID == null)
                    return;
                var optionDef = level.Content.GetSeedOptionDefinition(optionID);
                if (optionDef == null)
                    return;
                optionDef.Use(blueprint);
                level.AddEnergy(-blueprint.GetCost());
        }
    }

    // 蓝图掉落物
    private function OnPointerEventEntity(target:HeldItemTargetEntity, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (!IsValidPointer(pointerParams))
            return;
        var pickup = target.Target;
        var level = pickup.Level;
        var seedDefinition = BlueprintPickup.GetSeedDefinition(pickup);
        if (seedDefinition == null)
            return;

        var pickData = GetBlueprintPickDataFromDefinition(level, seedDefinition);

        var enchanted = pickData.IsEnchanted();
        if (pointerParams.interaction == PointerInteraction.Release && !enchanted)
            return;
        PickupBlueprintPickup(pickup, pickData);
    }
    private function GetBlueprintPickDataFromDefinition(level:LevelEngine, seedDef:SeedDefinition):PickData
    {
        var canInstantEvoke = LogicSeedExt.WillInstantEvoke(seedDef, level);
        var canInstantTrigger = LogicSeedProps.IsTriggerActive(seedDef) && LogicSeedProps.CanInstantTrigger(seedDef);
        return GetBlueprintPickData(level, canInstantEvoke, canInstantTrigger);
    }
    private function PickupBlueprintPickup(pickup:Entity, pickData:PickData):Void
    {
        var level = pickup.Level;
        // 先取消已经手持的物品。
        if (!pickData.IsEnchanted() && LogicLevelExt.IsHoldingExclusiveItem(level))
        {
            if (LogicLevelExt.CancelHeldItem(level))
            {
                LogicLevelExt.PlaySound(level, VanillaSoundID.tap);
            }
            return;
        }
        var blueprintDef = BlueprintPickup.GetSeedDefinition(pickup);
        if (blueprintDef == null)
            return;
        var seedType = LogicSeedProps.GetSeedType(blueprintDef);
        switch (seedType)
        {
            case SeedTypes.ENTITY:
                // 设置当前手持物品。
                var builder = new HeldItemBuilder(VanillaHeldTypes.blueprintPickup, 0);
                LogicHeldItemProps.SetEntityID(builder, pickup.ID);
                LogicHeldItemProps.SetInstantTrigger(builder, pickData.triggerValue);
                LogicHeldItemProps.SetInstantEvoke(builder, pickData.instantEvoke);
                LogicLevelExt.SetHeldItem(level, builder);
                LogicEntityExt.PlaySound(pickup, VanillaSoundID.pick);

            case SeedTypes.OPTION:
                var optionID = LogicSeedProps.GetSeedOptionID(blueprintDef);
                if (optionID == null)
                    return;
                var optionDef = level.Content.GetSeedOptionDefinition(optionID);
                if (optionDef == null)
                    return;
                optionDef.UseWithDefinition(level, blueprintDef);
        }
    }

    private function IsTriggerSwapped():Bool
    {
        return LogicSaveExt.IsTriggerUnlocked(Global.Saves) && LogicOptionExt.IsTriggerSwapped(Global.Options);
    }
    private function IsValidPointer(pointerParams:PointerInteractionData):Bool
    {
        if (pointerParams.pointer.type == PointerTypes.TOUCH)
        {
            if (pointerParams.interaction != PointerInteraction.Release && pointerParams.interaction != PointerInteraction.Down)
                return false;
        }
        else if (pointerParams.pointer.type == PointerTypes.MOUSE)
        {
            if (pointerParams.interaction != PointerInteraction.Down)
                return false;
        }
        else if (pointerParams.pointer.type == PointerTypes.KEY)
        {
            if (pointerParams.interaction != PointerInteraction.Key)
                return false;
        }
        return true;
    }
}

// PORT-NOTE: C# 嵌套 struct PickData → Haxe 模块级类（Haxe 不允许在类内声明类型）。
class PickData
{
    public function new(instantEvoke:Bool, instantTrigger:Bool, triggerValue:Bool)
    {
        this.instantEvoke = instantEvoke;
        this.instantTrigger = instantTrigger;
        this.triggerValue = triggerValue;
    }

    public function IsEnchanted():Bool
    {
        return instantEvoke || instantTrigger;
    }

    public var instantEvoke:Bool;
    public var instantTrigger:Bool;
    public var triggerValue:Bool;
}
