// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/ToEntityHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.grids.VanillaGridExt;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemTargetEntity;
import mvz2logic.helditems.HeldItemTargetGrid;
import mvz2logic.helditems.HeldItemTargetLawn;
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

// abstract
class ToEntityHeldItemBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
    {
        return HeldTargetFlag.Plant;
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
        if (Std.isOfType(target, HeldItemTargetLawn))
        {
            return true;
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
            return HeldHighlight.Red(grid);
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
        if (Std.isOfType(target, HeldItemTargetLawn))
        {
            OnPointerEventLawn(cast(target, HeldItemTargetLawn), data, pointerParams);
        }
        else if (Std.isOfType(target, HeldItemTargetEntity))
        {
            OnPointerEventEntity(cast(target, HeldItemTargetEntity), data, pointerParams);
        }
        else if (Std.isOfType(target, HeldItemTargetGrid))
        {
            OnPointerEventGrid(cast(target, HeldItemTargetGrid), data, pointerParams);
        }
    }
    private function OnPointerEventLawn(target:HeldItemTargetLawn, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (PointerHelper.IsInvalidReleaseAction(pointerParams))
            return;
        var level = target.Level;
        if (LogicLevelExt.CancelHeldItem(level))
        {
            LogicLevelExt.PlaySound(level, VanillaSoundID.tap);
        }
    }
    private function OnPointerEventEntity(target:HeldItemTargetEntity, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        var interaction = pointerParams.interaction;
        if (interaction != PointerInteraction.Down)
            return;

        var entity = target.Target;
        var targetEntity = VanillaEntityExt.FindPointerTargetEntity(entity, target.LocalPointerPosition.y, new Vector2(target.ScreenPosition.x, target.ScreenPosition.y), CanUseOnEntity);
        LogicLevelExt.ResetHeldItem(entity.Level);
        if (targetEntity != null)
        {
            UseOnEntity(targetEntity);
        }
    }
    private function OnPointerEventGrid(target:HeldItemTargetGrid, data:IHeldItemData, pointerData:PointerInteractionData):Void
    {
        var interaction = pointerData.interaction;
        if (interaction != PointerInteraction.Release)
            return;

        var grid = target.Target;
        // PORT-NOTE: C# `out _, out _` → 忽略的 tools.Ref<Float>。
        var rangeMin = Ref.to(0.0);
        var rangeMax = Ref.to(0.0);
        var targetEntity = VanillaGridExt.FindPointerTargetEntity(grid, target.LocalPointerPosition.y, CanUseOnEntity, rangeMin, rangeMax);
        LogicLevelExt.ResetHeldItem(grid.Level);
        if (targetEntity != null)
        {
            UseOnEntity(targetEntity);
        }
    }

    // abstract
    public function CanUseOnEntity(entity:Entity):Bool throw "abstract";
    // abstract
    public function UseOnEntity(entity:Entity):Void throw "abstract";
}
