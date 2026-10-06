// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/RightMouseCancelHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.Global;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.callbacks.LogicCallbacks.PostPointerActionParams;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.LogicHeldItemExt;
import mvz2logic.inputs.MouseButtons;
import mvz2logic.inputs.PointerPhase;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.level.LogicLevelExt;
import pvzengine.callbacks.CallbackResult;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.rightMouseCancel)
class RightMouseCancelHeldItemBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        // C#: AddTrigger(LogicCallbacks.POST_POINTER_ACTION, PostPointerActionCallback, filter: PointerPhase.Press);
        AddTrigger(LogicCallbacks.POST_POINTER_ACTION, PostPointerActionCallback, 0, PointerPhase.Press);
    }
    private function PostPointerActionCallback(param:PostPointerActionParams, result:CallbackResult):Void
    {
        var type = param.type;
        var button = param.button;
        if (type != PointerTypes.MOUSE || button != MouseButtons.RIGHT)
            return;
        var level = Global.Level.GetLevel();
        if (level == null || !LogicLevelExt.IsGameRunning(level))
            return;
        var data = LogicLevelExt.GetHeldItemData(level);
        var heldItemDef = data != null ? LogicHeldItemExt.GetDefinition(data, level) : null;
        if (data == null || heldItemDef == null)
            return;
        if (!heldItemDef.HasBehaviour(level, data, this))
            return;
        if (LogicLevelExt.CancelHeldItem(level))
        {
            LogicLevelExt.PlaySound(level, VanillaSoundID.tap);
        }
    }
}
