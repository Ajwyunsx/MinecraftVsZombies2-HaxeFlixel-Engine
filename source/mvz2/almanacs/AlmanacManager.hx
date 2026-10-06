package mvz2.almanacs;

import mvz2.managers.MainManager;
import mvz2.metas.AlmanacMetaEntry;
import mvz2.metas.AlmanacPicture;
import mvz2.saves.MVZ2SaveExt;
import mvz2.ui.almanac.AlmanacEntryGroupUI;
import mvz2.ui.almanac.AlmanacEntry;
import mvz2.ui.BlueprintDisplayer;
import mvz2logic.almanac.LogicAlmanacCategories;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.localization.LogicStrings;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import unity.Color;
import unity.MonoBehaviour;
import unity.Sprite;
import unity.Vector2;
import mvz2.localization.LanguageManager;
import Main;
import mvz2.managers.ResourceManager;
import mvz2.saves.SaveManager;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;
import mvz2.ui.almanac.AlmanacEntry.AlmanacEntryViewData;
import mvz2.ui.almanac.AlmanacEntryGroupUI.AlmanacEntryGroupViewData;

// PORT-NOTE: C# 中 GetArtifactDefinition / GetSpriteReference 是扩展方法，Haxe 侧用 `using` 还原。
using mvz2logic.games.LogicGameDefinitionsExt;
using mvz2logic.artifacts.LogicArtifactProps;

// Ported from: Assets/Scripts/MVZ2/Almanac/AlmanacManager.cs
class AlmanacManager extends MonoBehaviour {
    // #region 获取图鉴项列表
    public function GetOrderedContraptionsByAlmanac(contraptionsID:Array<NamespaceID>, appendList:Array<NamespaceID>):Void {
        var idList = GetUnlockedAlmanacEntries(LogicAlmanacCategories.CONTRAPTIONS, (id, entry) -> contraptionsID.contains(id) && !entry.hidden);
        var ordered = CompressLayout(idList, GetBlueprintCountPerRow());
        for (id in ordered) appendList.push(id);
    }
    public function GetContraptionPageEntries(appendList:Array<NamespaceID>):Void {
        var idList = GetUnlockedAlmanacEntries(LogicAlmanacCategories.CONTRAPTIONS, (id, entry) -> Main.SaveManager.IsContraptionUnlocked(id) && !entry.hidden);
        var ordered = CompressLayout(idList, GetBlueprintCountPerRow());
        for (id in ordered) appendList.push(id);
    }
    public function GetEnemyPageEntries(appendList:Array<NamespaceID>):Void {
        var idList = GetUnlockedAlmanacEntries(LogicAlmanacCategories.ENEMIES, (id, entry) -> Main.SaveManager.IsEnemyUnlocked(id) && !entry.hidden);
        var ordered = CompressLayout(idList, GetEnemyCountPerRow());
        for (id in ordered) appendList.push(id);
    }
    public function GetOrderedArtifactsByAlmanac(artifactsID:Array<NamespaceID>, appendList:Array<NamespaceID>):Void {
        var idList = GetUnlockedAlmanacEntries(LogicAlmanacCategories.ARTIFACTS, (id, entry) -> artifactsID.contains(id) && !entry.hidden);
        var ordered = CompressLayout(idList, GetMiscCountPerRow());
        for (id in ordered) appendList.push(id);
    }
    public function GetArtifactPageEntries(appendList:Array<NamespaceID>):Void {
        var idList = GetUnlockedAlmanacEntries(LogicAlmanacCategories.ARTIFACTS, ShouldArtifactShowInAlmanac);
        var ordered = CompressLayout(idList, GetMiscCountPerRow());
        for (id in ordered) appendList.push(id);
    }
    public function GetMiscPageGroups(appendList:Array<AlmanacEntryGroup>):Void {
        var groups = Main.ResourceManager.GetAlmanacMetaGroups(LogicAlmanacCategories.MISC);
        for (group in groups) {
            var entries = group.entries;
            var groupEntries:Array<NamespaceID> = [];
            groupEntries.resize(entries.length);
            for (i in 0...groupEntries.length) {
                var entry = entries[i];
                var id = entry.id;
                if (!NamespaceID.IsValid(id))
                    continue;
                if (!MVZ2SaveExt.IsNullOrMeetsConditions(entry.unlock, Main.SaveManager))
                    continue;
                groupEntries[i] = id;
            }
            var compressedEntries = CompressLayout(groupEntries, miscCountPerRow);
            var g = new AlmanacEntryGroup(group.name, compressedEntries);
            if (Lambda.exists(g.entries, e -> NamespaceID.IsValid(e))) {
                appendList.push(g);
            }
        }
    }
    private function ShouldArtifactShowInAlmanac(id:NamespaceID, entry:AlmanacMetaEntry):Bool {
        if (entry.hidden)
            return false;
        if (Main.SaveManager.IsArtifactUnlocked(id))
            return true;
        if (entry.silhouetteUnlock != null && entry.silhouetteUnlock.MeetsConditions(Main.SaveManager))
            return true;
        return false;
    }
    private function GetUnlockedAlmanacEntries(category:String, predicate:NamespaceID->AlmanacMetaEntry->Bool):Array<NamespaceID> {
        var entries = Main.ResourceManager.GetAlmanacMetaEntries(category);
        var results:Array<NamespaceID> = [];
        results.resize(entries.length);
        for (i in 0...results.length) {
            var entry = entries[i];
            if (entry == null) continue;
            var id = entry.id;
            if (!NamespaceID.IsValid(id))
                continue;
            if (predicate(id, entry)) {
                results[i] = id;
            }
        }
        return results;
    }
    // #endregion

    // #region 压缩布局
    // PORT-NOTE: C# LINQ Select+GroupBy+Where+SelectMany → explicit row grouping.
    private function CompressLayout(idList:Array<NamespaceID>, countPerRow:Int):Array<NamespaceID> {
        var result:Array<NamespaceID> = [];
        var index = 0;
        while (index < idList.length) {
            var group:Array<NamespaceID> = [];
            var rowEnd = Std.int(Math.min(index + countPerRow, idList.length));
            for (i in index...rowEnd) group.push(idList[i]);
            var hasValid = false;
            for (v in group) {
                if (NamespaceID.IsValid(v)) { hasValid = true; break; }
            }
            if (hasValid) {
                for (v in group) result.push(v);
            }
            index += countPerRow;
        }
        return result;
    }
    public function GetBlueprintCountPerRow():Int {
        return Main.UseMobileLayout() ? blueprintCountPerRowMobile : blueprintCountPerRowStandalone;
    }
    public function GetEnemyCountPerRow():Int {
        return enemyCountPerRow;
    }
    public function GetMiscCountPerRow():Int {
        return miscCountPerRow;
    }
    // #endregion

    // #region 获取图鉴项显示信息
    public function GetChoosingBlueprintViewData(id:NamespaceID, isEndless:Bool, isCommandBlock:Bool = false):ChoosingBlueprintViewData {
        if (!NamespaceID.IsValid(id))
            return ChoosingBlueprintViewData.Empty;
        var blueprintDef = Main.Game.GetSeedDefinition(id);
        if (blueprintDef == null)
            return ChoosingBlueprintViewData.Empty;
        // PORT-NOTE: C# 用对象初始化器构造 ChoosingBlueprintViewData；Haxe 无该语法，改为逐字段赋值。
        // PORT-NOTE: C# 重载 GetBlueprintViewData(SeedDefinition, bool, bool) 在移植层名为 GetBlueprintViewDataFromDefinition。
        var viewData = new ChoosingBlueprintViewData();
        viewData.blueprint = Main.ResourceManager.GetBlueprintViewDataFromDefinition(blueprintDef, isEndless, isCommandBlock);
        viewData.disabled = false;
        return viewData;
    }
    public function GetEnemyEntryViewData(id:NamespaceID):AlmanacEntryViewData {
        if (!NamespaceID.IsValid(id))
            return AlmanacEntryViewData.Empty;
        var def = Main.Game.GetEntityDefinition(id);
        if (def == null)
            return AlmanacEntryViewData.Empty;

        var entry = Main.ResourceManager.GetAlmanacMetaEntry(LogicAlmanacCategories.ENEMIES, id);
        var icon:Sprite = null;
        var color = Color.white;
        var offset = Vector2.zero;
        if (entry != null) {
            icon = GetEntryThumbnailSprite(entry);
        }
        if (icon == null) {
            var blueprintID = LogicBlueprintID.FromEntity(id);
            var blueprintDef = Main.Game.GetSeedDefinition(blueprintID);
            if (blueprintDef != null) {
                icon = Main.ResourceManager.GetBlueprintIconMobile(blueprintDef);
            }
            offset = new Vector2(20, 0);
        }
        return new AlmanacEntryViewData({sprite: icon, color: color, offset: offset});
    }
    public function GetArtifactEntryViewData(id:NamespaceID):AlmanacEntryViewData {
        if (!NamespaceID.IsValid(id))
            return AlmanacEntryViewData.Empty;
        var def = Main.Game.GetArtifactDefinition(id);
        if (def == null)
            return AlmanacEntryViewData.Empty;

        var entry = Main.ResourceManager.GetAlmanacMetaEntry(LogicAlmanacCategories.ARTIFACTS, id);
        var icon = GetArtifactThumbnail(entry, def);
        var color = Main.SaveManager.IsArtifactUnlocked(id) ? Color.white : Color.black;
        return new AlmanacEntryViewData({sprite: icon, color: color});
    }
    public function GetMiscEntryViewData(id:NamespaceID):AlmanacEntryViewData {
        if (!NamespaceID.IsValid(id))
            return AlmanacEntryViewData.Empty;

        var entry = Main.ResourceManager.GetAlmanacMetaEntry(LogicAlmanacCategories.MISC, id);
        if (entry == null)
            return AlmanacEntryViewData.Empty;

        return new AlmanacEntryViewData({sprite: GetEntryThumbnailSprite(entry), color: Color.white});
    }
    public function GetMiscGroupViewData(group:AlmanacEntryGroup):AlmanacEntryGroupViewData {
        return new AlmanacEntryGroupViewData({
            name: Main.LanguageManager._p(LogicStrings.CONTEXT_ALMANAC_GROUP_NAME, group.name),
            entries: Lambda.array(Lambda.map(group.entries, GetMiscEntryViewData))
        });
    }
    // #endregion

    // #region 缩略图
    public function GetEntryThumbnailSprite(entry:AlmanacMetaEntry):Sprite {
        var sprite:Sprite = null;
        if (entry.thumbnail != null)
            sprite = GetPictureThumbnailSprite(entry.thumbnail);
        if (sprite != null)
            return sprite;

        if (entry.picture != null)
            sprite = GetPictureThumbnailSprite(entry.picture);
        return sprite;
    }
    public function GetPictureThumbnailSprite(picture:AlmanacPicture):Sprite {
        if (picture == null)
            return null;
        var sprite:Sprite = null;

        if (picture.model != null)
            sprite = Main.ResourceManager.GetModelIcon(picture.model);
        if (sprite != null)
            return sprite;

        sprite = GetPictureSprite(picture);
        return sprite;
    }
    // #endregion

    // #region 图片
    public function GetArtifactThumbnail(entry:AlmanacMetaEntry, def:ArtifactDefinition):Sprite {
        var icon:Sprite = null;
        if (entry != null) {
            icon = GetEntryThumbnailSprite(entry);
        }
        if (icon != null)
            return icon;

        // PORT-NOTE: C# 重载 GetFinalSprite(SpriteReference?) 在移植层名为 GetFinalSpriteFromRef。
        var spriteRef = def.GetSpriteReference();
        if (SpriteReference.IsValid(spriteRef)) {
            icon = Main.GetFinalSpriteFromRef(spriteRef);
        }
        return icon;
    }
    public function GetEntryPictureSprite(entry:AlmanacMetaEntry):Sprite {
        return GetPictureSprite(entry.picture);
    }
    public function GetPictureSprite(picture:AlmanacPicture):Sprite {
        if (picture == null)
            return null;
        var sprite:Sprite = null;
        if (picture.sprite != null)
            sprite = Main.GetFinalSpriteFromRef(picture.sprite);

        if (sprite != null)
            return sprite;

        return sprite;
    }
    // #endregion


    public var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    @:serializeField
    private var blueprintCountPerRowStandalone:Int = 8;
    @:serializeField
    private var blueprintCountPerRowMobile:Int = 4;
    @:serializeField
    private var enemyCountPerRow:Int = 5;
    @:serializeField
    private var miscCountPerRow:Int = 5;
}

class AlmanacEntryGroup {
    public function new(name:String, entries:Array<NamespaceID>) {
        this.name = name;
        this.entries = entries;
    }
    public var name:String;
    public var entries:Array<NamespaceID>;
}
