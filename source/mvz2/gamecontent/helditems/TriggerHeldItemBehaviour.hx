// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Main/TriggerHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.models.VanillaModelID;
import mvz2.gamecontent.pickups.BlueprintPickup;
import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.blueprints.LogicSeedExt;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldTwinkleEntityBehaviour;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.trigger)
class TriggerHeldItemBehaviour extends ToEntityHeldItemBehaviour implements IHeldTwinkleEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanUseOnEntity(entity:Entity):Bool
    {
        if (!entity.ExistsAndAlive())
            return false;
        if (entity.Type != EntityTypes.PLANT)
            return false;
        if (VanillaEntityProps.NoHeldTarget(entity))
            return false;
        return entity.GetFaction() == entity.Level.Option.LeftFaction && VanillaContraptionExt.CanTrigger(entity);
    }
    public override function UseOnEntity(entity:Entity):Void
    {
        VanillaContraptionExt.Trigger(entity);
    }

    public override function GetModelID(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
    {
        result.SetFinalValue(VanillaModelID.triggerHeldItem);
    }

    public function ShouldMakeEntityTwinkle(entity:Entity, data:IHeldItemData):Bool
    {
        if (VanillaContraptionExt.CanTrigger(entity))
            return true;
        var seedDefinition = BlueprintPickup.GetSeedDefinition(entity);
        return seedDefinition != null && LogicSeedProps.IsTriggerActive(seedDefinition) && LogicSeedProps.CanInstantTrigger(seedDefinition);
    }
}
