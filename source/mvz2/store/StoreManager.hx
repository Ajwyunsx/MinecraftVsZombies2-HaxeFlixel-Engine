package mvz2.store;

import mvz2.managers.MainManager;
import mvz2.metas.ProductMeta;
import mvz2.metas.ProductStageMeta;
import mvz2.metas.StoreChatMeta;
import mvz2.saves.MVZ2SaveExt;
import mvz2.ui.store.StoreProductItem;
import pvzengine.NamespaceID;
import tools.RandomGenerator;
import unity.MonoBehaviour;
import mvz2.localization.LanguageManager;
import Main;
import unity.Random;
import mvz2.managers.ResourceManager;
import mvz2.saves.SaveManager;
import unity.Sprite;
import unity.ui.Text;
import mvz2.ui.store.StoreProductItem.ProductItemViewData;

// PORT-NOTE: C# 的 `characterChats.Random(rng)` 是扩展方法，Haxe 需 `using` 对应扩展类。
using tools.EnumerableExt;
// PORT-NOTE: C# 中 MeetsXMLConditions / IsValidAndUnlocked 是扩展方法，Haxe 侧用 `using` 还原。
using mvz2.saves.MVZ2SaveExt;
using mvz2logic.saves.LogicSaveExt;

// Ported from: Assets/Scripts/MVZ2/Store/StoreManager.cs
class StoreManager extends MonoBehaviour {
    public function GetOrderedProducts(products:Array<NamespaceID>, countPerRow:Int, appendList:Array<NamespaceID>):Void {
        var idList = GetIDListByProductOrder(products);
        var ordered = CompressLayout(idList, countPerRow);
        for (id in ordered) appendList.push(id);
    }
    public function GetRandomChat(characterId:NamespaceID, rng:RandomGenerator):StoreChatMeta {
        var characterChats = Main.ResourceManager.GetCharacterStoreChats(characterId);
        if (characterChats == null)
            return null;
        return characterChats.Random(rng);
    }
    public function GetProductViewData(id:NamespaceID):ProductItemViewData {
        if (!NamespaceID.IsValid(id))
            return ProductItemViewData.Empty;
        var productMeta = Main.ResourceManager.GetProductMeta(id);
        if (productMeta == null)
            return ProductItemViewData.Empty;

        var isBlueprint = NamespaceID.IsValid(productMeta.BlueprintID);
        // PORT-NOTE: C# 重载 GetFinalSprite(SpriteReference?) 在移植层名为 GetFinalSpriteFromRef。
        var icon = Main.GetFinalSpriteFromRef(productMeta.Sprite);
        // PORT-NOTE: C# 重载 GetBlueprintViewData(NamespaceID, bool) 在 Haxe 移植层改名为 GetBlueprintViewDataFromID。
        var blueprint = Main.ResourceManager.GetBlueprintViewDataFromID(productMeta.BlueprintID, false);

        var price = "";
        var interactable = false;
        var text = "";

        var stage = GetCurrentProductStage(productMeta);
        if (stage != null) {
            var soldout = IsSoldout(stage);
            price = formatN0(stage.Price);
            interactable = !soldout;
            var textKey = soldout ? PRODUCT_SOLDOUT : stage.Text;
            if (textKey != null && textKey.length > 0)
                text = Main.LanguageManager._(textKey);
        }

        return new ProductItemViewData({
            icon: icon,
            blueprint: blueprint,
            isBlueprint: isBlueprint,
            isBlueprintMobile: Main.UseMobileLayout(),

            interactable: interactable,
            price: price,
            text: text
        });
    }
    public function GetCurrentProductStage(productMeta:ProductMeta):ProductStageMeta {
        for (i in 0...productMeta.Stages.length) {
            var stage = productMeta.Stages[i];
            if (stage == null)
                continue;
            if (stage.Conditions != null && !Main.SaveManager.MeetsXMLConditions(stage.Conditions))
                continue;
            if (IsSoldout(stage))
                continue;
            return stage;
        }
        return productMeta.Stages.length > 0 ? productMeta.Stages[productMeta.Stages.length - 1] : null;
    }
    public function IsSoldout(stage:ProductStageMeta):Bool {
        return Main.SaveManager.IsValidAndUnlocked(stage.Unlocks);
    }
    private function GetIDListByProductOrder(idList:Array<NamespaceID>):Array<NamespaceID> {
        if (idList == null || idList.length == 0)
            return [];
        var productIndexes = Lambda.map(idList, id -> {
            id: id,
            index: Main.ResourceManager.GetProductMeta(id) != null ? Main.ResourceManager.GetProductMeta(id).Index : -1
        });
        var maxIndex = 0;
        for (tuple in productIndexes) {
            if (tuple.index > maxIndex) maxIndex = tuple.index;
        }
        var ordered:Array<NamespaceID> = [];
        ordered.resize(maxIndex + 1);
        for (i in 0...ordered.length) {
            var tuple = Lambda.find(productIndexes, t -> t.index == i);
            ordered[i] = tuple != null ? tuple.id : null;
        }
        return ordered;
    }
    // PORT-NOTE: C# LINQ Select+GroupBy+Where+SelectMany → explicit grouping by row.
    private function CompressLayout(idList:Array<NamespaceID>, countPerRow:Int):Array<NamespaceID> {
        var result:Array<NamespaceID> = [];
        var index = 0;
        while (index < idList.length) {
            var group:Array<NamespaceID> = [];
            var rowEnd = Std.int(Math.min(index + countPerRow, idList.length));
            for (i in index...rowEnd) {
                group.push(idList[i]);
            }
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
    // PORT-NOTE: C# numeric format "N0" (thousands separator, no decimals).
    private static function formatN0(value:Int):String {
        var negative = value < 0;
        var s = Std.string(negative ? -value : value);
        var grouped = "";
        var count = 0;
        var i = s.length - 1;
        while (i >= 0) {
            grouped = s.charAt(i) + grouped;
            count++;
            if (count % 3 == 0 && i > 0) grouped = "," + grouped;
            i--;
        }
        return negative ? "-" + grouped : grouped;
    }

    @:translateMsg("商店文本")
    public static inline var PRODUCT_SOLDOUT:String = "<color=red>售罄</color>";

    public var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;
}
