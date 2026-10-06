// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/BlueprintGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.blueprints.LogicBlueprintStyles;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.level.LogicHeldItemProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.modding.Mod;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.seedpacks.EngineSeedProps;

@:modGlobalCallbacks
class BlueprintGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LogicLevelCallbacks.POST_USE_ENTITY_BLUEPRINT, PostUseEntityBlueprintCallback);
        mod.AddTrigger(LogicCallbacks.GET_BLUEPRINT_STYLE, GetBlueprintStyleCallback);
    }
    function PostUseEntityBlueprintCallback(param:PostUseEntityBlueprintParams, callbackResult:CallbackResult):Void
    {
        var output = param.placeOutput;
        var entity = output.entity;
        var seed = param.blueprint;
        var definition = param.definition;
        var heldData = param.heldData;
        if (entity == null)
            return;
        if (LogicHeldItemProps.IsInstantTrigger(heldData) && VanillaContraptionExt.CanTrigger(entity))
        {
            VanillaContraptionExt.Trigger(entity);
        }
        if (LogicHeldItemProps.IsInstantEvoke(heldData) && VanillaContraptionExt.CanEvoke(entity) && LogicLevelProps.GetStarshardCount(entity.Level) > 0 && !LogicLevelProps.IsStarshardDisabled(entity.Level))
        {
            LogicLevelProps.AddStarshardCount(entity.Level, -1);
            VanillaContraptionExt.Evoke(entity);
            entity.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_USE_STARSHARD, new EntityCallbackParams(entity), entity.GetDefinitionID());
        }
        if (seed != null)
        {
            var drawnFromPool = EngineSeedProps.GetDrawnConveyorSeed(seed);
            if (NamespaceID.IsValid(drawnFromPool))
            {
                if (output.increaseTakenConveyorSeed)
                {
                    // PORT-NOTE: C# 的 entity.AddTakenConveyorSeed(id) 是 Entity 的实例方法（非 LogicSeedProps 扩展）。
                    entity.AddTakenConveyorSeed(drawnFromPool);
                }
                else
                {
                    // PORT-NOTE: C# 的 Level.PutSeedToConveyorDiscardPile(seedID, value = 1) 是 LevelEngine 的实例方法。
                    entity.Level.PutSeedToConveyorDiscardPile(drawnFromPool);
                }
            }
            EngineSeedProps.SetDrawnConveyorSeed(seed, null);
        }
    }
    function GetBlueprintStyleCallback(param:GetBlueprintStyleParams, result:CallbackResult):Void
    {
        var definition = param.blueprintDefinition;
        var seedID = definition.GetID();
        if (seedID == LogicBlueprintID.FromEntity(VanillaContraptionID.commandBlock) || param.isCommandBlock)
        {
            result.SetValue(LogicBlueprintStyles.commandBlock);
        }
        else if (LogicSeedProps.IsUpgradeBlueprint(definition))
        {
            result.SetValue(LogicBlueprintStyles.upgrade);
        }
    }
}
