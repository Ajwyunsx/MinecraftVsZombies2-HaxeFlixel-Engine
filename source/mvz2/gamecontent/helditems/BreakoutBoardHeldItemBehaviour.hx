// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Entity/BreakoutHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.effects.BreakoutBoard;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.HeldItemTargetLawn;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.level.LawnArea;

// PORT-NOTE: C# 文件名 BreakoutHeldItemBehaviour.cs 与主类名不一致，按类名命名模块（Haxe 模块名须与主类型名一致）。
@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.breakoutBoard)
class BreakoutBoardHeldItemBehaviour extends EntityHeldItemBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):Bool
    {
        return Std.isOfType(target, HeldItemTargetLawn) && (cast(target, HeldItemTargetLawn)).Area == LawnArea.Main;
    }

    public override function GetHighlight(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):HeldHighlight
    {
        return HeldHighlight.None;
    }

    public override function OnPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        // TODO-PORT: C# GetEntity(target, data) 重载在 Haxe 中重命名为 GetEntityOfTarget。
        var entity = GetEntityOfTarget(target, data);
        if (entity == null)
            return;
        if (PointerHelper.IsInvalidClickButton(pointerParams) || PointerHelper.IsInvalidReleaseAction(pointerParams))
            return;
        BreakoutBoard.FirePearl(entity);
    }
}
