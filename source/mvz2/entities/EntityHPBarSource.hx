package mvz2.entities;

import mvz2.managers.MainManager;
import mvz2.ui.level.HPBar.HPBarViewData;
import mvz2.ui.level.HPBarList;
import mvz2.ui.level.IHPBarSource;
import mvz2logic.entities.HPBarVisibility;
import pvzengine.armors.Armor;
import unity.Color;
import unity.Mathf;
import unity.Vector3;
import mvz2.options.OptionsManager;
import mvz2.ui.level.HPBar;
import Main;
// PORT-NOTE: C# 的扩展方法（this 参数形式）在 Haxe 中需显式 using 才能以 `obj.Method()` 调用。
using mvz2logic.entities.LogicEnemyProps;          // IsPreviewEnemy(this Entity)
using mvz2logic.entities.LogicEntityProps;         // GetHPBarVisibility(this Entity)
using mvz2logic.games.LogicGameDefinitionsExt;     // GetArmorSlotDefinition(this IGameContent)
using mvz2logic.options.LogicOptionExt;            // GetHPBarAmountMode(this IGlobalOptions)

// Ported from: Assets/Scripts/MVZ2/Entities/EntityHPBarSource.cs
class EntityHPBarSource implements IHPBarSource {
    public function new(controller:EntityController) {
        Controller = controller;
    }

    public function IsActive():Bool {
        if (Controller == null)
            return false;
        var entity = Controller.Entity;
        var level = Controller.Level;
        if (entity.IsPreviewEnemy())
            return false;
        var visibility = entity.GetHPBarVisibility();
        var shouldShow = visibility == HPBarVisibility.FORCE || (level.ShouldShowHPBars() && visibility != HPBarVisibility.HIDDEN);
        if (!shouldShow || !Controller.ShouldShowHPBarOnEntity())
            return false;
        return true;
    }
    public function GetPosition():Vector3 {
        var entity = Controller.Entity;
        var groundPos = entity.Position;
        groundPos.y = entity.GetGroundY();
        var groundTransPos = Controller.Level.LawnToTrans(groundPos);
        var position = Controller.transform.position;
        position.y = Mathf.Max(position.y, groundTransPos.y);
        return position + Vector3.up * 0.24;
    }
    public function UpdateHPBarList(list:HPBarList):Void {
        list.gameObject.name = Controller.gameObject.name;
        hpBarBuffer = [];
        GetHPBarViewDatas(hpBarBuffer);

        list.SetBarCount(hpBarBuffer.length);
        for (i in 0...hpBarBuffer.length) {
            list.UpdateBar(i, hpBarBuffer[i]);
        }
    }
    private function GetHPBarViewDatas(hpBarBuffer:Array<HPBarViewData>):Void {
        var amountMode = Main.OptionsManager.GetHPBarAmountMode();

        if (Controller.ShouldShowMainHPBar()) {
            var mainViewData = new HPBarViewData();
            mainViewData.barAmount = Controller.GetMainHPBarAmount();
            mainViewData.barColor = Color.red;
            mainViewData.text = Controller.GetMainHPBarText(amountMode);
            mainViewData.icon = null;
            hpBarBuffer.push(mainViewData);
        }

        var entity = Controller.Entity;
        var level = Controller.Level;
        for (armorSlot in entity.GetActiveArmorSlots()) {
            var armor = entity.GetArmorAtSlot(armorSlot);
            if (armor == null)
                continue;
            var armorSlotDefinition = level.Game.GetArmorSlotDefinition(armorSlot);
            if (armorSlotDefinition == null)
                continue;
            if (!Controller.ShouldShowArmorHPBar(armor))
                continue;

            // PORT-NOTE: C# 的重载 Main.GetFinalSprite(SpriteReference) 在 Haxe 中改名为 GetFinalSpriteFromRef。
            var icon = Main.GetFinalSpriteFromRef(armorSlotDefinition.HPBarIcon);
            var viewData = new HPBarViewData();
            viewData.barAmount = Controller.GetArmorHPBarAmount(armor);
            viewData.barColor = armorSlotDefinition.HPBarColor;
            viewData.text = Controller.GetArmorHPBarText(armor, amountMode);
            viewData.icon = icon;
            hpBarBuffer.push(viewData);
        }
    }
    public var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    public var Controller(default, null):EntityController;
    private var hpBarBuffer:Array<HPBarViewData> = [];
}
