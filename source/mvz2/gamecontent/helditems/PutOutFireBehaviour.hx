// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/PutOutFireBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemTargetEntity;
import mvz2logic.helditems.HeldTargetFlag;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.inputs.PointerInteractionData;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.putOutFire)
class PutOutFireBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
    {
        return HeldTargetFlag.Effect;
    }
    public override function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):Bool
    {
        if (!Std.isOfType(target, HeldItemTargetEntity))
            return false;

        var entityTarget = cast(target, HeldItemTargetEntity);
        var entity = entityTarget.Target;
        switch (entity.Type)
        {
            case EntityTypes.EFFECT:
                return entity.IsEntityOf(VanillaEffectID.gridFire);
        }
        return false;
    }
    public override function GetHighlight(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):HeldHighlight
    {
        if (!Std.isOfType(target, HeldItemTargetEntity))
            return HeldHighlight.None;

        var entityTarget = cast(target, HeldItemTargetEntity);
        var entity = entityTarget.Target;
        switch (entity.Type)
        {
            case EntityTypes.EFFECT:
                return HeldHighlight.Entity(entity);
        }
        return HeldHighlight.None;
    }
    public override function OnPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (!Std.isOfType(target, HeldItemTargetEntity))
            return;
        var entityTarget = cast(target, HeldItemTargetEntity);
        if (PointerHelper.IsInvalidClickButton(pointerParams))
            return;
        var interaction = pointerParams.interaction;
        var entity = entityTarget.Target;
        switch (entity.Type)
        {
            case EntityTypes.EFFECT:
                if (interaction == PointerInteraction.Down)
                {
                    LogicEntityExt.PlaySound(entity, VanillaSoundID.fizz);
                    entity.Remove();
                }
        }
    }
}
