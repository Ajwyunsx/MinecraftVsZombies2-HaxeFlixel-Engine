package mvz2.addons;

import mvz2.io.FileHelper;
import mvz2.managers.MainManager;
import mvz2.ui.addons.LanguagePacksUI;
import mvz2.localization.LanguagePack;
import mvz2.localization.LanguageManager;
import mvz2logic.localization.LogicStrings;
import unity.Debug;
import unity.MonoBehaviour;
import unity.Task;
import unity.Time;
import Main;
import system.io.Path;
import mvz2.localization.LanguageManager.LanguagePackReference;
import mvz2.localization.LanguagePack.LanguagePackMetadata;
import mvz2.ui.addons.LanguagePacksUI.Buttons;
import mvz2.ui.addons.LanguagePackItem.LanguagePackViewData;
import unity.scenemanagement.SceneInstance.Scene;

// Ported from: Assets/Scripts/MVZ2/Addons/LanguagePacksController.cs
// PORT-NOTE: C# async/await is translated as follows: `async Task M()` keeps its Task return
// type, `await t` becomes `t.awaitResult()` (a non-blocking read of the task result), and
// `async void` becomes Void. Truly asynchronous gaps (file dialogs) need callbacks.
class LanguagePacksController extends MonoBehaviour {
    public function Display():Task {
        // 加载语言包引用。
        RefreshLanguagePacks().awaitResult();
        references = [];
        references = references.concat(Main.LanguageManager.GetAllLanguagePackReferences());
        var originPreference = Main.LanguageManager.GetEnabledLanguagePackList();
        enabledReferences = [];
        enabledReferences = enabledReferences.concat(originPreference);

        gameObject.SetActive(true);

        // 更新UI。
        CancelSelection();
        UpdateLanguagePacks();
        return Task.completedTask();
    }
    public function Hide():Void {
        gameObject.SetActive(false);
    }
    // #region 生命周期
    private function Awake():Void {
        ui.OnButtonClick.add(OnButtonClickCallback);
        ui.OnPackItemToggled.add(OnPackItemToggledCallback);
    }
    private function Update():Void {
        refreshInterval -= Time.deltaTime;
        if (refreshInterval <= 0) {
            RefreshLanguagePacks();
        }
    }
    // #endregion

    // #region 事件回调
    private function OnButtonClickCallback(button:Buttons):Void {
        switch (button) {
            case Buttons.Return:
                if (IsDirty()) {
                    overridedFile = false;
                    addons.SetLoadingVisible(true);
                    // PORT-NOTE: LanguageManager.ReloadLanguagePacks 在 Haxe 端口返回 Void（不是 Task），故无需 awaitResult。
                    Main.LanguageManager.ReloadLanguagePacks(enabledReferences.copy());
                    addons.SetLoadingVisible(false);
                }
                Hide();
                addons.DisplayIndex();
            case Buttons.Import:
                {
                    // PORT-NOTE: local `async void importAction(string path)` is kept as a local function.
                    var importAction = function(path:String):Void {
                        addons.SetLoadingVisible(true);
                        try {
                            var key = Main.LanguageManager.GetImportKey(path);
                            if (key != null && key.length > 0) {
                                var reference = Lambda.find(references, r -> r.GetKey() == key);
                                if (reference != null) {
                                    var metadata = Main.LanguageManager.GetLanguagePackMetadata(reference);
                                    var languagePackName = (metadata != null && metadata.name != null) ? metadata.name : key;
                                    var title = Main.LanguageManager._(LogicStrings.WARNING);
                                    var desc = Main.LanguageManager._(WARNING_OVERRIDE_LANGUAGE_PACK, [languagePackName]);
                                    var result:Bool = Main.Scene.ShowDialogSelectAsync(title, desc).awaitResult();
                                    if (!result) {
                                        return;
                                    }
                                    Main.LanguageManager.DeleteLanguagePack(reference);
                                    overridedFile = true;
                                }
                                var valid:Bool = Main.LanguageManager.ValidateLanguagePack(path);
                                if (!valid) {
                                    var title = Main.LanguageManager._(LogicStrings.ERROR);
                                    var desc = Main.LanguageManager._(ERROR_FAILED_TO_IMPORT);
                                    Main.Scene.ShowDialogMessage(title, desc);
                                    return;
                                }
                                Main.LanguageManager.ImportLanguagePack(path);
                                RefreshLanguagePacks().awaitResult();
                            }
                        } catch (e:Dynamic) {
                            Debug.LogError('导入语言包时出现错误：${e}');
                        }
                        addons.SetLoadingVisible(false);
                    };
                    FileHelper.OpenExternalFile(["zip"], importAction).awaitResult();
                }
            case Buttons.Export:
                {
                    var selected = selectedLanguagePack;
                    if (selected != null) {
                        var key = selected.GetKey();
                        var success = false;
                        var fileName = haxe.io.Path.withoutExtension(selected.GetFileName());
                        // PORT-NOTE: local `async dest => {...}` lambda keeps Void signature.
                        var saveAction = function(dest:String):Void {
                            if (!references.contains(selected))
                                return;
                            success = Main.LanguageManager.ExportLanguagePack(selected, dest);
                        };
                        var path:String = FileHelper.SaveExternalFile(fileName, ["zip"], saveAction).awaitResult();
                        if (path == null || path.length == 0)
                            return;
                        if (!success) {
                            var title = Main.LanguageManager._(LogicStrings.ERROR);
                            var desc = Main.LanguageManager._(ERROR_NOT_SAVED);
                            Main.Scene.ShowDialogMessageAsync(title, desc).awaitResult();
                        } else {
                            var title = Main.LanguageManager._(LogicStrings.HINT);
                            var desc = Main.LanguageManager._(HINT_SAVED, [path]);
                            Main.Scene.ShowDialogMessageAsync(title, desc).awaitResult();
                        }
                    }
                }
            case Buttons.Delete:
                {
                    var selected = selectedLanguagePack;
                    if (selected != null) {
                        var key = selected.GetFileName();
                        var metadata = Main.LanguageManager.GetLanguagePackMetadata(selected);
                        var languagePackName = (metadata != null && metadata.name != null) ? metadata.name : key;
                        var title = Main.LanguageManager._(LogicStrings.WARNING);
                        var desc = Main.LanguageManager._(WARNING_DELETE_LANGUAGE_PACK, [languagePackName]);
                        var result:Bool = Main.Scene.ShowDialogSelectAsync(title, desc).awaitResult();
                        if (result) {
                            Main.LanguageManager.DeleteLanguagePack(selected);
                            RefreshLanguagePacks().awaitResult();
                        }
                    }
                }
            case Buttons.Disable:
                if (selectedLanguagePack != null) {
                    enabledReferences.remove(selectedLanguagePack);
                    UpdateLanguagePacks();
                    UpdateButtonInteractions();
                    ui.SelectItemUI(false, GetItemUIIndex(false, selectedLanguagePack));
                }
            case Buttons.Enable:
                if (selectedLanguagePack != null && !enabledReferences.contains(selectedLanguagePack)) {
                    enabledReferences.insert(0, selectedLanguagePack);
                    UpdateLanguagePacks();
                    UpdateButtonInteractions();
                    ui.SelectItemUI(true, GetItemUIIndex(true, selectedLanguagePack));
                }
            case Buttons.MoveUp:
                if (selectedLanguagePack != null && enabledReferences.contains(selectedLanguagePack)) {
                    var index = enabledReferences.indexOf(selectedLanguagePack);
                    if (index > 0) {
                        enabledReferences.remove(selectedLanguagePack);
                        enabledReferences.insert(index - 1, selectedLanguagePack);
                        UpdateLanguagePacks();
                        UpdateButtonInteractions();
                        ui.SelectItemUI(true, GetItemUIIndex(true, selectedLanguagePack));
                    }
                }
            case Buttons.MoveDown:
                if (selectedLanguagePack != null && enabledReferences.contains(selectedLanguagePack)) {
                    var index = enabledReferences.indexOf(selectedLanguagePack);
                    if (index < enabledReferences.length - 1) {
                        enabledReferences.remove(selectedLanguagePack);
                        enabledReferences.insert(index + 1, selectedLanguagePack);
                        UpdateLanguagePacks();
                        UpdateButtonInteractions();
                        ui.SelectItemUI(true, GetItemUIIndex(true, selectedLanguagePack));
                    }
                }
        }
    }
    private function OnPackItemToggledCallback(enabled:Bool, index:Int, value:Bool):Void {
        var reference = GetLanguagePackReferenceByUI(enabled, index);
        if (value) {
            selectedLanguagePack = reference;
            UpdateButtonInteractions();
        } else if (selectedLanguagePack == reference) {
            selectedLanguagePack = null;
            UpdateButtonInteractions();
        }
    }
    // #endregion

    private function RefreshLanguagePacks():Task {
        refreshInterval = maxRefreshInterval;
        var changed:Bool = Main.LanguageManager.RefreshLanguagePackReferences();
        if (changed) {
            references = [];
            references = references.concat(Main.LanguageManager.GetAllLanguagePackReferences());
            enabledReferences = enabledReferences.filter(r -> references.contains(r));
            UpdateLanguagePacks();
            CancelSelection();
        }
        return Task.completedTask();
    }
    private function CancelSelection():Void {
        selectedLanguagePack = null;
        ui.DeselectAll();
        UpdateButtonInteractions();
    }
    private function UpdateLanguagePacks():Void {
        var disabled = GetDisabledReferences();
        var disabledViewDatas = Lambda.array(Lambda.map(Lambda.filter(Lambda.map(disabled, r -> Main.LanguageManager.GetLanguagePackMetadata(r)), p -> Std.isOfType(p, LanguagePackMetadata)), p -> GetLanguagePackViewData(cast p)));
        var enabledViewDatas = Lambda.array(Lambda.map(Lambda.filter(Lambda.map(enabledReferences, r -> Main.LanguageManager.GetLanguagePackMetadata(r)), p -> Std.isOfType(p, LanguagePackMetadata)), p -> GetLanguagePackViewData(cast p)));
        ui.SetDisabledLanguagePacks(disabledViewDatas);
        ui.SetEnabledLanguagePacks(enabledViewDatas);
    }
    private function UpdateButtonInteractions():Void {
        var selected = selectedLanguagePack != null;
        var isBuiltin = selectedLanguagePack != null && selectedLanguagePack.IsBuiltin;
        var enabled = selectedLanguagePack != null && enabledReferences.contains(selectedLanguagePack);
        var index = selectedLanguagePack != null ? enabledReferences.indexOf(selectedLanguagePack) : -1;
        ui.SetButtonInteractable(Buttons.Delete, selected && !isBuiltin);
        ui.SetButtonInteractable(Buttons.Export, selected);
        ui.SetButtonInteractable(Buttons.Disable, enabled && selected && !isBuiltin);
        ui.SetButtonInteractable(Buttons.Enable, !enabled && selected && !isBuiltin);
        ui.SetButtonInteractable(Buttons.MoveUp, enabled && selected && index > 0);
        ui.SetButtonInteractable(Buttons.MoveDown, enabled && selected && index < enabledReferences.length - 1);
    }
    private function GetDisabledReferences():Array<LanguagePackReference> {
        return references.filter(r -> !enabledReferences.contains(r));
    }
    private function IsDirty():Bool {
        if (overridedFile) return true;
        return !arrayEquals(enabledReferences, Main.LanguageManager.GetEnabledLanguagePackList());
    }
    private function GetLanguagePackReferenceByUI(enabled:Bool, index:Int):LanguagePackReference {
        if (enabled) {
            return enabledReferences[index];
        } else {
            var disabled = GetDisabledReferences();
            return index >= 0 && index < disabled.length ? disabled[index] : null;
        }
    }
    private function GetItemUIIndex(enabled:Bool, reference:LanguagePackReference):Int {
        if (enabled) {
            return enabledReferences.indexOf(reference);
        } else {
            var disabled = GetDisabledReferences();
            return disabled.indexOf(reference);
        }
    }
    private function GetLanguagePackViewData(metadata:LanguagePackMetadata):LanguagePackViewData {
        return new LanguagePackViewData({
            name: metadata.name != null ? metadata.name : "",
            description: metadata.description != null ? metadata.description : "",
            icon: metadata.icon,
        });
    }
    // PORT-NOTE: C# `enabledReferences.SequenceEqual(other)` helper.
    private static function arrayEquals(a:Array<LanguagePackReference>, b:Array<LanguagePackReference>):Bool {
        if (a == null || b == null) return a == b;
        if (a.length != b.length) return false;
        for (i in 0...a.length) {
            if (a[i] != b[i]) return false;
        }
        return true;
    }

    @:translateMsg("覆盖语言包的警告，{0}为语言包名称")
    public static inline var WARNING_OVERRIDE_LANGUAGE_PACK:String = "已经存在同名语言包“{0}”，是否覆盖？";
    @:translateMsg("删除语言包的警告，{0}为语言包名称")
    public static inline var WARNING_DELETE_LANGUAGE_PACK:String = "是否删除语言包“{0}”？";
    @:translateMsg("语言包导出失败的警告")
    public static inline var ERROR_NOT_SAVED:String = "导出语言包失败。";
    @:translateMsg("语言包导入失败的警告")
    public static inline var ERROR_FAILED_TO_IMPORT:String = "导入语言包失败。";
    @:translateMsg("语言包导出成功的提示，{0}为路径")
    public static inline var HINT_SAVED:String = "语言包已导出至{0}。";

    public var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    @:serializeField
    private var addons:AddonsController = null;
    @:serializeField
    private var ui:LanguagePacksUI = null;
    @:serializeField
    private var maxRefreshInterval:Float = 1;
    private var overridedFile:Bool;
    private var selectedLanguagePack:LanguagePackReference;
    private var enabledReferences:Array<LanguagePackReference> = [];
    private var references:Array<LanguagePackReference> = [];
    private var refreshInterval:Float;
}
