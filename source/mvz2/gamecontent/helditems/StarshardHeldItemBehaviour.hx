// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Main/StarshardHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.models.VanillaModelID;
import mvz2.gamecontent.pickups.BlueprintPickup;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.Global;
import mvz2logic.blueprints.LogicSeedExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldTwinkleEntityBehaviour;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.starshard)
class StarshardHeldItemBehaviour extends ToEntityHeldItemBehaviour implements IHeldTwinkleEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function OnUpdate(level:LevelEngine, data:IHeldItemData):Void
    {
        super.OnUpdate(level, data);
        if (!IsValid(level, data))
        {
            LogicLevelExt.ResetHeldItem(level);
        }
    }
    public function IsValid(level:LevelEngine, data:IHeldItemData):Bool
    {
        return LogicLevelProps.GetStarshardCount(level) > 0 && LogicLevelProps.CanUseStarshard(level) && LogicLevelProps.GetStarshardHeldType(level) == data.Type;
    }
    public override function GetModelID(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
    {
        var modelID = VanillaModelID.GetStarshardHeldItem(level.AreaDefinition.GetID());
        var id = Global.Models.ModelExists(modelID) ? modelID : VanillaModelID.defaultStartShardHeldItem;
        result.SetFinalValue(id);
    }
    public override function CanUseOnEntity(entity:Entity):Bool
    {
        if (!entity.ExistsAndAlive())
            return false;
        if (entity.Type != EntityTypes.PLANT)
            return false;
        if (VanillaEntityProps.NoHeldTarget(entity))
            return false;
        return entity.GetFaction() == entity.Level.Option.LeftFaction && VanillaContraptionExt.CanEvoke(entity);
    }
    public override function UseOnEntity(entity:Entity):Void
    {
        LogicLevelProps.AddStarshardCount(entity.Level, -1);
        VanillaContraptionExt.Evoke(entity);
        entity.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_USE_STARSHARD, new EntityCallbackParams(entity), entity.GetDefinitionID());
    }
    public function ShouldMakeEntityTwinkle(entity:Entity, data:IHeldItemData):Bool
    {
        var seedDefinition = BlueprintPickup.GetSeedDefinition(entity);
        if (seedDefinition == null)
            return false;
        return LogicSeedExt.WillInstantEvoke(seedDefinition, entity.Level);
    }
}
