// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Main/EmptyHandEntityHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2.vanilla.entities.IEmptyHandClickEntity;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.grids.VanillaGridExt;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemTargetEntity;
import mvz2logic.helditems.HeldItemTargetGrid;
import mvz2logic.helditems.HeldTargetFlag;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import tools.Ref;
import unity.Vector2;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.emptyHandEntity)
class EmptyHandEntityHeldItemBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
    {
        return HeldTargetFlag.Plant | HeldTargetFlag.Enemy | HeldTargetFlag.Boss | HeldTargetFlag.Obstacle;
    }
    public override function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointerInteraction:PointerInteractionData):Bool
    {
        var pointer = pointerInteraction.pointer;
        if (Std.isOfType(target, HeldItemTargetEntity))
        {
            var entityTarget = cast(target, HeldItemTargetEntity);
            return pointer.type == PointerTypes.MOUSE && CanUseOnEntity(entityTarget.Target);
        }
        if (Std.isOfType(target, HeldItemTargetGrid))
        {
            return pointer.type == PointerTypes.TOUCH;
        }
        return false;
    }
    public override function GetHighlight(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):HeldHighlight
    {
        if (Std.isOfType(target, HeldItemTargetEntity))
        {
            var entityTarget = cast(target, HeldItemTargetEntity);
            var entity = entityTarget.Target;
            var targetEntity = VanillaEntityExt.FindPointerTargetEntity(entity, entityTarget.LocalPointerPosition.y, new Vector2(entityTarget.ScreenPosition.x, entityTarget.ScreenPosition.y), CanUseOnEntity);
            return HeldHighlight.Entity(targetEntity);
        }
        else if (Std.isOfType(target, HeldItemTargetGrid))
        {
            if (pointer.interaction == PointerInteraction.Hold)
            {
                var gridTarget = cast(target, HeldItemTargetGrid);
                var grid = gridTarget.Target;
                // PORT-NOTE: C# `out float rangeMin, out float rangeMax` → tools.Ref<Float>。
                var rangeMin = Ref.to(0.0);
                var rangeMax = Ref.to(0.0);
                var entityTarget = VanillaGridExt.FindPointerTargetEntity(grid, gridTarget.LocalPointerPosition.y, CanUseOnEntity, rangeMin, rangeMax);
                if (entityTarget != null)
                {
                    return HeldHighlight.Green(grid, rangeMin.value, rangeMax.value);
                }
            }
        }
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
        if (Std.isOfType(target, HeldItemTargetEntity))
        {
            OnPointerEventEntity(cast(target, HeldItemTargetEntity), data, pointerParams);
        }
        else if (Std.isOfType(target, HeldItemTargetGrid))
        {
            OnPointerEventGrid(cast(target, HeldItemTargetGrid), data, pointerParams);
        }
    }
    private function OnPointerEventEntity(target:HeldItemTargetEntity, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        var entity = target.Target;
        var targetEntity = VanillaEntityExt.FindPointerTargetEntity(entity, target.LocalPointerPosition.y, new Vector2(target.ScreenPosition.x, target.ScreenPosition.y), CanUseOnEntity);
        if (targetEntity != null && CanUseOnEntityOfPointer(targetEntity, pointerParams))
        {
            LogicLevelExt.ResetHeldItem(entity.Level);
            UseOnEntity(targetEntity);
        }
    }
    private function OnPointerEventGrid(target:HeldItemTargetGrid, data:IHeldItemData, pointerData:PointerInteractionData):Void
    {
        var grid = target.Target;
        // PORT-NOTE: C# `out _, out _` → 忽略的 tools.Ref<Float>。
        var rangeMin = Ref.to(0.0);
        var rangeMax = Ref.to(0.0);
        var targetEntity = VanillaGridExt.FindPointerTargetEntity(grid, target.LocalPointerPosition.y, CanUseOnEntity, rangeMin, rangeMax);
        if (targetEntity != null && CanUseOnEntityOfPointer(targetEntity, pointerData))
        {
            LogicLevelExt.ResetHeldItem(grid.Level);
            UseOnEntity(targetEntity);
        }
    }
    private function CanUseOnEntity(entity:Entity):Bool
    {
        if (!entity.ExistsAndAlive())
            return false;
        if (VanillaEntityProps.NoHeldTarget(entity))
            return false;
        return VanillaContraptionExt.CanEmptyHandClick(entity);
    }
    private function CanUseOnEntityOfPointer(entity:Entity, pointerData:PointerInteractionData):Bool
    {
        // TODO-PORT: C# 泛型方法 GetBehaviour<T>()，Haxe 无法在无参情况下推断泛型参数，改为传入类型。
        var behaviour:Null<IEmptyHandClickEntity> = cast entity.Definition.GetBehaviour(cast IEmptyHandClickEntity);
        if (behaviour == null)
            return false;
        return behaviour.IsValidPointerInteraction(entity, pointerData) && behaviour.CanEmptyHandClick(entity);
    }
    private function UseOnEntity(entity:Entity):Void
    {
        VanillaContraptionExt.EmptyHandClick(entity);
    }
}
