// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Main/BlueprintHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.Global;
import mvz2logic.blueprints.LogicSeedExt;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.games.LogicGameExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemTargetGrid;
import mvz2logic.helditems.HeldItemTargetLawn;
import mvz2logic.helditems.IBlueprintHeldItemBehaviour;
import mvz2logic.helditems.IEntityTwinklePlaceMethod;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.helditems.IHeldTwinkleEntityBehaviour;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.level.LawnArea;
import mvz2logic.level.LogicHeldItemProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.localization.LogicStrings;
import mvz2logic.models.SortingLayers.ShaderProperties;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
import pvzengine.entities.EngineEntityProps;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import pvzengine.models.IModelInterface;
import pvzengine.seedpacks.SeedPack;
import tools.Ref;

// PORT-NOTE: 原文件包含三个顶层类（BlueprintHeldItemBehaviour、ClassicBlueprintHeldItemBehaviour、
// ConveyorBlueprintHeldItemBehaviour），保留在同一模块中。
// abstract
class BlueprintHeldItemBehaviour extends HeldItemBehaviourDefinition implements IBlueprintHeldItemBehaviour implements IHeldTwinkleEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):Bool
    {
        return Std.isOfType(target, HeldItemTargetGrid);
    }
    public override function OnUpdate(level:LevelEngine, data:IHeldItemData):Void
    {
        super.OnUpdate(level, data);
        if (!IsValid(level, data))
        {
            LogicLevelExt.ResetHeldItem(level);
        }
    }
    public function IsValid(level:LevelEngine, data:IHeldItemData):Bool
    {
        var seedPack = GetSeedPack(level, data);
        if (seedPack == null)
            return false;
        return LogicSeedExt.CanPick(seedPack);
    }
    public override function GetHighlight(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):HeldHighlight
    {
        if (!Std.isOfType(target, HeldItemTargetGrid))
            return HeldHighlight.None;

        var gridTarget = cast(target, HeldItemTargetGrid);
        var grid = gridTarget.Target;

        var level = grid.Level;
        var seed = GetSeedPack(level, data);
        var seedDef = seed != null ? seed.Definition : null;
        return LogicGridExt.GetSeedHeldHighlight(grid, seedDef);
    }
    public override function OnPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (PointerHelper.IsInvalidClickButton(pointerParams))
            return;
        OnMainPointerEvent(target, data, pointerParams);
    }
    private function OnMainPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (Std.isOfType(target, HeldItemTargetGrid))
        {
            OnPointerEventGrid(cast(target, HeldItemTargetGrid), data, pointerParams);
        }
    }
    private function OnPointerEventGrid(gridTarget:HeldItemTargetGrid, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (PointerHelper.IsInvalidReleaseAction(pointerParams))
            return;
        var level = gridTarget.GetLevel();
        var seed = GetSeedPack(level, data);
        var seedDef = seed != null ? seed.Definition : null;
        if (seedDef == null)
            return;
        var grid = gridTarget.Target;
        var error:Ref<Null<NamespaceID>> = Ref.to(null);
        if (!LogicGridExt.CanPlaceBlueprintByID(grid, seedDef.GetID(), error))
        {
            if (error.value != null)
            {
                var message = LogicGameExt.GetGridErrorMessage(Global.Game, error.value);
                if (message != null && message != "")
                {
                    LogicLevelExt.ShowAdvice(level, LogicStrings.CONTEXT_ADVICE, message, 0, 150, []);
                }
            }
            return;
        }

        if (LogicSeedProps.GetSeedType(seedDef) == SeedTypes.ENTITY)
        {
            var type = data.Type;
            CostBlueprint(grid, data);
            if (seed != null)
            {
                LogicGridExt.UseEntityBlueprint(grid, seed, data);
            }
            ResetHeldItemIfType(level, type);
        }
    }
    // PORT-NOTE: 原 C# 中该方法未被任何位置调用（保留 1:1）。
    private function OnPointerEventLawn(lawnTarget:HeldItemTargetLawn, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        var level = lawnTarget.Level;
        var area = lawnTarget.Area;

        if (area == LawnArea.Side)
        {
            if (LogicLevelExt.CancelHeldItem(level))
            {
                LogicLevelExt.PlaySound(level, VanillaSoundID.tap);
            }
        }
    }
    public override function OnSetModel(level:LevelEngine, data:IHeldItemData, model:Null<IModelInterface>):Void
    {
        super.OnSetModel(level, data, model);
        if (model == null)
            return;
        var seedPack = GetSeedPack(level, data);
        if (seedPack == null)
            return;
        if (LogicSeedProps.IsCommandBlockOfPack(seedPack))
        {
            model.SetShaderInt(ShaderProperties.GRAYSCALE, 1);
            model.ApplyShaderProperties();
        }
    }

    public function ShouldMakeEntityTwinkle(entity:Entity, data:IHeldItemData):Bool
    {
        var level = entity.Level;
        var seedPack = GetSeedPack(level, data);
        if (seedPack == null || LogicSeedProps.GetSeedTypeOfPack(seedPack) != SeedTypes.ENTITY)
            return false;
        var seedEntityID = LogicSeedProps.GetSeedEntityIDOfPack(seedPack);
        var entityDef = level.Content.GetEntityDefinition(seedEntityID);
        if (entityDef == null)
            return false;
        var placementID = EngineEntityProps.GetPlacementID(entityDef);
        var placementDef = level.Content.GetPlacementDefinition(placementID);
        if (placementDef == null)
            return false;
        // TODO-PORT: C# 泛型方法 GetMethod<T>()，Haxe 无法在无参情况下推断泛型参数，改为传入类型。
        var method = placementDef.GetMethod(IEntityTwinklePlaceMethod);
        if (method == null)
            return false;
        return method.ShouldMakeEntityTwinkle(placementDef, entity, entityDef);
    }

    // C#: protected virtual void CostBlueprint(LawnGrid grid, IHeldItemData data)
    public function CostBlueprint(grid:LawnGrid, data:IHeldItemData):Void
    {

    }
    // abstract
    public function GetSeedPack(level:LevelEngine, data:IHeldItemData):Null<SeedPack> throw "abstract";
    public override function GetModelID(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
    {
        var seed = GetSeedPack(level, data);
        var seedDef = seed != null ? seed.Definition : null;
        if (seedDef == null)
            return;

        result.SetFinalValue(LogicSeedProps.GetModelID(seedDef));
    }
    public override function GetModelOffset(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
    {
        var seed = GetSeedPack(level, data);
        var seedDef = seed != null ? seed.Definition : null;
        if (seedDef == null)
            return;
        if (LogicSeedProps.GetSeedType(seedDef) == SeedTypes.ENTITY)
        {
            var seedEntityID = LogicSeedProps.GetSeedEntityID(seedDef);
            var entityDef = level.Content.GetEntityDefinition(seedEntityID);
            if (entityDef == null)
                return;
            result.SetFinalValue(-entityDef.GetGridPivotOffset());
        }
    }
}

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.classicBlueprint)
class ClassicBlueprintHeldItemBehaviour extends BlueprintHeldItemBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function CostBlueprint(grid:LawnGrid, data:IHeldItemData):Void
    {
        var level = grid.Level;
        var seed = GetSeedPack(level, data);
        if (seed == null)
            return;
        level.AddEnergy(-seed.GetCost());
        seed.SetStartRecharge(false);
        seed.ResetRecharge();
    }
    public override function GetSeedPack(level:LevelEngine, data:IHeldItemData):Null<SeedPack>
    {
        return level.GetSeedPackAt(LogicHeldItemProps.GetSeedPackIndex(data));
    }
}

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.conveyorBlueprint)
class ConveyorBlueprintHeldItemBehaviour extends BlueprintHeldItemBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function CostBlueprint(grid:LawnGrid, data:IHeldItemData):Void
    {
        grid.Level.RemoveConveyorSeedPackAt(LogicHeldItemProps.GetSeedPackIndex(data));
    }
    public override function GetSeedPack(level:LevelEngine, data:IHeldItemData):Null<SeedPack>
    {
        return level.GetConveyorSeedPackAt(LogicHeldItemProps.GetSeedPackIndex(data));
    }
}
