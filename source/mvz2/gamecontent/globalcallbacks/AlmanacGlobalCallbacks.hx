// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/AlmanacGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.vanilla.entities.WaterInteraction;
import mvz2.gamecontent.placements.VanillaPlacementID;
import mvz2.vanilla.almanac.VanillaAlmanacTagID;
import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.almanac.AlmanacEntryTagInfo;
import mvz2logic.almanac.LogicAlmanacCategories;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.modding.Mod;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityDefinition;
import pvzengine.entities.EntityTypes;
using mvz2logic.games.LogicGameDefinitionsExt;
import mvz2logic.entities.LogicContraptionProps;
import mvz2logic.blueprints.LogicSeedProps;
import pvzengine.armors.EngineArmorProps;
import mvz2.gamecontent.placements.VanillaPlacementProps;
import pvzengine.entities.EngineEntityProps;
import mvz2.vanilla.contraptions.VanillaContraptionProps;

@:modGlobalCallbacks
class AlmanacGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LogicCallbacks.GET_ALMANAC_ENTRY_TAGS, GetAlmanacEntryTagsCallback);
    }
    function GetAlmanacEntryTagsCallback(param:GetAlmanacEntryTagsParams, result:CallbackResult):Void
    {
        var category = param.category;
        var entryID = param.entryID;
        var entityID = param.sourceEntityID;
        var tags = param.tags;

        if (category == LogicAlmanacCategories.CONTRAPTIONS)
        {
            var def = Global.Game.GetEntityDefinition(entryID);
            if (def != null)
                GetContraptionEntryTags(def, tags);
        }
        else if (category == LogicAlmanacCategories.ENEMIES)
        {
            var def = Global.Game.GetEntityDefinition(entryID);
            if (def != null)
                GetEnemyEntryTags(def, tags);
        }
        else if (category == LogicAlmanacCategories.MISC)
        {
            GetMiscEntryTags(entryID, entityID, tags);
        }
    }
    function GetEntityAttributeTags(entityDef:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        var game = Global.Game;
        // 占位类。
        var takenGridLayers = LogicEntityProps.GetGridLayersToTakeOfDefinition(entityDef);
        if (takenGridLayers != null)
        {
            for (layer in takenGridLayers)
            {
                var layerDef = game.GetGridLayerDefinition(layer);
                if (layerDef != null && NamespaceID.IsValid(layerDef.AlmanacTag))
                {
                    tags.push(new AlmanacEntryTagInfo(layerDef.AlmanacTag));
                }
            }
        }
        // 发光
        if (LogicEntityProps.IsLightSourceOfDefinition(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.lightSource));
        }
        // 火焰
        if (VanillaEntityProps.IsFireOfDefinition(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.fire));
        }
        // 忠诚
        if (VanillaEntityProps.IsLoyalOfDefinition(entityDef) && Global.Saves.IsUnlocked(VanillaUnlockID.castle1))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.loyal));
        }
    }
    function GetShellAttributeTags(entityDef:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        var shell = EngineArmorProps.GetShellID(entityDef);
        if (shell == null)
            return;
        tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.shell, Std.string(shell)));
    }
    function GetEnemyShellAttributeTags(entityDef:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        var game = Global.Game;
        // 盔甲材质
        var startingArmor = VanillaEnemyProps.GetStartingArmorOfDefinition(entityDef);
        if (NamespaceID.IsValid(startingArmor))
        {
            var armorDef = game.GetArmorDefinition(startingArmor);
            var shellID = armorDef != null ? EngineArmorProps.GetShellID(armorDef) : null;
            if (NamespaceID.IsValid(shellID))
            {
                tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.shellArmor, Std.string(shellID)));
            }
        }
        // 护盾材质
        var startingShield = VanillaEnemyProps.GetStartingShieldOfDefinition(entityDef);
        if (NamespaceID.IsValid(startingShield))
        {
            var armorDef = game.GetArmorDefinition(startingShield);
            var shellID = armorDef != null ? EngineArmorProps.GetShellID(armorDef) : null;
            if (NamespaceID.IsValid(shellID))
            {
                tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.shellShield, Std.string(shellID)));
            }
        }
    }
    function GetMassAttributeTags(entityDef:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        var mass = VanillaEntityProps.GetMassOfDefinition(entityDef);
        tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.mass, Std.string(mass)));
    }
    function GetContraptionAttributeTags(entityDef:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        GetVulnerableAttributeTags(entityDef, tags);
        // 夜用
        if (LogicContraptionProps.IsNocturnalOfDefinition(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.nocturnal));
        }
        // 防御性
        if (VanillaContraptionProps.IsDefensiveOfDefinition(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.defensive));
        }
        // 地面器械
        if (VanillaContraptionProps.IsFloorOfDefinition(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.floorContraption));
        }
        // 高
        if (VanillaContraptionProps.BlocksJumpOfDefinition(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.tall));
        }
        // 可触发
        // PORT-NOTE: C# 的 entityDef.IsTriggerActive() 是 LogicContraptionProps 上针对 EntityDefinition 的扩展方法
        // （LogicSeedProps 的同名方法针对 SeedDefinition）；Haxe 无重载，故改名为 IsTriggerActiveOfDefinition。
        if (LogicContraptionProps.IsTriggerActiveOfDefinition(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.canTrigger));
        }
    }
    function GetEnemyAttributeTags(entityDef:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        GetVulnerableAttributeTags(entityDef, tags);
        // 低矮
        if (VanillaEnemyProps.IsLowEnemy(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.shortEnemy));
        }
        // 飞行
        if (VanillaEnemyProps.IsFlyingEnemy(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.flying));
        }
        // 非亡灵
        if (!VanillaEntityProps.IsUndeadOfDefinition(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.notUndead));
        }
        // 漂浮
        var waterInteraction = VanillaEntityProps.GetWaterInteractionOfDefinition(entityDef);
        if (waterInteraction == WaterInteraction.NONE || waterInteraction == WaterInteraction.FLOAT)
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.drownproof));
        }
    }
    function GetVulnerableAttributeTags(entityDef:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        // 控制免疫
        if (!VanillaEntityProps.CanDeactiveOfDefinition(entityDef))
        {
            tags.push(new AlmanacEntryTagInfo(VanillaAlmanacTagID.controlImmunity));
        }
    }
    function GetContraptionEntryTags(def:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        var game = Global.Game;

        // 放置类。
        var placement = EngineEntityProps.GetPlacementID(def);
        var placementDef = placement != null ? game.GetPlacementDefinition(placement) : null;
        if (placementDef != null)
        {
            var almanacTag = VanillaPlacementProps.GetAlmanacTag(placementDef);
            if (NamespaceID.IsValid(almanacTag))
            {
                tags.push(new AlmanacEntryTagInfo(almanacTag));
            }
        }

        // 特性类。
        GetEntityAttributeTags(def, tags);
        GetContraptionAttributeTags(def, tags);

        // 枚举类。
        GetShellAttributeTags(def, tags);
    }
    function GetEnemyEntryTags(def:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        // 特性类。
        GetEntityAttributeTags(def, tags);
        GetEnemyAttributeTags(def, tags);

        // 枚举类。
        GetShellAttributeTags(def, tags);
        GetEnemyShellAttributeTags(def, tags);
        GetMassAttributeTags(def, tags);
    }
    function GetObstacleEntryTags(def:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        // 特性类。
        GetEntityAttributeTags(def, tags);
        GetVulnerableAttributeTags(def, tags);

        // 枚举类。
        GetShellAttributeTags(def, tags);
    }
    function GetBossEntryTags(def:EntityDefinition, tags:Array<AlmanacEntryTagInfo>):Void
    {
        // 特性类。
        GetEntityAttributeTags(def, tags);
        GetVulnerableAttributeTags(def, tags);

        // 枚举类。
        GetShellAttributeTags(def, tags);
    }
    function GetMiscEntryTags(id:NamespaceID, entityID:Null<NamespaceID>, tags:Array<AlmanacEntryTagInfo>):Void
    {
        if (!NamespaceID.IsValid(entityID))
            return;

        var game = Global.Game;
        var def = game.GetEntityDefinition(entityID);
        if (def == null)
            return;

        if (def.Type == EntityTypes.PLANT)
        {
            GetContraptionEntryTags(def, tags);
        }
        else if (def.Type == EntityTypes.ENEMY)
        {
            GetEnemyEntryTags(def, tags);
        }
        else if (def.Type == EntityTypes.OBSTACLE)
        {
            GetObstacleEntryTags(def, tags);
        }
        else if (def.Type == EntityTypes.BOSS)
        {
            GetBossEntryTags(def, tags);
        }
        else
        {
            // 特性类。
            GetEntityAttributeTags(def, tags);

            // 枚举类。
            GetShellAttributeTags(def, tags);
        }
    }
}
