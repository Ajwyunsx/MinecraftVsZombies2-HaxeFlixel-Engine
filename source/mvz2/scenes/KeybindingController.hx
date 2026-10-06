package mvz2.scenes;

import mvz2.managers.MainManager;
import mvz2.ui.keybinding.KeybindingItem;
import mvz2.ui.keybinding.KeybindingPage;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;
import unity.Color;
import unity.Input;
import unity.KeyCode;
import unity.MonoBehaviour;
import mvz2.inputs.InputManager;
import mvz2.localization.LanguageManager;
import mvz2.level.LevelManager;
import Main;
import mvz2.options.OptionsManager;
import mvz2.ui.keybinding.KeybindingItem.KeybindingItemViewData;
import unity.scenemanagement.SceneInstance.Scene;

// Ported from: Assets/Scripts/MVZ2/Scene/KeybindingController.cs
class KeybindingController extends MonoBehaviour {
    // #region 按键绑定
    public function Display():Void {
        bindingKeys = Main.OptionsManager.GetAllKeyBindings();
        bindingKeyIndex = -1;
        UpdateKeybindingItems();
        gameObject.SetActive(true);
    }
    public function Hide():Void {
        gameObject.SetActive(false);
    }
    // #endregion

    // #region 生命周期
    private function Awake():Void {
        ui.OnBackButtonClick.add(OnKeybindingReturnButtonClickCallback);
        ui.OnResetButtonClick.add(OnKeybindingResetButtonClickCallback);
        ui.OnItemButtonClick.add(OnKeybindingItemButtonClickCallback);
    }
    private function Update():Void {
        UpdateKeybindingCheck();
    }
    // #endregion

    // #region 事件回调
    private function OnKeybindingReturnButtonClickCallback():Void {
        bindingKeys = null;
        bindingKeyIndex = -1;
        Hide();
    }
    private function OnKeybindingResetButtonClickCallback():Void {
        var title = Main.LanguageManager._(LogicStrings.WARNING);
        var desc = Main.LanguageManager._(RESET_KEY_BINDINGS_WARNING);
        Main.Scene.ShowDialogSelect(title, desc, function(confirm:Bool) {
            if (confirm) {
                Main.OptionsManager.ResetKeyBindings();
                UpdateKeybindingItems();
            }
        });
    }
    private function OnKeybindingItemButtonClickCallback(index:Int):Void {
        bindingKeyIndex = index;
        UpdateKeybindingItem(index);
    }
    // #endregion

    // #region 私有方法
    private function UpdateKeybindingItems():Void {
        if (bindingKeys == null)
            return;
        var viewDatas:Array<KeybindingItemViewData> = [];
        var conflictKeys = GetConflictKeys();
        for (i in 0...bindingKeys.length) {
            var id = bindingKeys[i];
            var keyCode = Main.OptionsManager.GetKeyBinding(id);
            var conflict = conflictKeys.indexOf(keyCode) >= 0;
            var viewData = GetKeybindingItemViewData(id, i, conflict);
            viewDatas.push(viewData);
        }
        ui.UpdateItems(viewDatas);
    }
    private function UpdateKeybindingItem(index:Int):Void {
        if (bindingKeys == null)
            return;
        var conflictKeys = GetConflictKeys();
        var id = bindingKeys[index];
        var keyCode = Main.OptionsManager.GetKeyBinding(id);
        var conflict = conflictKeys.indexOf(keyCode) >= 0;
        var viewData = GetKeybindingItemViewData(id, index, conflict);
        ui.UpdateItem(index, viewData);
    }
    // PORT-NOTE: C# LINQ GroupBy/Where/Select for duplicate key bindings → explicit grouping.
    private function GetConflictKeys():Array<KeyCode> {
        var counts:Map<Int, Int> = new Map();
        var keys:Array<KeyCode> = [];
        for (k in bindingKeys) {
            var keyCode = Main.OptionsManager.GetKeyBinding(k);
            var asInt:Int = cast keyCode;
            counts.set(asInt, (counts.exists(asInt) ? counts.get(asInt) : 0) + 1);
        }
        for (k in bindingKeys) {
            var keyCode = Main.OptionsManager.GetKeyBinding(k);
            var asInt:Int = cast keyCode;
            if (counts.get(asInt) > 1 && keys.indexOf(keyCode) < 0) keys.push(keyCode);
        }
        return keys;
    }
    private function GetKeybindingItemViewData(id:NamespaceID, index:Int, conflict:Bool):KeybindingItemViewData {
        var nameKey = Main.OptionsManager.GetHotkeyNameKey(id);
        var name = Main.LanguageManager._p(LogicStrings.CONTEXT_HOTKEY_NAME, nameKey);

        var keyCode = Main.OptionsManager.GetKeyBinding(id);
        var keyColor = Color.white;
        var keyName:String;
        if (bindingKeyIndex != index) {
            keyName = Main.InputManager.GetKeyCodeName(keyCode);
            keyColor = conflict ? Color.red : Color.white;
        } else {
            keyName = Main.LanguageManager._(PRESS_KEY_HINT);
        }
        return new KeybindingItemViewData({
            name: name,
            key: keyName,
            keyColor: keyColor
        });
    }
    private function UpdateKeybindingCheck():Void {
        if (bindingKeys == null)
            return;
        if (bindingKeyIndex < 0 || bindingKeyIndex >= bindingKeys.length)
            return;
        if (!Input.anyKeyDown)
            return;
        var code = Main.InputManager.GetCurrentPressedKey();
        if (code == KeyCode.None) {
            bindingKeyIndex = -1;
            UpdateKeybindingItems();
            return;
        }
        if (code == KeyCode.Escape) {
            code = KeyCode.None;
        }
        var id = bindingKeys[bindingKeyIndex];
        bindingKeyIndex = -1;
        Main.OptionsManager.SetKeyBinding(id, code);

        var level = Main.LevelManager.GetLevelController();
        if (level != null) {
            level.UpdateHotkeyTexts();
        }
        UpdateKeybindingItems();
    }
    // #endregion

    @:translateMsg("设置按键提醒")
    public static inline var PRESS_KEY_HINT:String = "请按键";
    @:translateMsg("重置所有按键绑定的警告")
    public static inline var RESET_KEY_BINDINGS_WARNING:String = "确认要重置所有按键绑定吗？";

    private var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    @:serializeField
    private var ui:KeybindingPage = null;
    private var bindingKeys:Array<NamespaceID>;
    private var bindingKeyIndex:Int;
}
