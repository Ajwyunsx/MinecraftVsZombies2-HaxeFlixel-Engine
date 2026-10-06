// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Main/SwordHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.buffs.level.SwordParalyzedBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemTargetEntity;
import mvz2logic.helditems.HeldItemTargetLawn;
import mvz2logic.helditems.HeldTargetFlag;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.level.LogicLevelExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.sword)
class SwordHeldItemBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetModelID(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
    {
        result.SetFinalValue(VanillaModelID.swordHeldItem);
    }
    public override function GetRadius(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
    {
        result.SetFinalValue(16);
    }
    public override function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
    {
        return HeldTargetFlag.Enemy;
    }
    public override function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):Bool
    {
        if (Std.isOfType(target, HeldItemTargetLawn))
            return true;
        if (Std.isOfType(target, HeldItemTargetEntity))
        {
            var entityTarget = cast(target, HeldItemTargetEntity);
            var entity = entityTarget.Target;
            if (entity.Type == EntityTypes.ENEMY)
            {
                return LogicEntityExt.IsHostileEntity(entity) || entity.IsEntityOf(VanillaEnemyID.napstablook);
            }
            return false;
        }

        return false;
    }
    public override function OnUpdate(level:LevelEngine, data:IHeldItemData):Void
    {
        super.OnUpdate(level, data);
        var modelInterface = LogicLevelExt.GetHeldItemModelInterface(level);
        if (modelInterface != null)
        {
            modelInterface.SetAnimationBool("Paralyzed", level.HasBuff(SwordParalyzedBuff));
        }
    }
    public override function OnPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        super.OnPointerEvent(target, data, pointerParams);
        if (PointerHelper.IsInvalidClickButton(pointerParams))
            return;
        OnMainPointerEvent(target, data, pointerParams);
        PointerDown(target, data, pointerParams);
    }
    private function OnMainPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (Std.isOfType(target, HeldItemTargetEntity))
        {
            OnPointerEventEntity(cast(target, HeldItemTargetEntity), data, pointerParams);
        }
    }
    private function OnPointerEventEntity(target:HeldItemTargetEntity, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        var entity = target.Target;

        switch (entity.Type)
        {
            case EntityTypes.ENEMY:
                if (pointerParams.interaction == PointerInteraction.Down)
                {
                    if (IsParalyzed(entity.Level))
                        return;
                    var effects = new DamageEffectList([VanillaDamageEffects.WHACK, VanillaDamageEffects.REMOVE_ON_DEATH, VanillaDamageEffects.NO_DEATH_EFFECTS]);
                    VanillaEntityExt.TakeDamageNoSource(entity, 750, effects);
                    if (entity.IsDead)
                    {
                        var screenPos = Global.Input.GetPointerScreenPosition();
                        var pos = LogicLevelExt.ScreenToLawnPositionByZ(entity.Level, screenPos, entity.Position.z);
                        entity.Level.Spawn(VanillaEffectID.pow, pos, null);
                    }
                }
        }
    }
    private function PointerDown(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        if (pointerParams.interaction == PointerInteraction.Down)
        {
            Swing(target.GetLevel());
        }
    }
    public static function Paralyze(level:LevelEngine):Void
    {
        var buff = level.AddBuff(SwordParalyzedBuff);
        var timeout = VanillaDifficultyLevelProps.GetNapstablookParalysisTime(level);
        buff.SetProperty(SwordParalyzedBuff.PROP_TIMEOUT, timeout);
        LogicLevelExt.PlaySound(level, VanillaSoundID.shock);
    }
    public static function IsParalyzed(level:LevelEngine):Bool
    {
        return level.HasBuff(SwordParalyzedBuff);
    }
    private function Swing(level:LevelEngine):Void
    {
        if (IsParalyzed(level))
            return;
        var modelInterface = LogicLevelExt.GetHeldItemModelInterface(level);
        if (modelInterface != null)
        {
            modelInterface.TriggerAnimation("Swing");
        }
        LogicLevelExt.PlaySound(level, VanillaSoundID.swing);
    }
}
