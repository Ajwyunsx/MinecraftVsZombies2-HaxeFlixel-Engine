// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/BlueprintRecommendGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.placements.VanillaPlacementID;
import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.Global;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicAreaTags;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.modding.Mod;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityDefinition;
import pvzengine.seedpacks.SeedDefinition;
using mvz2logic.games.LogicGameExt;
import mvz2logic.entities.LogicContraptionProps;
import pvzengine.level.EngineAreaProps;
import mvz2logic.level.LogicStageProps;
import pvzengine.entities.EngineEntityProps;
import mvz2.vanilla.contraptions.VanillaContraptionProps;

@:modGlobalCallbacks
class BlueprintRecommendGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LogicLevelCallbacks.GET_BLUEPRINT_NOT_RECOMMONDED, GetBlueprintNotRecommondedCallback);
        mod.AddTrigger(LogicLevelCallbacks.GET_BLUEPRINT_WARNINGS, GetBlueprintWarningsCallback);
    }

    function GetBlueprintNotRecommondedCallback(param:GetBlueprintNotRecommondedParams, callbackResult:CallbackResult):Void
    {
        var level = param.level;
        var blueprint = param.blueprintID;
        var content = level.Content;
        var blueprintDef = content.GetSeedDefinition(blueprint);
        if (blueprintDef == null)
            return;

        if (LogicSeedProps.GetSeedType(blueprintDef) == SeedTypes.ENTITY)
        {
            var entityID = LogicSeedProps.GetSeedEntityID(blueprintDef);
            if (entityID == null)
                return;
            var entityDef = content.GetEntityDefinition(entityID);
            if (entityDef == null)
                return;
            if (LogicLevelExt.IsDay(level))
            {
                // 白天的夜间器械
                if (LogicContraptionProps.IsNocturnalOfDefinition(entityDef))
                {
                    callbackResult.SetFinalValue(true);
                    return;
                }
            }
            // 白天的荧石
            if (entityID == VanillaContraptionID.glowstone)
            {
                if (LogicLevelExt.IsDay(level) && level.AreaID != VanillaAreaID.dream)
                {
                    callbackResult.SetFinalValue(true);
                    return;
                }
            }
            var areaTags = EngineAreaProps.GetAreaTags(level.AreaDefinition);
            if (areaTags != null)
            {
                if (LogicAreaTagsContains(areaTags, LogicAreaTags.noWater))
                {
                    // 无水地形的水生器械
                    if (EngineEntityProps.GetPlacementID(entityDef) == VanillaPlacementID.aquatic)
                    {
                        callbackResult.SetFinalValue(true);
                        return;
                    }
                }
            }
        }
    }
    function GetBlueprintWarningsCallback(param:GetBlueprintWarningsParams, callbackResult:CallbackResult):Void
    {
        var level = param.level;
        var chosenBlueprints = param.chosenBlueprints;
        var blueprintsForChoose = param.blueprintsForChoose;
        var results = param.warnings;

        var content = level.Content;
        // PORT-NOTE: C# LINQ Select/OfType/Where → Lambda 显式处理。
        var chosenBlueprintDefs:Array<SeedDefinition> = [];
        for (item in chosenBlueprints)
        {
            var def = level.Content.GetSeedDefinition(item.id);
            if (def != null)
                chosenBlueprintDefs.push(def);
        }
        var chosenBlueprintEntityDefs:Array<EntityDefinition> = [];
        for (def in chosenBlueprintDefs)
        {
            if (LogicSeedProps.GetSeedType(def) != SeedTypes.ENTITY)
                continue;
            var entID = LogicSeedProps.GetSeedEntityID(def);
            if (entID == null)
                continue;
            var entityDef = level.Content.GetEntityDefinition(entID);
            if (entityDef != null)
                chosenBlueprintEntityDefs.push(entityDef);
        }

        var entityDefsForChoose:Array<EntityDefinition> = [];
        for (id in blueprintsForChoose)
        {
            if (!NamespaceID.IsValid(id))
                continue;
            var blueprintDef = level.Content.GetSeedDefinition(id);
            if (blueprintDef == null)
                continue;
            if (LogicSeedProps.GetSeedType(blueprintDef) != SeedTypes.ENTITY)
                continue;
            var seedEntID = LogicSeedProps.GetSeedEntityID(blueprintDef);
            if (seedEntID == null)
                continue;
            var entityDef = level.Content.GetEntityDefinition(seedEntID);
            if (entityDef != null)
                entityDefsForChoose.push(entityDef);
        }

        // 升级
        // PORT-NOTE: C# 的 d.IsUpgradeBlueprint()（d 为 EntityDefinition）来自 LogicContraptionProps；
        // Haxe 无重载，针对 EntityDefinition 的版本改名为 IsUpgradeBlueprintOfDefinition。
        var upgradeBlueprints = Lambda.filter(chosenBlueprintEntityDefs, d -> LogicContraptionProps.IsUpgradeBlueprintOfDefinition(d));
        for (upgradeDef in upgradeBlueprints)
        {
            var neededBase = VanillaEntityProps.GetUpgradeFromEntity(upgradeDef);
            if (neededBase == null)
                continue;
            if (Lambda.exists(chosenBlueprints, b -> b.id == neededBase))
                continue;
            if (!Lambda.has(blueprintsForChoose, neededBase))
                continue;
            var baseName = Global.Game.GetEntityName(neededBase);
            var upgradeName = Global.Game.GetEntityName(upgradeDef.GetID());
            // PORT-NOTE: C# GetText(key, params object[] args) 的可变参数在 Haxe 侧收成单个数组。
            results.push(Global.Localization.GetText(WARNING_MISSING_UPGRADE_BASE, [baseName, upgradeName]));
        }
        // 攻击者
        var enemyPool = LogicStageProps.GetEnemyPool(level);
        var contraptionAttackers:Array<NamespaceID> = [];
        for (def in chosenBlueprintEntityDefs)
        {
            var tags = LogicContraptionProps.GetCounterTagsFor(def);
            if (tags == null)
                continue;
            for (t in tags)
            {
                if (!Lambda.has(contraptionAttackers, t))
                    contraptionAttackers.push(t);
            }
        }
        var missingTagsList:Array<NamespaceID> = [];
        if (enemyPool != null)
        {
            for (spawnID in enemyPool)
            {
                var spawnDef = level.Content.GetSpawnDefinition(spawnID);
                if (spawnDef == null)
                    continue;
                var tags = LogicSpawnProps_GetCounterTags(spawnDef, level);
                if (tags == null)
                    continue;
                for (tag in tags)
                {
                    if (Lambda.has(contraptionAttackers, tag))
                        continue;
                    if (Lambda.has(missingTagsList, tag))
                        continue;
                    missingTagsList.push(tag);
                    var counterName = Global.Game.GetEntityCounterName(tag);
                    results.push(Global.Localization.GetText(WARNING_MISSING_ATTACKER, [counterName]));
                }
            }
        }
        // 生产者
        if (!Lambda.exists(chosenBlueprintEntityDefs, e -> VanillaContraptionProps.IsProducer(e)) && Lambda.exists(entityDefsForChoose, e -> VanillaContraptionProps.IsProducer(e)))
        {
            results.push(Global.Localization.GetText(WARNING_MISSING_PRODUCER));
        }
        // 水生器械
        var areaTags = EngineAreaProps.GetAreaTags(level.AreaDefinition);
        if (areaTags != null && LogicAreaTagsContains(areaTags, LogicAreaTags.water))
        {
            if (!Lambda.exists(chosenBlueprintEntityDefs, e -> EngineEntityProps.GetPlacementID(e) == VanillaPlacementID.aquatic) && Lambda.exists(entityDefsForChoose, e -> EngineEntityProps.GetPlacementID(e) == VanillaPlacementID.aquatic))
            {
                results.push(Global.Localization.GetText(WARNING_MISSING_AQUATIC));
            }
        }

    }
    // PORT-NOTE: C# HashSet<NamespaceID>.Contains → Array.has 包装。
    // PORT-NOTE: C# 里 areaTags 是 IEnumerable<NamespaceID>（EngineAreaProps.GetAreaTags 返回 Array<NamespaceID>），
    // 不应写成 Array<String>；Haxe 的 NamespaceID 是 abstract，不能与 String 混用。
    static function LogicAreaTagsContains(tags:Array<NamespaceID>, tag:NamespaceID):Bool
    {
        return Lambda.has(tags, tag);
    }
    // TODO-PORT: LogicSpawnProps.GetCounterTags(spawnDef, level) 为 MVZ2Logic.Spawns 扩展方法（由 mvz2logic 工作包提供）。
    static function LogicSpawnProps_GetCounterTags(spawnDef:Dynamic, level:Dynamic):Array<NamespaceID>
    {
        return null;
    }
    // [TranslateMsg("选卡警告，{0}为原器械，{1}为升级器械")]
    public static inline var WARNING_MISSING_UPGRADE_BASE:String = "你确定想要在没有{0}的情况下使用{1}？";
    // [TranslateMsg("选卡警告，{0}为目标敌人")]
    public static inline var WARNING_MISSING_ATTACKER:String = "你没有选能干掉{0}的器械，确定要继续吗？";
    // [TranslateMsg("选卡警告")]
    public static inline var WARNING_MISSING_PRODUCER:String = "你没有选能生产能量的器械，确定要继续吗？";
    // [TranslateMsg("选卡警告")]
    public static inline var WARNING_MISSING_AQUATIC:String = "你确定这关不使用任何水生器械吗？";
}
