// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Entity/DigEnemyHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicContraptionProps;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemTargetEntity;
import mvz2logic.helditems.HeldTargetFlag;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.digEnemy)
class DigEnemyHeldItemBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
    {
        return HeldTargetFlag.Enemy;
    }
    public override function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointerInteraction:PointerInteractionData):Bool
    {
        var pointer = pointerInteraction.pointer;
        if (Std.isOfType(target, HeldItemTargetEntity))
        {
            var entityTarget = cast(target, HeldItemTargetEntity);
            return CanUseOnEntity(entityTarget.Target);
        }
        return false;
    }
    public override function GetHighlight(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):HeldHighlight
    {
        if (Std.isOfType(target, HeldItemTargetEntity))
        {
            var entityTarget = cast(target, HeldItemTargetEntity);
            var entity = entityTarget.Target;
            return HeldHighlight.Entity(entity);
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
            var entityTarget = cast(target, HeldItemTargetEntity);
            OnPointerEventEntity(entityTarget, data, pointerParams);
        }
    }
    private function OnPointerEventEntity(target:HeldItemTargetEntity, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (PointerHelper.IsInvalidReleaseAction(pointerParams))
            return;
        var entity = target.Target;
        LogicLevelExt.ResetHeldItem(entity.Level);
        UseOnEntity(entity);
    }
    private function CanUseOnEntity(entity:Entity):Bool
    {
        if (!entity.ExistsAndAlive() || VanillaEntityProps.NoHeldTarget(entity) || LogicContraptionProps.CannotDig(entity))
            return false;
        return entity.Type == EntityTypes.ENEMY && LogicEntityProps.CanBeKilledByPickaxe(entity);
    }
    private function UseOnEntity(entity:Entity):Void
    {
        var effects = new DamageEffectList(VanillaDamageEffects.PICKAXE);
        entity.Die(effects);
        if (LogicLevelProps.IsPickaxeCountLimited(entity.Level))
        {
            LogicLevelProps.AddPickaxeRemainCount(entity.Level, -1);
        }
    }
}
