// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Main/CombatHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.Global;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.HeldHighlightGrid;
import mvz2logic.helditems.HeldHighlightMode;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemTargetGrid;
import mvz2logic.helditems.HeldItemTargetLawn;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.level.LawnArea;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.PropertyMeta;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.EngineEntityProps;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import pvzengine.level.SpawnParams;
import unity.Vector2;
import unity.Vector3;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.combat)
class CombatHeldItemBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):Bool
    {
        var pointerData = pointer.pointer;
        if (pointerData.type == PointerTypes.TOUCH && pointerData.button != 0)
            return false;
        return Std.isOfType(target, HeldItemTargetGrid) || IsDragging(data);
    }
    public override function OnBegin(level:LevelEngine, data:IHeldItemData):Void
    {
        super.OnBegin(level, data);
        UpdateModel(level, data);
    }
    public override function OnUpdate(level:LevelEngine, data:IHeldItemData):Void
    {
        super.OnUpdate(level, data);
        UpdateModel(level, data);
        if (!IsValid(level, data))
        {
            LogicLevelExt.ResetHeldItem(level);
        }
    }
    public function IsValid(level:LevelEngine, data:IHeldItemData):Bool
    {
        return LogicLevelProps.GetStarshardCount(level) > 0 && LogicLevelProps.CanUseStarshard(level) && LogicLevelProps.GetStarshardHeldType(level) == data.Type;
    }
    public override function GetHighlight(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):HeldHighlight
    {
        var level = target.GetLevel();
        var dragged = IsDragging(data);

        var grids:Array<LawnGrid> = [];
        if (dragged)
        {
            var startPosition = GetDragStartPosition(data);
            var startLawnPosition = LogicLevelExt.ScreenToLawnPositionByRelativeY(level, startPosition, 0);
            var grid = level.GetGridAt(startLawnPosition);
            if (grid != null)
            {
                var artType = GetCombatType(level, data);
                switch (artType)
                {
                    case CombatType.Smash:
                        var minX = -1;
                        var maxX = 1;
                        var minY = -1;
                        var maxY = 1;
                        for (xOffset in minX...(maxX + 1))
                        {
                            for (yOffset in minY...(maxY + 1))
                            {
                                var g = level.GetGrid(grid.Column + xOffset, grid.Lane + yOffset);
                                if (g != null)
                                    grids.push(g);
                            }
                        }
                    case CombatType.Uppercut:
                        var minUpX = -2;
                        var maxUpX = 2;
                        var minUpY = -2;
                        var maxUpY = 2;
                        for (xOffset in minUpX...(maxUpX + 1))
                        {
                            for (yOffset in minUpY...(maxUpY + 1))
                            {
                                var g = level.GetGrid(grid.Column + xOffset, grid.Lane + yOffset);
                                if (g != null)
                                    grids.push(g);
                            }
                        }
                    case CombatType.Punch:
                        for (x in 0...level.GetMaxColumnCount())
                        {
                            var g = level.GetGrid(x, grid.Lane);
                            if (g != null)
                                grids.push(g);
                        }
                }
            }
        }
        else if (Std.isOfType(target, HeldItemTargetGrid))
        {
            var gridTarget = cast(target, HeldItemTargetGrid);
            var grid = gridTarget.Target;
            if (grid != null)
            {
                grids.push(grid);
            }
        }

        // C#: new HeldHighlight() { mode = HeldHighlightMode.Grid, grids = grids.Select(g => HeldHighlightGrid.Green(g)).ToArray() }
        var highlightGrids:Array<HeldHighlightGrid> = [];
        for (g in grids)
        {
            highlightGrids.push(HeldHighlightGrid.Green(g));
        }
        return new HeldHighlight(HeldHighlightMode.Grid, null, highlightGrids);
    }
    public override function OnPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (PointerHelper.IsInvalidClickButton(pointerParams))
            return;
        var pointer = pointerParams.pointer;
        if (pointer.type == PointerTypes.TOUCH && pointer.button != 0)
            return;
        OnMainPointerEvent(target, data, pointerParams);
    }
    private function OnMainPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (Std.isOfType(target, HeldItemTargetGrid))
        {
            OnPointerEventGrid(cast(target, HeldItemTargetGrid), data, pointerParams);
        }
        else if (Std.isOfType(target, HeldItemTargetLawn))
        {
            OnPointerEventLawn(cast(target, HeldItemTargetLawn), data, pointerParams);
        }
        var pointer = pointerParams.pointer;
        if (pointerParams.interaction == PointerInteraction.Drag)
        {
            var level = target.GetLevel();
            var pointerPosition = Global.Input.GetPointerScreenPositionByType(pointer.type, pointer.button);
            SetDragPosition(data, pointerPosition);
        }
        else if (pointerParams.interaction == PointerInteraction.Up)
        {
            var level = target.GetLevel();
            var pointerPosition = Global.Input.GetPointerScreenPositionByType(pointer.type, pointer.button);
            SetDragPosition(data, pointerPosition);
            CastCombat(level, data);
            LogicLevelExt.ResetHeldItem(level);
        }
    }
    private function OnPointerEventGrid(gridTarget:HeldItemTargetGrid, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (pointerParams.interaction == PointerInteraction.Down)
        {
            var level = gridTarget.GetLevel();
            var pointer = pointerParams.pointer;
            var pointerPosition = Global.Input.GetPointerScreenPositionByType(pointer.type, pointer.button);
            SetDragStartPosition(data, pointerPosition);
            SetDragPosition(data, pointerPosition);
        }
    }
    private function OnPointerEventLawn(lawnTarget:HeldItemTargetLawn, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (pointerParams.interaction == PointerInteraction.Down)
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
    }
    private function GetCombatType(level:LevelEngine, data:IHeldItemData):CombatType
    {
        var dragStartPosition = GetDragStartPosition(data);
        var dragPosition = GetDragPosition(data);
        var direction = LogicLevelExt.ScreenToLawnPositionByY(level, dragPosition, 0) - LogicLevelExt.ScreenToLawnPositionByY(level, dragStartPosition, 0);
        var angle = Vector2.Angle(Vector2.down, new Vector2(direction.x, direction.z));
        var castPosition = LogicLevelExt.ScreenToLawnPositionByRelativeY(level, dragStartPosition, 0);
        if (direction.sqrMagnitude <= SQR_THRESOLD || angle < 45 || angle >= 315)
        {
            return CombatType.Smash;
        }
        else if (angle > 135 && angle <= 225)
        {
            return CombatType.Uppercut;
        }
        else
        {
            return CombatType.Punch;
        }
    }
    private function UpdateModel(level:LevelEngine, data:IHeldItemData):Void
    {
        var modelInterface = LogicLevelExt.GetHeldItemModelInterface(level);
        if (modelInterface == null)
            return;
        var dragging = IsDragging(data);
        modelInterface.SetModelProperty("ShowLine", dragging);
        if (dragging)
        {
            var startPosition = GetDragStartPosition(data);
            var startLawnPos = LogicLevelExt.ScreenToLawnPositionByY(level, startPosition, 0);
            modelInterface.SetModelProperty("Dest", startLawnPos);
        }
    }
    private function CastCombat(level:LevelEngine, data:IHeldItemData):Void
    {
        var artType = GetCombatType(level, data);
        var dragStartPosition = GetDragStartPosition(data);
        var castPosition = LogicLevelExt.ScreenToLawnPositionByRelativeY(level, dragStartPosition, 0);
        if (artType == CombatType.Punch)
        {
            CastCombatPunch(level, castPosition);
        }
        else if (artType == CombatType.Uppercut)
        {
            CastCombatUppercut(level, castPosition);
        }
        else
        {
            CastCombatSmash(level, castPosition);
        }
        LogicLevelExt.PlaySoundAt(level, VanillaSoundID.evocation, castPosition);
        LogicLevelExt.PlaySoundAt(level, VanillaSoundID.steveRoar, castPosition);
        LogicLevelProps.AddStarshardCount(level, -1);
        LogicLevelExt.ResetHeldItem(level);
    }
    private function CastCombatSmash(level:LevelEngine, position:Vector3):Void
    {
        var column = level.GetColumn(position.x);
        var lane = level.GetLane(position.z);
        var x = level.GetEntityColumnX(column);
        var z = level.GetEntityLaneZ(lane);
        var y = level.GetGroundY(x, z);
        var pos = new Vector3(x, y, z);
        var param = new SpawnParams();
        param.SetProperty(EngineEntityProps.FACTION, level.Option.LeftFaction);
        param.SetProperty(VanillaEntityProps.DAMAGE, 1800.0);
        param.SetProperty(VanillaEntityProps.RANGE, 120.0);
        level.Spawn(VanillaEffectID.combatSmash, pos, null, param);
    }
    private function CastCombatUppercut(level:LevelEngine, position:Vector3):Void
    {
        var column = level.GetColumn(position.x);
        var lane = level.GetLane(position.z);
        var x = level.GetEntityColumnX(column);
        var z = level.GetEntityLaneZ(lane);
        var y = level.GetGroundY(x, z);
        var pos = new Vector3(x, y, z);
        var param = new SpawnParams();
        param.SetProperty(EngineEntityProps.FACTION, level.Option.LeftFaction);
        param.SetProperty(VanillaEntityProps.DAMAGE, 400.0);
        param.SetProperty(VanillaEntityProps.RANGE, 200.0);
        level.Spawn(VanillaEffectID.combatUppercut, pos, null, param);
    }
    private function CastCombatPunch(level:LevelEngine, position:Vector3):Void
    {
        var lane = level.GetLane(position.z);
        var x:Float = 0;
        var z = level.GetEntityLaneZ(lane);
        var y = level.GetGroundY(x, z);
        var pos = new Vector3(x, y, z);
        var param = new SpawnParams();
        param.SetProperty(EngineEntityProps.FACTION, level.Option.LeftFaction);
        param.SetProperty(VanillaEntityProps.DAMAGE, 1200.0);
        level.Spawn(VanillaEffectID.combatPunch, pos, null, param);
    }
    private function IsDragging(data:IHeldItemData):Bool
    {
        var dragStartPosition = GetDragStartPosition(data);
        var dragPosition = GetDragPosition(data);
        return Vector2.SqrMagnitude(dragPosition - dragStartPosition) > 1;
    }
    public override function GetModelID(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
    {
        super.GetModelID(level, data, result);
        result.SetFinalValue(VanillaModelID.combat);
    }
    public static function SetDragStartPosition(data:IHeldItemData, position:Vector2):Void
    {
        data.SetProperty(PROP_DRAG_START_POSITION, position);
    }
    public static function GetDragStartPosition(data:IHeldItemData):Vector2
    {
        return data.GetProperty(PROP_DRAG_START_POSITION);
    }
    public static function SetDragPosition(data:IHeldItemData, position:Vector2):Void
    {
        data.SetProperty(PROP_DRAG_POSITION, position);
    }
    public static function GetDragPosition(data:IHeldItemData):Vector2
    {
        return data.GetProperty(PROP_DRAG_POSITION);
    }
    // C#: public const float SQR_THRESOLD = 20 * 20;
    public static inline var SQR_THRESOLD:Float = 400;
    public static var PROP_DRAG_START_POSITION:PropertyMeta<Vector2> = new PropertyMeta<Vector2>("drag_start_position");
    public static var PROP_DRAG_POSITION:PropertyMeta<Vector2> = new PropertyMeta<Vector2>("drag_position");
}

// PORT-NOTE: C# 嵌套 enum CombatType → Haxe 模块级 enum abstract（Haxe 不允许在类内声明类型）。
enum abstract CombatType(Int)
{
    var Smash = 0;
    var Punch = 1;
    var Uppercut = 2;
}
