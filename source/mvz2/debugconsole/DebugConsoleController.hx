package mvz2.debugconsole;

import mvz2.debugs.DebugManager;
import mvz2.managers.MainManager;
import mvz2.ui.debugconsole.DebugConsoleUI;
import mvz2logic.commands.CommandUtility;
import unity.Application;
import unity.Debug;
import unity.Input;
import unity.KeyCode;
import unity.Mathf;
import unity.MonoBehaviour;
import unity.Screen;
import unity.TouchScreenKeyboard;
import mvz2.inputs.InputManager;
import Main;
import unity.Application.LogType;
import unity.Application.RuntimePlatform;

// Ported from: Assets/Scripts/MVZ2/DebugConsole/DebugConsoleController.cs
class DebugConsoleController extends MonoBehaviour {
    public function Show():Void {
        LoadCommandHistory();
        gameObject.SetActive(true);
        ui.ActivateInputField();
    }
    public function Hide():Void {
        gameObject.SetActive(false);
        historyIndex = -1;
        ui.SetCommand("");
    }
    public function IsActive():Bool {
        return gameObject.activeSelf;
    }
    public function GetCommandHistory():Array<String> {
        return Lambda.array(commandHistory);
    }
    public function SetDefaultCommandPlaceholder():Void {
        if (ui.GetCommand() == null || ui.GetCommand().length == 0) {
            var str = Std.string(CommandUtility.COMMAND_CHARACTER);
            ui.SetCommand(str);
            ui.MoveToCommandEnd(false);
        }
    }
    public function ClearConsole():Void {
        ui.ClearConsole();
    }
    public function Print(text:String):Void {
        ui.Print(text);
    }
    private function Awake():Void {
        ui.OnCloseClick.add(OnCloseCallback);
        ui.OnArrowButtonClick.add(OnArrowButtonClickCallback);
        ui.OnSubmit.add(OnSubmitCallback);
        ui.OnInputFieldValueChanged.add(OnInputFieldValueChangedCallback);
        ui.OnAutoCompleteItemClick.add(OnAutoCompleteItemClickCallback);
        ui.OnAutoCompleteArrowButtonClick.add(OnAutoCompleteArrowButtonClickCallback);
        Application.logMessageReceivedThreaded.push(OnLogReceivedCallback);
    }
    private function Update():Void {
        UpdateUIMargin();

        HandleInputNavigation();
        if (CheckSuggestionDirty()) {
            UpdateInputFieldSuggestions();
        }
        historyNavigated = false;
    }
    private function OnCloseCallback():Void {
        Hide();
    }
    private function OnArrowButtonClickCallback(up:Bool):Void {
        if (up) {
            NavigateHistory(1);
        } else {
            NavigateHistory(-1);
        }
    }
    private function OnSubmitCallback(text:String):Void {
        if (text != null && text.length > 0) {
            AddToHistory(text);
            historyIndex = -1;
            // PORT-NOTE: C# 调用点依赖 DebugManager.ExecuteCommand 的默认参数 count = 1，
            // 但 IGlobalDebug 接口中该参数不可选，Haxe 要求签名一致，这里显式传 1。
            Main.DebugManager.ExecuteCommand(text, 1);
        }
        ui.SetCommand("");
        ui.MoveToCommandEnd(false);
        HideAutoCompletePanel();
        ui.ActivateInputField();
    }
    private function OnInputFieldValueChangedCallback(text:String):Void {
        UpdateInputFieldSuggestions();
    }
    private function OnAutoCompleteItemClickCallback(index:Int):Void {
        var realIndex = GetRealAutoCompleteIndex(index);
        SetSuggestionIndex(realIndex);
        AutoComplete();
        ui.ActivateInputField();
    }
    private function OnAutoCompleteArrowButtonClickCallback(up:Bool):Void {
        var direction = up ? -1 : 1;
        SetSuggestionIndex(Mathf.ClampInt(suggestionIndex + direction * maxSuggestionCount, 0, currentSuggestions.length - 1));
    }
    private function OnLogReceivedCallback(logString:String, stackTrace:String, type:LogType):Void {
        switch (type) {
            case LogType.Log, LogType.Warning:
                return;
            case LogType.Error, LogType.Exception, LogType.Assert:
                Print('<color=red>${logString}</color>\n');
        }
    }

    private function CheckSuggestionDirty():Bool {
        var input = ui.GetCommand();
        var caret = ui.GetStringPosition();
        if (lastInput != input || lastCaret != caret) {
            lastInput = input;
            lastCaret = caret;
            return true;
        }
        return false;
    }
    private function UpdateInputFieldSuggestions():Void {
        // 输入变化时更新自动补全
        var command = ui.GetCommand();
        if (!historyNavigated && command != null && StringTools.startsWith(command, DebugManager.COMMAND_CHARACTER)) {
            UpdateSuggestions(command, ui.GetStringPosition());
        } else {
            HideAutoCompletePanel();
        }
    }
    function HandleInputNavigation():Void {
        if (Main.InputManager.GetKeyDownOrHold(KeyCode.UpArrow)) {
            PressUp();
            return;
        }

        if (Main.InputManager.GetKeyDownOrHold(KeyCode.DownArrow)) {
            PressDown();
            return;
        }

        if (Input.GetKeyDown(KeyCode.Tab)) {
            AutoComplete();
            return;
        }
        if (Input.GetKeyDown(KeyCode.Escape)) {
            Hide();
            return;
        }
    }
    function PressUp():Void {
        if (isAutoCompleteActive) {
            NavigateSuggestions(-1);
        } else {
            NavigateHistory(1);
        }
    }
    function PressDown():Void {
        if (isAutoCompleteActive) {
            NavigateSuggestions(1);
        } else {
            NavigateHistory(-1);
        }
    }

    // #region 自动补全
    private function NavigateSuggestions(direction:Int):Void {
        if (currentSuggestions.length == 0)
            return;

        SetSuggestionIndex((suggestionIndex + direction + currentSuggestions.length) % currentSuggestions.length);
    }

    function UpdateSuggestions(text:String, currentIndex:Int):Void {
        var input = text.substr(0, currentIndex);
        var parts = Main.DebugManager.SplitCommand(input);
        if (parts.length < 1)
            return;

        currentSuggestions = [];
        Main.DebugManager.FillSuggestions(parts, currentSuggestions);
        currentSuggestions.sort(Reflect.compare);

        if (currentSuggestions.length > 0) {
            suggestionIndex = 0;
            currentSuggestionViewStart = 0;
            ShowAutoCompletePanel();
            ui.SetAutoCompletePosition(currentIndex - parts[parts.length - 1].length);
        } else {
            HideAutoCompletePanel();
        }
    }

    function ShowAutoCompletePanel():Void {
        ui.ShowAutoCompletePanel();
        isAutoCompleteActive = true;

        UpdateAutoCompleteSelections();
        UpdateSelectedAutoComplete();
    }
    private function HideAutoCompletePanel():Void {
        ui.HideAutoCompletePanel();
        isAutoCompleteActive = false;
    }
    private function SetSuggestionIndex(index:Int):Void {
        suggestionIndex = index;

        var dirty = false;
        if (suggestionIndex - suggestionMoveMargin < currentSuggestionViewStart && currentSuggestionViewStart > 0) {
            currentSuggestionViewStart = Mathf.MaxInt(suggestionIndex - suggestionMoveMargin, 0);
            dirty = true;
        }
        var end = currentSuggestionViewStart + maxSuggestionCount;
        if (suggestionIndex + suggestionMoveMargin >= end && currentSuggestions.length > end) {
            end = Mathf.MinInt(suggestionIndex + suggestionMoveMargin, currentSuggestions.length);
            currentSuggestionViewStart = end - maxSuggestionCount;
            dirty = true;
        }
        if (dirty) {
            UpdateAutoCompleteSelections();
        }
        UpdateSelectedAutoComplete();
    }
    private function UpdateAutoCompleteSelections():Void {
        // PORT-NOTE: C# LINQ Skip/Take.
        var suggestions:Array<String> = [];
        var end = Std.int(Math.min(currentSuggestionViewStart + maxSuggestionCount, currentSuggestions.length));
        for (i in currentSuggestionViewStart...end) suggestions.push(currentSuggestions[i]);
        var hasAbove = currentSuggestionViewStart > 0;
        var hasBelow = currentSuggestionViewStart + maxSuggestionCount < currentSuggestions.length - 1;
        ui.SetAutoCompleteSelections(suggestions, GetUIAutoCompleteIndex(suggestionIndex), hasAbove, hasBelow);
    }
    private function UpdateSelectedAutoComplete():Void {
        var uiIndex = GetUIAutoCompleteIndex(suggestionIndex);
        ui.SetCurrentAutoComplete(uiIndex);
    }
    private function GetRealAutoCompleteIndex(uiIndex:Int):Int {
        return uiIndex + currentSuggestionViewStart;
    }
    private function GetUIAutoCompleteIndex(index:Int):Int {
        return index - currentSuggestionViewStart;
    }

    private function AutoComplete():Void {
        if (currentSuggestions.length == 0 || suggestionIndex < 0)
            return;

        var fullText = ui.GetCommand();
        var caretIndex = ui.GetStringPosition();
        var beforeText = fullText.substr(0, caretIndex);
        var afterText = fullText.substr(caretIndex);

        var splitedBefore = Main.DebugManager.SplitCommand(beforeText);
        // PORT-NOTE: C# `SkipLast(1)`.
        var newBeforeTextParts = splitedBefore.slice(0, Std.int(Math.max(0, splitedBefore.length - 1)));
        var newBeforeText = newBeforeTextParts.join(" ");

        var completedText = currentSuggestions[suggestionIndex];
        if (newBeforeText != null && StringTools.trim(newBeforeText).length > 0) {
            completedText = newBeforeText + " " + completedText;
        }
        completedText = DebugManager.COMMAND_CHARACTER + completedText;
        ui.SetCommand(completedText + afterText);
        ui.SetStringPosition(completedText.length);

        UpdateInputFieldSuggestions();
    }
    // #endregion


    // #region 历史

    function SaveCommandHistory():Void {
        if (!keepHistoryBetweenSessions)
            return;
        Main.DebugManager.SaveCommandHistory(commandHistory);
    }

    function LoadCommandHistory():Void {
        if (!keepHistoryBetweenSessions)
            return;

        commandHistory = [];
        Main.DebugManager.LoadCommandHistory(commandHistory);
    }
    private function AddToHistory(command:String):Void {
        // 避免添加重复的命令
        commandHistory.remove(command);
        commandHistory.insert(0, command);

        // 限制历史记录大小
        while (commandHistory.length > maxHistorySize) {
            commandHistory.splice(commandHistory.length - 1, 1);
        }

        SaveCommandHistory();
    }
    private function NavigateHistory(direction:Int):Void {
        if (commandHistory.length == 0)
            return;

        historyIndex = Mathf.ClampInt(historyIndex + direction, -1, commandHistory.length - 1);

        var command = "";
        if (historyIndex >= 0) {
            command = commandHistory[historyIndex];
        }
        ui.SetCommand(command);
        ui.MoveToCommandEnd(false);
        historyNavigated = true;
    }
    // #endregion

    private function UpdateUIMargin():Void {
        ui.SetConsoleBottomMargin(GetKeyboardHeight() / Screen.height);
    }
    private function GetKeyboardHeight():Float {
        if (Application.isEditor) {
            return debugKeyboardHeight;
        } else if (Application.platform == RuntimePlatform.Android) {
            // PORT-NOTE: C# 判断 `TouchScreenKeyboard.isSupported && TouchScreenKeyboard.visible`；
            // Haxe 的 unity shim 未提供 static visible/area，且移动端软键盘需要原生支持，
            // 这里退化为仅检查 isSupported（下方实现本就返回 0）。
            if (TouchScreenKeyboard.isSupported)
                return GetKeyboardHeightAndroid();
        } else if (Application.platform == RuntimePlatform.IPhonePlayer) {
            if (TouchScreenKeyboard.isSupported)
                return GetSoftKeyboardHeightIos();
        }
        return 0;
    }
    private function GetSoftKeyboardHeightIos():Float {
        // TODO-PORT: C# 用 `TouchScreenKeyboard.area.height` 取 iOS 软键盘高度，
        // unity shim 未提供 area/visible 静态成员，Haxe 侧也无原生软键盘 API，返回 0。
        return 0;
    }
    private function GetKeyboardHeightAndroid():Float {
        // TODO-PORT: the AndroidJavaClass/AndroidJavaObject interop used to measure the soft
        // keyboard height has no Haxe equivalent; return 0 instead.
        return 0;
    }
    public var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    private var commandHistory:Array<String> = [];
    private var historyIndex:Int = -1;
    private var currentSuggestions:Array<String> = [];
    private var currentSuggestionViewStart:Int = 0;
    private var suggestionIndex:Int;
    private var isAutoCompleteActive:Bool;

    private var lastInput:String;
    private var lastCaret:Int = -1;
    private var historyNavigated:Bool;
    @:serializeField
    private var debugKeyboardHeight:Float = 0;
    @:serializeField
    private var keepHistoryBetweenSessions:Bool = true;
    @:serializeField
    private var maxHistorySize:Int = 100;
    @:serializeField
    private var suggestionMoveMargin:Int = 1;
    @:serializeField
    private var maxSuggestionCount:Int = 10;
    @:serializeField
    private var ui:DebugConsoleUI = null;
}
