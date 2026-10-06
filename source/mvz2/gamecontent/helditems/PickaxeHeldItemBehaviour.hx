// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Main/PickaxeHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicContraptionProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.helditems.HeldTargetFlag;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.level.LogicLevelProps;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.pickaxe)
class PickaxeHeldItemBehaviour extends ToEntityHeldItemBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
    {
        return HeldTargetFlag.Plant | HeldTargetFlag.Obstacle;
    }
    public override function CanUseOnEntity(entity:Entity):Bool
    {
        if (!entity.ExistsAndAlive() || VanillaEntityProps.NoHeldTarget(entity) || LogicContraptionProps.CannotDig(entity))
            return false;
        if (entity.Type != EntityTypes.PLANT && entity.Type != EntityTypes.OBSTACLE)
            return false;
        return LogicEntityExt.IsFriendlyEntity(entity) || LogicEntityProps.CanBeKilledByPickaxe(entity);
    }
    public override function UseOnEntity(entity:Entity):Void
    {
        var effects = new DamageEffectList(VanillaDamageEffects.PICKAXE);
        entity.Die(effects);
        if (LogicLevelProps.IsPickaxeCountLimited(entity.Level))
        {
            LogicLevelProps.AddPickaxeRemainCount(entity.Level, -1);
        }
    }
    public override function GetModelID(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
    {
        result.SetFinalValue(VanillaModelID.pickaxeHeldItem);
    }
}
