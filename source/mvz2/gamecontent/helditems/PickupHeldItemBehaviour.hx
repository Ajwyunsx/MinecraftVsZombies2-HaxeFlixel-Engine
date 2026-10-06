// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/PickupHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemTargetEntity;
import mvz2logic.helditems.HeldTargetFlag;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.pickup)
class PickupHeldItemBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
    {
        return HeldTargetFlag.Pickup;
    }
    public override function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Bool
    {
        if (!Std.isOfType(target, HeldItemTargetEntity))
            return false;
        var entityTarget = cast(target, HeldItemTargetEntity);
        if (PointerHelper.IsInvalidClickButton(pointerParams))
            return false;
        var entity = entityTarget.Target;
        var level = entity.Level;
        switch (entity.Type)
        {
            case EntityTypes.PICKUP:
                return !VanillaPickupExt.IsCollected(entity) && !LogicLevelExt.IsHoldingEntity(level, entity) && !VanillaPickupProps.NoCollect(entity);
        }
        return false;
    }
    public override function OnPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (!Std.isOfType(target, HeldItemTargetEntity))
            return;
        var entityTarget = cast(target, HeldItemTargetEntity);
        OnMainPointerEvent(entityTarget, data, pointerParams);
    }
    private function OnMainPointerEvent(entityTarget:HeldItemTargetEntity, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        var interaction = pointerParams.interaction;
        var entity = entityTarget.Target;
        switch (entity.Type)
        {
            case EntityTypes.PICKUP:
                var interacted = interaction == PointerInteraction.Down || interaction == PointerInteraction.Hold || interaction == PointerInteraction.Streak;
                if (interacted)
                {
                    if (VanillaPickupExt.CanCollect(entity))
                    {
                        VanillaPickupExt.Collect(entity);
                    }
                    else
                    {
                        if (!LogicLevelExt.IsPlayingSound(entity.Level, VanillaSoundID.buzzer))
                        {
                            LogicEntityExt.PlaySound(entity, VanillaSoundID.buzzer);
                        }
                    }
                }
        }
    }
}
