// Ported from: Assets/Scripts/MVZ2/Almanac/AlmanacController.cs
package mvz2.almanacs;

import mvz2.almanacs.AlmanacManager;
import mvz2.almanacs.DescriptionPropReplacer;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.managers.MainManager;
import mvz2.metas.AlmanacTagMeta;
import mvz2.metas.AlmanacVariableContext;
import mvz2.metas.ModelMeta;
import mvz2.models.ModelBuilder;
import mvz2.scenes.MainScenePage;
import mvz2.talk.CharacterPortrait;
import mvz2.ui.SimpleTooltipSource;
import mvz2.ui.Tooltip;
import mvz2.ui.almanac.AlmanacDescriptionTag;
import mvz2.ui.almanac.AlmanacTagIcon;
import mvz2.ui.almanac.AlmanacTagIconLayer;
import mvz2.ui.almanac.AlmanacUI;
// PORT-NOTE: C# `MVZ2.UI.Almanac.IndexAlmanacPage.ButtonType`；此前被误写为 arcade 的 IndexArcadePage.ButtonType。
import mvz2.ui.almanac.IndexAlmanacPage.ButtonType;
import mvz2logic.Global;
import mvz2logic.ParseHelper;
import mvz2logic.almanac.AlmanacEntryTagInfo;
import mvz2logic.almanac.LogicAlmanacCategories;
import mvz2logic.audios.LogicMusicID;
import mvz2logic.audios.LogicSoundID;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.definitions.LogicDefinitionTypes;
import mvz2logic.localization.LogicStrings;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import pvzengine.definitions.EngineDefinitionTypes;
import unity.Camera;
import unity.Color;
import unity.Sprite;
import unity.UnityObject;
import unity.Vector2;
import unity.eventsystems.PointerEventData;
import mvz2.ui.almanac.IndexAlmanacPage;
import mvz2logic.inputs.InputHelper;
import mvz2.inputs.InputManager;
import mvz2.localization.LanguageManager;
import mvz2logic.saves.LogicSaveExt;
import mvz2.saves.MVZ2SaveExt;
import Main;
import mvz2.audios.MusicManager;
import mvz2logic.inputs.PointerTypes;
import mvz2.managers.ResourceManager;
import mvz2.saves.SaveManager;
import mvz2.audios.SoundManager;
import mvz2.managers.TalkManager;
import mvz2.almanacs.AlmanacManager.AlmanacEntryGroup;
import mvz2.ui.Tooltip.TooltipContent;
import mvz2.ui.almanac.AlmanacDescriptionTag.AlmanacDescriptionTagViewData;
import mvz2.ui.almanac.AlmanacTagIcon.AlmanacTagIconViewData;
import mvz2.ui.almanac.AlmanacTagIconLayer.AlmanacTagIconLayerViewData;
import mvz2.ui.almanac.AlmanacUI.AlmanacPageType;
import mvz2logic.callbacks.LogicCallbacks.GetAlmanacEntryTagsParams;
import unity.scenemanagement.SceneInstance.Scene;

using mvz2.saves.MVZ2SaveExt;
using mvz2logic.inputs.InputHelper;
using mvz2logic.saves.LogicSaveExt;
// PORT-NOTE: C# 中 GetCost/GetRechargeID/GetArtifactDefinition 是扩展方法，Haxe 侧用 `using` 还原。
using mvz2logic.entities.LogicEntityProps;
using mvz2logic.games.LogicGameDefinitionsExt;
using mvz2logic.artifacts.LogicArtifactProps;

class AlmanacController extends MainScenePage {
    override public function Display():Void {
        super.Display();
        ui.DisplayPage(AlmanacPageType.Index);
        UpdateEntries();
        if (!Main.MusicManager.IsPlaying(LogicMusicID.choosing))
            Main.MusicManager.Play(LogicMusicID.choosing);
    }
    public function OpenEnemyAlmanac(id:NamespaceID):Void {
        ui.DisplayPage(AlmanacPageType.Enemies);
        if (enemyEntries.contains(id)) {
            SetActiveEnemyEntry(id);
        } else {
            SetActiveEnemyEntry(enemyEntries.length > 0 ? enemyEntries[0] : null);
        }
    }
    private function Awake():Void {
        propReplacer = new DescriptionPropReplacer(Main);
        ui.OnReturnClick.add(OnReturnClickCallback);

        ui.OnIndexButtonClick.add(OnIndexButtonClickCallback);

        ui.OnCommandBlockClick.add(OnCommandBlockClickCallback);

        ui.OnContraptionEntryClick.add(OnContraptionEntryClickCallback);
        ui.OnMiscEntryClick.add(OnMiscEntryClickCallback);
        ui.OnGroupEntryClick.add(OnGroupEntryClickCallback);
        ui.OnZoomClick.add(OnZoomClickCallback);

        ui.OnDescriptionIconEnter.add(OnDescriptionIconEnterCallback);
        ui.OnDescriptionIconExit.add(OnDescriptionIconExitCallback);
        ui.OnDescriptionIconDown.add(OnDescriptionIconDownCallback);
        ui.OnDescriptionLinkClick.add(OnDescriptionLinkClickCallback);
        ui.OnTagIconEnter.add(OnTagIconEnterCallback);
        ui.OnTagIconExit.add(OnTagIconExitCallback);
        ui.OnTagIconDown.add(OnTagIconDownCallback);

        ui.OnZoomReturnClick.add(OnZoomReturnClickCallback);
        ui.OnZoomPageButtonClick.add(OnZoomPageButtonClickCallback);
    }
    private function OnReturnClickCallback(page:Bool):Void {
        UnlockAndHideTooltip();
        if (page) {
            ui.DisplayPage(AlmanacPageType.Index);
        } else {
            Return();
        }
    }
    private function OnIndexButtonClickCallback(button:ButtonType):Void {
        switch (button) {
            case ButtonType.ViewContraption:
                ViewContraptions();
            case ButtonType.ViewEnemy:
                ViewEnemies();
            case ButtonType.ViewArtifact:
                ViewArtifacts();
            case ButtonType.ViewMisc:
                ViewMisc();
            case _:
        }
    }
    private function OnCommandBlockClickCallback(eventData:PointerEventData):Void {
        if (eventData.IsMouseButNotLeft())
            return;
        SetActiveContraptionEntry(VanillaContraptionID.commandBlock);
        Main.SoundManager.Play2D(LogicSoundID.tap);
    }
    private function OnContraptionEntryClickCallback(index:Int, data:PointerEventData):Void {
        if (data.IsMouseButNotLeft())
            return;
        SetActiveContraptionEntry(contraptionEntries[index]);
        Main.SoundManager.Play2D(LogicSoundID.tap);
    }
    private function OnMiscEntryClickCallback(page:AlmanacPageType, index:Int):Void {
        switch (page) {
            case AlmanacPageType.Enemies:
                SetActiveEnemyEntry(enemyEntries[index]);
            case AlmanacPageType.Artifacts:
                SetActiveArtifactEntry(artifactEntries[index]);
            case _:
        }
        Main.SoundManager.Play2D(LogicSoundID.tap);
    }
    private function OnGroupEntryClickCallback(page:AlmanacPageType, groupIndex:Int, entryIndex:Int):Void {
        switch (page) {
            case AlmanacPageType.Miscs:
                var group = miscGroups[groupIndex];
                var entry = group.entries[entryIndex];
                if (entry != null) {
                    SetActiveMiscEntry(entry);
                }
            case _:
        }
        Main.SoundManager.Play2D(LogicSoundID.tap);
    }
    // #region 缩放
    private function OnZoomClickCallback(page:AlmanacPageType):Void {
        if (page != AlmanacPageType.Miscs)
            return;
        var entry = Main.ResourceManager.GetAlmanacMetaEntry(LogicAlmanacCategories.MISC, activeMiscEntryID);

        var picture = entry != null ? entry.picture : null;
        var characterID = picture != null ? picture.character : null;
        if (NamespaceID.IsValid(characterID)) {
            ShowCharacterZoom(characterID);
        } else {
            var sprite:Sprite = null;
            if (entry != null) {
                sprite = Main.AlmanacManager.GetEntryPictureSprite(entry);
            }
            if (UnityObject.exists(sprite)) {
                ShowSpriteZoom(sprite, false);
            }
        }
        Main.SoundManager.Play2D(LogicSoundID.tap);
    }
    private function OnZoomReturnClickCallback():Void {
        StopZoom();
    }
    private function OnZoomPageButtonClickCallback(next:Bool):Void {
        if (zoomPortrait == null)
            return;
        var entry = Main.ResourceManager.GetAlmanacMetaEntry(LogicAlmanacCategories.MISC, activeMiscEntryID);
        var picture = entry != null ? entry.picture : null;
        if (picture == null)
            return;
        var characterID = picture.character;
        var characterMeta = Main.ResourceManager.GetCharacterMeta(characterID);
        var offset = next ? 1 : -1;
        if (characterMeta != null) {
            var variants = characterMeta.variants;
            if (variants.length <= 0)
                return;
            var cycleCount = 0;
            do {
                zoomIndex = cycleOffset(zoomIndex, offset, variants.length);
                var variant = variants[zoomIndex];
                if (variant.unlock.IsNullOrMeetsConditions(Main.SaveManager)) {
                    var viewData = Main.TalkManager.GetPortraitViewData(variant);
                    zoomPortrait.ChangeVariant(viewData);
                    ui.SetZoomSprite(zoomPortrait.GetSprite());
                    break;
                }
                cycleCount++;
            } while (cycleCount < variants.length);
        }
    }
    // #endregion

    // #region 描述图标
    private function OnTagIconEnterCallback(page:AlmanacPageType, index:Int):Void {
        if (tagTooltipLockedTarget == index)
            return;
        var icon = ui.GetTagIcon(page, index);
        if (!UnityObject.exists(icon))
            return;
        var tagInfo = GetEntryTagIconInfo(index);
        var viewData = GetTagTooltipViewData(tagInfo.tagID, tagInfo.enumValue);
        Main.Scene.ShowTooltip(new SimpleTooltipSource(almanacCamera, icon, viewData));
        Main.Scene.UpdateTooltip();
        UnlockTooltip();
    }
    private function OnTagIconExitCallback(page:AlmanacPageType, index:Int):Void {
        if (tagTooltipLockedTarget >= 0)
            return;
        Main.Scene.HideTooltip();
    }
    private function OnTagIconDownCallback(page:AlmanacPageType, index:Int):Void {
        if (Main.InputManager.GetActivePointerType() != PointerTypes.TOUCH)
            return;
        LockTooltipEntryTag(tagTooltipLockedTarget == index ? -1 : index);
        Main.SoundManager.Play2D(LogicSoundID.tap);
    }
    private function OnDescriptionIconEnterCallback(page:AlmanacPageType, linkID:String):Void {
        if (descriptionTagTooltipLockedTarget == linkID)
            return;
        var parsed = TryParseTagLinkID(linkID);
        if (parsed == null)
            return;
        var icon = ui.GetDescriptionIcon(page, parsed.index);
        if (!UnityObject.exists(icon))
            return;
        var viewData = GetTagTooltipViewData(parsed.tagID, parsed.enumValue);
        Main.Scene.ShowTooltip(new SimpleTooltipSource(almanacCamera, icon, viewData));
        Main.Scene.UpdateTooltip();
        UnlockTooltip();
    }
    private function OnDescriptionIconExitCallback(page:AlmanacPageType, linkID:String):Void {
        if (descriptionTagTooltipLockedTarget != null && descriptionTagTooltipLockedTarget.length > 0)
            return;
        Main.Scene.HideTooltip();
    }
    private function OnDescriptionIconDownCallback(page:AlmanacPageType, linkID:String):Void {
        if (Main.InputManager.GetActivePointerType() != PointerTypes.TOUCH)
            return;
        if (descriptionTagTooltipLockedTarget == linkID) {
            UnlockTooltip();
        } else {
            LockTooltipDescription(linkID);
        }
        Main.SoundManager.Play2D(LogicSoundID.tap);
    }
    private function OnDescriptionLinkClickCallback(page:AlmanacPageType, linkID:String):Void {
        Main.SoundManager.Play2D(LogicSoundID.tap);
        var parsed = TryParseDescriptionLinkID(linkID);
        if (parsed == null)
            return;
        if (!ValidateDescriptionLink(parsed.type, parsed.pageID))
            return;
        switch (parsed.type) {
            case HYPERLINK_TYPE_CONTRAPTIONS:
                ViewContraptions();
                SetActiveContraptionEntry(parsed.pageID);
            case HYPERLINK_TYPE_ENEMIES:
                ViewEnemies();
                SetActiveEnemyEntry(parsed.pageID);
            case HYPERLINK_TYPE_ARTIFACTS:
                ViewArtifacts();
                SetActiveArtifactEntry(parsed.pageID);
            case HYPERLINK_TYPE_MISC:
                ViewMisc();
                SetActiveMiscEntry(parsed.pageID);
        }
    }
    // #endregion

    // #region 查看某分类
    private function UpdateEntries():Void {
        contraptionEntries = [];
        Main.AlmanacManager.GetContraptionPageEntries(contraptionEntries);

        enemyEntries = [];
        Main.AlmanacManager.GetEnemyPageEntries(enemyEntries);

        artifactEntries = [];
        Main.AlmanacManager.GetArtifactPageEntries(artifactEntries);

        miscGroups = [];
        Main.AlmanacManager.GetMiscPageGroups(miscGroups);


        var contraptionViewDatas = Lambda.array(Lambda.map(contraptionEntries, c -> Main.AlmanacManager.GetChoosingBlueprintViewData(c, false)));
        var commandBlock = Main.SaveManager.IsCommandBlockUnlocked();
        var commandBlockViewData = Main.AlmanacManager.GetChoosingBlueprintViewData(VanillaContraptionID.commandBlock, false);
        ui.SetContraptionEntries(contraptionViewDatas, commandBlock, commandBlockViewData);

        var enemyViewDatas = Lambda.array(Lambda.map(enemyEntries, c -> Main.AlmanacManager.GetEnemyEntryViewData(c)));
        ui.SetEnemyEntries(enemyViewDatas);

        var artifactViewDatas = Lambda.array(Lambda.map(artifactEntries, c -> Main.AlmanacManager.GetArtifactEntryViewData(c)));
        ui.SetArtifactEntries(artifactViewDatas);
        ui.SetIndexArtifactVisible(artifactEntries.length > 0);

        var miscViewDatas = Lambda.array(Lambda.map(miscGroups, c -> Main.AlmanacManager.GetMiscGroupViewData(c)));
        ui.SetMiscGroups(miscViewDatas);
    }
    private function ViewContraptions():Void {
        var page = Main.UseMobileLayout() ? AlmanacPageType.ContraptionsMobile : AlmanacPageType.ContraptionsStandalone;
        ui.DisplayPage(page);
        SetActiveContraptionEntry(Lambda.find(contraptionEntries, e -> e != null));
    }
    private function ViewEnemies():Void {
        ui.DisplayPage(AlmanacPageType.Enemies);
        SetActiveEnemyEntry(Lambda.find(enemyEntries, e -> e != null));
    }
    private function ViewArtifacts():Void {
        ui.DisplayPage(AlmanacPageType.Artifacts);
        SetActiveArtifactEntry(Lambda.find(artifactEntries, e -> e != null));
    }
    private function ViewMisc():Void {
        ui.DisplayPage(AlmanacPageType.Miscs);
        var firstGroup = miscGroups.length > 0 ? miscGroups[0] : null;
        var entries = firstGroup != null ? firstGroup.entries : null;
        var entry = entries != null ? Lambda.find(entries, e -> e != null) : null;
        if (entry != null)
            SetActiveMiscEntry(entry);
    }
    // #endregion

    // #region 设置当前查看内容
    private function SetActiveContraptionEntry(contraptionID:NamespaceID):Void {
        if (!NamespaceID.IsValid(contraptionID))
            return;
        var type = LogicAlmanacCategories.CONTRAPTIONS;

        var infos = GetEntityAlmanacInfos(contraptionID, type);
        var model = infos.model;
        var name = infos.name;
        var description = infos.description;
        var entry = Main.ResourceManager.GetAlmanacMetaEntry(type, contraptionID);
        if (entry != null && entry.name != null && entry.name.length > 0) {
            name = GetTranslatedString(LogicStrings.GetAlmanacNameContext(type), entry.name, null);
        }
        if (propReplacer != null && entry != null) {
            var context = new AlmanacVariableContext(Main, EngineDefinitionTypes.ENTITY, contraptionID, entry);
            description = propReplacer.Replace(description, context);
        }
        description = ReplaceHyperlinkReferences(description);

        var cost = 0;
        var recharge = "";
        var definition = Main.Game.GetEntityDefinition(contraptionID);
        if (definition != null) {
            // PORT-NOTE: C# 重载 GetCost(this EntityDefinition)/GetRechargeID(this EntityDefinition) 在移植层
            // 分别改名为 GetCostOfDefinition / GetRechargeIDOfDefinition（见 LogicEntityProps）。
            cost = definition.GetCostOfDefinition();
            var rechargeID = definition.GetRechargeIDOfDefinition();
            var rechargeDefinition = Main.Game.GetRechargeDefinition(rechargeID);
            if (rechargeDefinition != null) {
                recharge = GetTranslatedString(LogicStrings.CONTEXT_RECHARGE_TIME, rechargeDefinition.GetName(), null);
            }
        }
        var costText = GetTranslatedString(LogicStrings.CONTEXT_ALMANAC, COST_LABEL, [cost]);
        var rechargeText = GetTranslatedString(LogicStrings.CONTEXT_ALMANAC, RECHARGE_LABEL, [recharge]);

        var page = Main.UseMobileLayout() ? AlmanacPageType.ContraptionsMobile : AlmanacPageType.ContraptionsStandalone;
        UpdateEntryTags(page, type, contraptionID);

        var iconInfos = GetDescriptionTagIconInfos(description);
        var replacements = Lambda.array(Lambda.map(iconInfos, i -> i.replacement));
        var iconStacks = Lambda.array(Lambda.map(iconInfos, i -> i.viewData));
        var finalDesc = ReplaceText(description, replacements);

        var viewData = new ModelBuilder(model, almanacCamera);
        ui.SetActiveContraptionEntry(viewData, name, finalDesc, costText, rechargeText);
        ui.UpdateContraptionDescriptionIcons(iconStacks);
        UnlockAndHideTooltip();
    }
    private function SetActiveEnemyEntry(enemyID:NamespaceID):Void {
        if (!NamespaceID.IsValid(enemyID))
            return;
        var type = LogicAlmanacCategories.ENEMIES;
        var entry = Main.ResourceManager.GetAlmanacMetaEntry(type, enemyID);
        if (entry == null)
            return;

        activeEnemyEntryID = enemyID;
        var infos = GetEntityAlmanacInfos(enemyID, type);
        var model = infos.model;
        var name = infos.name;
        var description = infos.description;
        if (entry.name != null && entry.name.length > 0) {
            name = GetTranslatedString(LogicStrings.GetAlmanacNameContext(type), entry.name, null);
        }
        if (propReplacer != null) {
            var context = new AlmanacVariableContext(Main, EngineDefinitionTypes.ENTITY, enemyID, entry);
            description = propReplacer.Replace(description, context);
        }
        description = ReplaceHyperlinkReferences(description);

        var encounterCondition = entry.encounterUnlock;
        var encountered = (encounterCondition != null && encounterCondition.MeetsConditions(Main.SaveManager)) || Main.SaveManager.IsEnemyEncountered(enemyID);
        if (encountered) {
            UpdateEntryTags(AlmanacPageType.Enemies, type, enemyID);
        } else {
            name = Main.LanguageManager._p(LogicStrings.CONTEXT_ENTITY_NAME, LogicStrings.UNKNOWN_ENTITY_NAME);
            description = Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC, LogicStrings.NOT_ENCOUNTERED_YET);

            ClearEntryTags(AlmanacPageType.Enemies);
        }

        var iconInfos = GetDescriptionTagIconInfos(description);
        var replacements = Lambda.array(Lambda.map(iconInfos, i -> i.replacement));
        var iconStacks = Lambda.array(Lambda.map(iconInfos, i -> i.viewData));
        var finalDesc = ReplaceText(description, replacements);

        var viewData = new ModelBuilder(model, almanacCamera);
        ui.SetActiveEnemyEntry(viewData, name, finalDesc);
        ui.UpdateEnemyDescriptionIcons(iconStacks);
        UnlockAndHideTooltip();
    }
    private function SetActiveArtifactEntry(artifactID:NamespaceID):Void {
        if (!NamespaceID.IsValid(artifactID))
            return;
        var type = LogicAlmanacCategories.ARTIFACTS;
        var entry = Main.ResourceManager.GetAlmanacMetaEntry(type, artifactID);
        if (entry == null)
            return;


        activeArtifactEntryID = artifactID;
        var infos = GetArtifactAlmanacInfos(artifactID, type);
        var sprite = infos.sprite;
        var name = infos.name;
        var description = infos.description;
        if (propReplacer != null) {
            var context = new AlmanacVariableContext(Main, LogicDefinitionTypes.ARTIFACT, artifactID, entry);
            description = propReplacer.Replace(description, context);
        }
        description = ReplaceHyperlinkReferences(description);

        var color = Color.white;
        var unlocked = Main.SaveManager.IsArtifactUnlocked(artifactID);
        if (unlocked) {
            UpdateEntryTags(AlmanacPageType.Artifacts, type, artifactID);
        } else {
            color = Color.black;
            name = Main.LanguageManager._p(LogicStrings.CONTEXT_ARTIFACT_NAME, LogicStrings.UNKNOWN_ARTIFACT_NAME);
            description = Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC, LogicStrings.ALMANAC_UNKNOWN);

            ClearEntryTags(AlmanacPageType.Artifacts);
        }

        var iconInfos = GetDescriptionTagIconInfos(description);
        var replacements = Lambda.array(Lambda.map(iconInfos, i -> i.replacement));
        var iconStacks = Lambda.array(Lambda.map(iconInfos, i -> i.viewData));
        var finalDesc = ReplaceText(description, replacements);

        ui.SetActiveArtifactEntry(sprite, color, name, finalDesc);
        ui.UpdateArtifactDescriptionIcons(iconStacks);
        UnlockAndHideTooltip();
    }
    private function SetActiveMiscEntry(miscID:NamespaceID):Void {
        var entry = Main.ResourceManager.GetAlmanacMetaEntry(LogicAlmanacCategories.MISC, miscID);
        if (entry == null)
            return;
        activeMiscEntryID = miscID;
        var name = GetTranslatedString(LogicStrings.GetAlmanacNameContext(LogicAlmanacCategories.MISC), entry.name, null);

        var descContext = LogicStrings.GetAlmanacDescriptionContext(LogicAlmanacCategories.MISC);
        var header = GetTranslatedString(descContext, entry.header, null);
        header = '<color=#00007F>${header}</color>';
        var properties = GetTranslatedString(descContext, entry.properties, null);

        var flavorKeys = entry.GetValidFlavors(Main.SaveManager);
        var flavors = Lambda.map(flavorKeys, f -> GetTranslatedString(descContext, f, null));
        var flavor = flavors.join("\n\n");

        var strings = Lambda.filter([header, properties, flavor], s -> s != null && s.length > 0);
        var description = strings.join("\n\n");
        if (propReplacer != null) {
            var context = new AlmanacVariableContext(Main, EngineDefinitionTypes.ENTITY, miscID, entry);
            description = propReplacer.Replace(description, context);
        }
        description = ReplaceHyperlinkReferences(description);

        var picture = entry.picture;

        UpdateEntryTags(AlmanacPageType.Miscs, LogicAlmanacCategories.MISC, miscID);

        var iconInfos = GetDescriptionTagIconInfos(description);
        var replacements = Lambda.array(Lambda.map(iconInfos, i -> i.replacement));
        var iconStacks = Lambda.array(Lambda.map(iconInfos, i -> i.viewData));
        var finalDesc = ReplaceText(description, replacements);

        if (picture != null) {
            var modelID = picture.model;
            var modelMeta = NamespaceID.IsValid(modelID) ? Main.ResourceManager.GetModelMeta(modelID) : null;
            if (modelMeta != null && Std.isOfType(modelMeta, ModelMeta)) {
                var viewData = new ModelBuilder(modelID, almanacCamera);
                // PORT-NOTE: C# AlmanacUI 中 SetActiveMiscEntry(IModelBuilder, ...) 与
                // SetActiveMiscEntry(Sprite?, ...) 为重载；Haxe 不支持重载，带模型的版本改名。
                ui.SetActiveMiscEntryFromModel(viewData, name, finalDesc);
            } else {
                var sprite:Sprite = Main.AlmanacManager.GetEntryPictureSprite(entry);
                var spriteSized = entry.pictureFixedSize;
                var zoom = entry.pictureZoom;

                ui.SetActiveMiscEntry(sprite, name, finalDesc, spriteSized, zoom);
            }
        }
        ui.UpdateMiscDescriptionIcons(iconStacks);
        UnlockAndHideTooltip();
    }
    // PORT-NOTE: C# 的 `out NamespaceID? model, out string name, out string description` 改为返回匿名结构体。
    private function GetEntityAlmanacInfos(entityID:NamespaceID, almanacCategory:String):{model:NamespaceID, name:String, description:String} {
        var model:NamespaceID = null;
        var name = "";
        var description = "";
        var definition = Main.Game.GetEntityDefinition(entityID);
        if (definition == null)
            return {model: model, name: name, description: description};
        name = Main.ResourceManager.GetEntityName(entityID);
        description = GetAlmanacDescription(entityID, almanacCategory);

        model = definition.GetModelID();
        return {model: model, name: name, description: description};
    }
    // PORT-NOTE: C# 的 `out Sprite? sprite, out string name, out string description` 改为返回匿名结构体。
    private function GetArtifactAlmanacInfos(artifactID:NamespaceID, almanacCategory:String):{sprite:Sprite, name:String, description:String} {
        var sprite:Sprite = null;
        var name = "";
        var description = "";
        if (!NamespaceID.IsValid(artifactID))
            return {sprite: sprite, name: name, description: description};
        name = Main.ResourceManager.GetArtifactName(artifactID);
        description = GetAlmanacDescription(artifactID, almanacCategory);


        var definition = Main.Game.GetArtifactDefinition(artifactID);
        if (definition == null)
            return {sprite: sprite, name: name, description: description};
        var spriteReference = definition.GetSpriteReference();
        if (spriteReference == null)
            return {sprite: sprite, name: name, description: description};
        sprite = Main.GetFinalSpriteFromRef(spriteReference);
        return {sprite: sprite, name: name, description: description};
    }
    private function GetAlmanacDescription(almanacID:NamespaceID, almanacCategory:String):String {
        if (!NamespaceID.IsValid(almanacID))
            return "";
        var almanacMeta = Main.ResourceManager.GetAlmanacMetaEntry(almanacCategory, almanacID);
        if (almanacMeta == null) {
            return "";
        } else {
            var context = LogicStrings.GetAlmanacDescriptionContext(almanacCategory);
            var header = GetTranslatedString(context, almanacMeta.header, null);
            header = '<color=#00007F>${header}</color>';
            var properties = GetTranslatedString(context, almanacMeta.properties, null);
            var flavorKeys = almanacMeta.GetValidFlavors(Main.SaveManager);
            var flavors = Lambda.map(flavorKeys, f -> GetTranslatedString(context, f, null));
            var flavor = flavors.join("\n\n");
            var strings = Lambda.filter([header, properties, flavor], s -> s != null && s.length > 0);
            return strings.join("\n\n");
        }
    }
    // #endregion

    // #region Description Tag
    // PORT-NOTE: C# 的 `out int index, out NamespaceID? tagID, out string enumValue` 改为返回匿名结构体（解析失败返回 null）。
    private function TryParseTagLinkID(linkID:String):{index:Int, tagID:NamespaceID, enumValue:String} {
        var index = -1;
        var tagID:NamespaceID = null;
        var enumValue = "";
        var indexStart = linkID.indexOf("[");
        var indexEnd = linkID.indexOf("]");
        if (indexStart < 0 || indexEnd < 0) {
            return null;
        }
        var indexStr = linkID.substring(indexStart + 1, indexEnd);
        var parsedIndex = {value: index};
        if (!ParseHelper.TryParseInt(indexStr, parsedIndex)) {
            return null;
        }
        index = parsedIndex.value;

        var afterIndex = linkID.substr(indexEnd + 1);
        var ampIndex = afterIndex.indexOf("&");
        var tagIDStr:String;
        if (ampIndex < 0) {
            tagIDStr = afterIndex;
        } else {
            tagIDStr = afterIndex.substring(0, ampIndex);
            enumValue = afterIndex.substr(ampIndex + 1);
        }
        var defaultNsp = Main.BuiltinNamespace;
        var parsedTag:{value:NamespaceID} = {value: null};
        if (!NamespaceID.TryParse(tagIDStr, defaultNsp, parsedTag))
            return null;
        tagID = parsedTag.value;
        return {index: index, tagID: tagID, enumValue: enumValue};
    }
    private function GetLinkIDByTag(index:Int, tagID:String):String {
        return '[${index}]${tagID}';
    }
    private function GetLinkIDByEnumTag(index:Int, tagID:String, enumID:String):String {
        return '[${index}]${tagID}&${enumID}';
    }
    private function GetTagTooltipViewData(tagID:NamespaceID, enumValue:String):TooltipContent {
        var tagMeta = Main.ResourceManager.GetAlmanacTagMeta(tagID);
        if (tagMeta == null)
            return new TooltipContent();
        var name = "";
        var desc = "";
        if (NamespaceID.IsValid(tagMeta.enumType)) {
            var defaultNsp = Main.BuiltinNamespace;
            var enumMeta = Main.ResourceManager.GetAlmanacTagEnumMeta(tagMeta.enumType);
            var enumValueMeta = enumMeta != null ? enumMeta.FindValueByString(enumValue, defaultNsp) : null;
            if (enumValueMeta != null) {
                var tagName = Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC_TAG_NAME, tagMeta.name);
                var enumValueName = Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC_TAG_ENUM_NAME, enumValueMeta.name);
                name = Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC, TAG_ENUM_TEMPLATE, [tagName, enumValueName]);
                desc = Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC_TAG_ENUM_DESCRIPTION, enumValueMeta.description);
                var content = new TooltipContent();
                content.name = name;
                content.description = desc;
                return content;
            }
        }
        name = Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC_TAG_NAME, tagMeta.name);
        desc = Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC_TAG_DESCRIPTION, tagMeta.description);
        var content = new TooltipContent();
        content.name = name;
        content.description = desc;
        return content;
    }
    private function GetDescriptionTagIconInfos(text:String):Array<DescriptionTagIconInfo> {
        var infos:Array<DescriptionTagIconInfo> = [];

        var pattern = '<tag +id ?= ?"([\\w:]*)"( +enum ?= ?"([\\w:]*)")? */>';
        // PORT-NOTE: C# `Regex.Matches(text, pattern)` → Haxe EReg 逐次 matchSub 迭代（EReg 无 Matches）。
        var regex = new EReg(pattern, "g");
        var defaultNsp = Main.BuiltinNamespace;
        var i = 0;
        var pos = 0;
        while (regex.matchSub(text, pos)) {
            var matchPos = regex.matchedPos();
            pos = matchPos.pos + (matchPos.len == 0 ? 1 : matchPos.len);

            var tagIDStr = regex.matched(1);
            var parsedTag:{value:NamespaceID} = {value: null};
            if (!NamespaceID.TryParse(tagIDStr, defaultNsp, parsedTag)) {
                i++;
                continue;
            }
            var tagID = parsedTag.value;
            var tagMeta = Main.ResourceManager.GetAlmanacTagMeta(tagID);
            if (tagMeta == null) {
                i++;
                continue;
            }
            var enumValue = "";
            var enumGroup = regex.matched(3);
            if (enumGroup != null && enumGroup.length > 0) {
                enumValue = enumGroup;
            }
            var viewProperties = GetTagMetaViewProperties(tagMeta, enumValue);
            var iconSpriteRef = viewProperties.iconSprite;
            var backgroundSpriteRef = viewProperties.backgroundSprite;
            var backgroundColor = viewProperties.backgroundColor;
            var markSpriteRef = viewProperties.markSprite;
            var linkID:String;
            if (enumValue != null && enumValue.length > 0) {
                linkID = GetLinkIDByEnumTag(i, tagIDStr, enumValue);
            } else {
                linkID = GetLinkIDByTag(i, tagIDStr);
            }

            var iconSprite = Main.GetFinalSpriteFromRef(iconSpriteRef);
            var backgroundSprite = Main.GetFinalSpriteFromRef(backgroundSpriteRef);
            var markSprite = Main.GetFinalSpriteFromRef(markSpriteRef);
            var size = new Vector2(32, 32);
            if (UnityObject.exists(backgroundSprite)) {
                size = backgroundSprite.rect.size;
            }


            // 存储替换信息
            var rep = "";
            rep += '<link="${linkID}">';
            rep += '<space=${descriptionTagSpacing}>';
            rep += '<sprite="tag_icon_placeholder" index=0>';
            rep += '<space=${descriptionTagSpacing}>';
            rep += '</link>';
            var replacement = new ReplacementInfo();
            replacement.startIndex = matchPos.pos;
            replacement.length = matchPos.len;
            replacement.text = rep;

            var iconViewdata = new AlmanacTagIconViewData();
            var backgroundLayer = new AlmanacTagIconLayerViewData();
            backgroundLayer.sprite = backgroundSprite;
            backgroundLayer.tint = backgroundColor;
            var mainLayer = new AlmanacTagIconLayerViewData();
            mainLayer.sprite = iconSprite;
            mainLayer.tint = Color.white;
            var markLayer = new AlmanacTagIconLayerViewData();
            markLayer.sprite = markSprite;
            markLayer.tint = Color.white;
            iconViewdata.background = backgroundLayer;
            iconViewdata.main = mainLayer;
            iconViewdata.mark = markLayer;

            var viewData = new AlmanacDescriptionTagViewData();
            viewData.linkID = linkID;
            viewData.icon = iconViewdata;
            viewData.size = size;

            var info = new DescriptionTagIconInfo();
            info.replacement = replacement;
            info.viewData = viewData;
            infos.push(info);
            i++;
        }
        return infos;
    }
    // PORT-NOTE: system.text.StringBuilder shim 无 Remove，改用字符串切片实现等价逻辑。
    private static function ReplaceText(text:String, replacements:Array<ReplacementInfo>):String {
        var result = text;
        var i = replacements.length - 1;
        while (i >= 0) {
            var replacement = replacements[i];
            result = result.substring(0, replacement.startIndex) + replacement.text + result.substr(replacement.startIndex + replacement.length);
            i--;
        }
        return result;
    }
    // #endregion

    // #region Entry Tag
    private function GetEntryTags(category:String, id:NamespaceID):Array<AlmanacEntryTagInfo> {
        var list:Array<AlmanacEntryTagInfo> = [];
        var almanacEntry = Main.ResourceManager.GetAlmanacMetaEntry(category, id);
        if (almanacEntry != null) {
            var param = new GetAlmanacEntryTagsParams(category, id, almanacEntry.tagSourceEntity, list);
            Global.Game.RunCallbackFiltered(LogicCallbacks.GET_ALMANAC_ENTRY_TAGS, param, category);

            for (tag in almanacEntry.tags) list.push(tag);
        }
        list.sort(CompareEntryTagInfo);
        // PORT-NOTE: C# struct 的 Distinct() 依赖值相等；Haxe 移植为类，改用显式去重。
        return distinctEntryTags(list);
    }
    private function CompareEntryTagInfo(a:AlmanacEntryTagInfo, b:AlmanacEntryTagInfo):Int {
        var metaA = Main.ResourceManager.GetAlmanacTagMeta(a.tagID);
        var metaB = Main.ResourceManager.GetAlmanacTagMeta(b.tagID);
        var priorityA = metaA != null ? metaA.priority : 0;
        var priorityB = metaB != null ? metaB.priority : 0;
        return priorityA - priorityB;
    }
    private function UpdateEntryTags(page:AlmanacPageType, category:String, id:NamespaceID):Void {
        var tags = GetEntryTags(category, id);

        currentTags = [];
        for (tag in tags) currentTags.push(tag);

        var viewDatas = Lambda.array(Lambda.map(currentTags, t -> GetTagIconViewData(t)));
        ui.UpdateTagIcons(page, viewDatas);
    }
    private function ClearEntryTags(page:AlmanacPageType):Void {
        currentTags = [];
        ui.UpdateTagIcons(page, []);
    }
    private function GetEntryTagIconInfo(index:Int):AlmanacEntryTagInfo {
        return currentTags[index];
    }
    private function GetTagIconViewData(info:AlmanacEntryTagInfo):AlmanacTagIconViewData {
        var tagID = info.tagID;
        var tagMeta = Main.ResourceManager.GetAlmanacTagMeta(tagID);
        if (tagMeta == null)
            // PORT-NOTE: C# 返回 default(AlmanacTagIconViewData)（全零结构体）；Haxe 无结构体默认值，返回空实例。
            return new AlmanacTagIconViewData();
        var viewProperties = GetTagMetaViewProperties(tagMeta, info.enumValue);
        var iconSpriteRef = viewProperties.iconSprite;
        var backgroundSpriteRef = viewProperties.backgroundSprite;
        var backgroundColor = viewProperties.backgroundColor;
        var markSpriteRef = viewProperties.markSprite;

        var iconSprite = Main.GetFinalSpriteFromRef(iconSpriteRef);
        var backgroundSprite = Main.GetFinalSpriteFromRef(backgroundSpriteRef);
        var markSprite = Main.GetFinalSpriteFromRef(markSpriteRef);

        var viewData = new AlmanacTagIconViewData();
        var backgroundLayer = new AlmanacTagIconLayerViewData();
        backgroundLayer.sprite = backgroundSprite;
        backgroundLayer.tint = backgroundColor;
        var mainLayer = new AlmanacTagIconLayerViewData();
        mainLayer.sprite = iconSprite;
        mainLayer.tint = Color.white;
        var markLayer = new AlmanacTagIconLayerViewData();
        markLayer.sprite = markSprite;
        markLayer.tint = Color.white;
        viewData.background = backgroundLayer;
        viewData.main = mainLayer;
        viewData.mark = markLayer;
        return viewData;
    }
    // PORT-NOTE: C# 的 `out SpriteReference? iconSpriteRef, out SpriteReference? backgroundSpriteRef, out Color backgroundColor, out SpriteReference? markSpriteRef` 改为返回匿名结构体。
    private function GetTagMetaViewProperties(tagMeta:AlmanacTagMeta, enumValue:String):{iconSprite:SpriteReference, backgroundSprite:SpriteReference, backgroundColor:Color, markSprite:SpriteReference} {
        var defaultNsp = Main.BuiltinNamespace;
        var iconSpriteRef = tagMeta.iconSprite;
        var backgroundSpriteRef = tagMeta.backgroundSprite;
        var backgroundColor = tagMeta.backgroundColor;
        var markSpriteRef = tagMeta.markSprite;
        if (NamespaceID.IsValid(tagMeta.enumType)) {
            var tagEnumMeta = Main.ResourceManager.GetAlmanacTagEnumMeta(tagMeta.enumType);
            var valueMeta = tagEnumMeta != null ? tagEnumMeta.FindValueByString(enumValue, defaultNsp) : null;
            if (valueMeta != null) {
                iconSpriteRef = valueMeta.iconSprite;
                backgroundColor = valueMeta.backgroundColor;
            }
        }
        return {iconSprite: iconSpriteRef, backgroundSprite: backgroundSpriteRef, backgroundColor: backgroundColor, markSprite: markSpriteRef};
    }
    // #endregion

    // #region Description Link
    private function ReplaceHyperlinkReferences(description:String):String {
        // C#: hyperlinkRegex.Replace(description, m => {...})
        // PORT-NOTE: Haxe 的 EReg.replace 不接受匹配求值函数，改为手动逐次匹配拼接。
        var regex = new EReg(hyperlinkPattern, "gi");
        var result = "";
        var pos = 0;
        while (regex.matchSub(description, pos)) {
            var matchPos = regex.matchedPos();
            result += description.substring(pos, matchPos.pos);
            var linkID = regex.matched(1);
            var text = regex.matched(2);
            var parsed = TryParseDescriptionLinkID(linkID);
            if (parsed == null) {
                result += regex.matched(0);
            } else if (!ValidateDescriptionLink(parsed.type, parsed.pageID)) {
                result += text;
            } else {
                result += '<color=blue><u><link=${linkID}>${regex.matched(2)}</link></u></color>';
            }
            pos = matchPos.pos + (matchPos.len == 0 ? 1 : matchPos.len);
        }
        result += description.substr(pos);
        return result;
    }
    // PORT-NOTE: C# 的 `out string type, out NamespaceID? pageID` 改为返回匿名结构体（解析失败返回 null）。
    private function TryParseDescriptionLinkID(linkID:String):{type:String, pageID:NamespaceID} {
        var type = "";
        var pageID:NamespaceID = null;
        var typeStart = linkID.indexOf("[");
        var typeEnd = linkID.indexOf("]");
        if (typeStart < 0 || typeEnd < 0) {
            return null;
        }
        type = linkID.substring(typeStart + 1, typeEnd);

        var afterIndex = linkID.substr(typeEnd + 1);
        var tagIDStr = afterIndex;
        var defaultNsp = Main.BuiltinNamespace;
        var parsed:{value:NamespaceID} = {value: null};
        if (!NamespaceID.TryParse(tagIDStr, defaultNsp, parsed))
            return null;
        pageID = parsed.value;
        return {type: type, pageID: pageID};
    }
    private function ValidateDescriptionLink(type:String, pageID:NamespaceID):Bool {
        switch (type) {
            case HYPERLINK_TYPE_CONTRAPTIONS:
                if (pageID == VanillaContraptionID.commandBlock) {
                    if (!Main.SaveManager.IsCommandBlockUnlocked())
                        return false;
                } else {
                    if (!contraptionEntries.contains(pageID))
                        return false;
                }
            case HYPERLINK_TYPE_ENEMIES:
                if (!enemyEntries.contains(pageID))
                    return false;
            case HYPERLINK_TYPE_ARTIFACTS:
                if (!artifactEntries.contains(pageID))
                    return false;
            case HYPERLINK_TYPE_MISC:
                if (!Lambda.exists(miscGroups, g -> g.entries.contains(pageID)))
                    return false;
        }
        return true;
    }
    // #endregion

    // #region 放大镜
    private function ShowCharacterZoom(characterID:NamespaceID):Void {
        var canSwitchPage = false;
        var characterMeta = Main.ResourceManager.GetCharacterMeta(characterID);
        if (characterMeta == null)
            return;
        var unlockedVariants = Lambda.filter(characterMeta.variants, v -> v.unlock.IsNullOrMeetsConditions(Main.SaveManager));
        var variantCount = unlockedVariants.length;
        if (variantCount <= 0)
            return;
        if (variantCount > 1) {
            canSwitchPage = true;
        }

        var variant = unlockedVariants[0];
        zoomPortrait = Main.TalkManager.CreateCharacterPortraitWithVariant(variant);
        ShowSpriteZoom(zoomPortrait.GetSprite(), canSwitchPage);
    }
    private function ShowSpriteZoom(sprite:Sprite, canSwitchPage:Bool):Void {
        var textKey = Main.InputManager.GetActivePointerType() == PointerTypes.TOUCH ? ZOOM_HINT_TOUCH : ZOOM_HINT_MOUSE;
        var hintText = Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC, textKey);
        ui.SetZoomHintText(hintText);
        ui.SetZoomPageButtonsActive(canSwitchPage);
        ui.SetZoomSprite(sprite);
        ui.StartZoom();
        zoomIndex = 0;
    }
    private function StopZoom():Void {
        ui.StopZoom();
        if (zoomPortrait != null) {
            zoomPortrait.Dispose();
            zoomPortrait = null;
        }
    }
    // #endregion

    private function LockTooltipEntryTag(entryTagIndex:Int):Void {
        tagTooltipLockedTarget = entryTagIndex;
        descriptionTagTooltipLockedTarget = "";
    }
    private function LockTooltipDescription(descriptionTagLinkID:String):Void {
        tagTooltipLockedTarget = -1;
        descriptionTagTooltipLockedTarget = descriptionTagLinkID;
    }
    private function UnlockTooltip():Void {
        tagTooltipLockedTarget = -1;
        descriptionTagTooltipLockedTarget = "";
    }
    private function UnlockAndHideTooltip():Void {
        UnlockTooltip();
        Main.Scene.HideTooltip();
    }
    private function GetTranslatedString(context:String, text:String, args:Array<Dynamic>):String {
        return Main.LanguageManager._p(context, text, args);
    }
    @:translateMsg("图鉴描述模板，{0}为能量", LogicStrings.CONTEXT_ALMANAC)
    public static inline var COST_LABEL:String = "花费：<color=red>{0}</color>";
    @:translateMsg("图鉴描述模板，{0}为充能时间", LogicStrings.CONTEXT_ALMANAC)
    public static inline var RECHARGE_LABEL:String = "充能时间：<color=red>{0}</color>";
    @:translateMsg("图鉴放大选项，{0}为缩放等级", LogicStrings.CONTEXT_ALMANAC)
    public static inline var OPTION_ZOOM_SCALE:String = "缩放：{0}";
    @:translateMsg("图鉴标签枚举值的名称模板，{0}为标签名，{1}为值名", LogicStrings.CONTEXT_ALMANAC)
    public static inline var TAG_ENUM_TEMPLATE:String = "{0}：{1}";
    @:translateMsg("图鉴缩放提示文本", LogicStrings.CONTEXT_ALMANAC)
    public static inline var ZOOM_HINT_MOUSE:String = "左键拖拽以移动视图；滚轮以缩放视图";
    @:translateMsg("图鉴缩放提示文本", LogicStrings.CONTEXT_ALMANAC)
    public static inline var ZOOM_HINT_TOUCH:String = "单指拖拽以移动视图；双指拖拽以缩放视图";


    private var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    private var propReplacer:DescriptionPropReplacer;
    private var contraptionEntries:Array<NamespaceID> = [];
    private var enemyEntries:Array<NamespaceID> = [];
    private var artifactEntries:Array<NamespaceID> = [];
    private var miscGroups:Array<AlmanacEntryGroup> = [];
    private var currentTags:Array<AlmanacEntryTagInfo> = [];
    private var activeEnemyEntryID:NamespaceID;
    private var activeArtifactEntryID:NamespaceID;
    private var activeMiscEntryID:NamespaceID;
    private var tagTooltipLockedTarget:Int;
    private var descriptionTagTooltipLockedTarget:String;
    private var zoomIndex:Int;
    private var zoomPortrait:CharacterPortrait;

    private static inline var hyperlinkPattern:String = '<ref=([\\w\\[\\]\\-\\.:]+?)>(.+?)</ref>';

    private static inline var HYPERLINK_TYPE_CONTRAPTIONS:String = "contraptions";
    private static inline var HYPERLINK_TYPE_ENEMIES:String = "enemies";
    private static inline var HYPERLINK_TYPE_ARTIFACTS:String = "artifacts";
    private static inline var HYPERLINK_TYPE_MISC:String = "misc";

    // PORT-NOTE: C# struct AlmanacEntryTagInfo 的 `Distinct()` 按其值相等；Haxe 移植为类，
    // 这里按 tagID + enumValue 显式去重。
    private static function distinctEntryTags(tags:Array<AlmanacEntryTagInfo>):Array<AlmanacEntryTagInfo> {
        var result:Array<AlmanacEntryTagInfo> = [];
        for (tag in tags) {
            if (!Lambda.exists(result, t -> t.tagID == tag.tagID && t.enumValue == tag.enumValue))
                result.push(tag);
        }
        return result;
    }
    // PORT-NOTE: C# Tools.Mathematics.MathTool 属于外部 Tools 库（未随本仓库提供源码），
    // 这里按循环偏移语义提供最小等价实现。
    // TODO-PORT: 无法核对 MathTool.CycleOffset 的原始实现，仅按“循环索引偏移”语义推断。
    private static function cycleOffset(index:Int, offset:Int, count:Int):Int {
        if (count <= 0)
            return index;
        return ((index + offset) % count + count) % count;
    }

    @:serializeField
    private var almanacCamera:Camera = null;
    @:serializeField
    private var ui:AlmanacUI = null;
    @:serializeField
    private var descriptionTagSpacing:Float = 2;
}

// PORT-NOTE: C# struct → class（PORTING.md: struct → class）。
class ReplacementInfo {
    public var startIndex:Int;
    public var length:Int;
    public var text:String;

    public function new() {}
}

// PORT-NOTE: C# struct → class（PORTING.md: struct → class）。
class DescriptionTagIconInfo {
    public var replacement:ReplacementInfo;
    public var viewData:AlmanacDescriptionTagViewData;

    public function new() {}
}
