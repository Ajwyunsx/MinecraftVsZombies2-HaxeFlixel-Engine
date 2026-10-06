package mvz2.scenes;

import mvz2.managers.MainManager;
import mvz2.ui.credits.CreditsCategory;
import mvz2.ui.credits.CreditsPage;
import mvz2logic.localization.LogicStrings;
import unity.MonoBehaviour;
import mvz2.localization.LanguageManager;
import mvz2.managers.ResourceManager;
import mvz2.ui.credits.CreditsCategory.CreditsCategoryViewData;

// Ported from: Assets/Scripts/MVZ2/Scene/CreditsController.cs
class CreditsController extends MonoBehaviour {
    // #region 制作人员名单
    public function Display():Void {
        var viewDatas:Array<CreditsCategoryViewData> = [];
        var categories = main.ResourceManager.GetAllCreditsCategories();
        for (category in categories) {
            var viewData = new CreditsCategoryViewData({
                name: main.LanguageManager._p(LogicStrings.CONTEXT_CREDITS_CATEGORY, category.Name),
                entries: Lambda.array(Lambda.map(category.Entries, e -> main.LanguageManager._p(LogicStrings.CONTEXT_STAFF_NAME, e))),
            });
            viewDatas.push(viewData);
        }
        ui.UpdateCredits(viewDatas);
        gameObject.SetActive(true);
    }
    public function Hide():Void {
        gameObject.SetActive(false);
    }
    // #endregion

    // #region 生命周期
    private function Awake():Void {
        ui.OnBackButtonClick.add(OnCreditsReturnClickCallback);
    }
    // #endregion

    // #region 事件回调
    private function OnCreditsReturnClickCallback():Void {
        Hide();
    }
    // #endregion

    private var main(get, never):MainManager;
    inline function get_main():MainManager return MainManager.Instance;

    @:serializeField
    private var ui:CreditsPage = null;
}
