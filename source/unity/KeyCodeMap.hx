package unity;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

// Minimal UnityEngine.Input 的键位映射 shim（配合 unity.Input）。
// PORT-NOTE: Unity 的 KeyCode 数值与 Flixel 的 FlxKey 数值大部分不同（例如 Unity A=97、FlxKey A=65），
// 因此需要显式转换；Flixel 里没有对应键的 Unity KeyCode（F13~F15、KeypadEquals、Clear、Help、None…）
// 统一回落 FlxKey.NONE，调用方据此返回 false（"该键不可检测"），见 toFlxKey 的 default 分支。
class KeyCodeMap {
    public static function toFlxKey(key:KeyCode):FlxKey {
        var code:Int = key;
        // PORT-NOTE: Haxe 4.3.7 不支持 `case a...b` 区间模式，这里用 if/else 区间判断。
        if (code >= 97 && code <= 122) return cast(code - 32);          // a-z -> A-Z
        if (code >= 48 && code <= 57) return cast code;                 // Alpha0..Alpha9
        if (code >= 256 && code <= 265) return cast(code - 256 + 96);   // Keypad0..9 -> NUMPADZERO..NINE
        if (code >= 282 && code <= 293) return cast(code - 282 + 112);  // F1..F12
        return switch (code) {
            // PORT-NOTE: Unity 为需要 Shift 的符号单独分配 KeyCode（见 KeyCode.hx），
            // 这些键没有独立的 FlxKey，这里按 US 布局映射回其所在的物理键。
            case 33 | 35 | 36 | 37 | 38 | 40 | 41 | 42 | 64:
                // `!` `#` `$` `%` `&` `(` `)` `*` `@` 分别落在 Shift + 1/3/4/5/7/9/0/8/2
                switch (code) {
                    case 33: FlxKey.ONE;
                    case 35: FlxKey.THREE;
                    case 36: FlxKey.FOUR;
                    case 37: FlxKey.FIVE;
                    case 38: FlxKey.SEVEN;
                    case 40: FlxKey.NINE;
                    case 41: FlxKey.ZERO;
                    case 42: FlxKey.EIGHT;
                    default: FlxKey.TWO; // 64 `@`
                }
            case 34 | 39: FlxKey.QUOTE;
            case 43: FlxKey.PLUS;
            case 58: FlxKey.SEMICOLON;
            case 60: FlxKey.COMMA;
            case 62: FlxKey.PERIOD;
            case 63: FlxKey.SLASH;
            case 94: FlxKey.SIX;
            case 95: FlxKey.MINUS;
            case 123: FlxKey.LBRACKET;
            case 124: FlxKey.BACKSLASH;
            case 125: FlxKey.RBRACKET;
            case 126: FlxKey.GRAVEACCENT;
            case 8: FlxKey.BACKSPACE;
            case 9: FlxKey.TAB;
            case 13: FlxKey.ENTER;
            case 19: FlxKey.BREAK;
            case 27: FlxKey.ESCAPE;
            case 32: FlxKey.SPACE;
            case 44: FlxKey.COMMA;
            case 45: FlxKey.MINUS;
            case 46: FlxKey.PERIOD;
            case 47: FlxKey.SLASH;
            case 59: FlxKey.SEMICOLON;
            case 61: FlxKey.PLUS;                  // Unity Equals
            case 91: FlxKey.LBRACKET;
            case 92: FlxKey.BACKSLASH;
            case 93: FlxKey.RBRACKET;
            case 96: FlxKey.GRAVEACCENT;           // Unity BackQuote
            case 127: FlxKey.DELETE;
            case 266: FlxKey.NUMPADPERIOD;
            case 267: FlxKey.NUMPADSLASH;
            case 268: FlxKey.NUMPADMULTIPLY;
            case 269: FlxKey.NUMPADMINUS;
            case 270: FlxKey.NUMPADPLUS;
            case 271: FlxKey.ENTER;
            case 273: FlxKey.UP;
            case 274: FlxKey.DOWN;
            case 275: FlxKey.RIGHT;
            case 276: FlxKey.LEFT;
            case 277: FlxKey.INSERT;
            case 278: FlxKey.HOME;
            case 279: FlxKey.END;
            case 280: FlxKey.PAGEUP;
            case 281: FlxKey.PAGEDOWN;
            case 300: FlxKey.NUMLOCK;
            case 301: FlxKey.CAPSLOCK;
            case 302: FlxKey.SCROLL_LOCK;
            case 303 | 304: FlxKey.SHIFT;
            case 305 | 306: FlxKey.CONTROL;
            case 307 | 308 | 313: FlxKey.ALT;
            case 309 | 310 | 311 | 312: FlxKey.WINDOWS;
            case 316: FlxKey.PRINTSCREEN;
            case 317 | 318: FlxKey.BREAK;
            case 319: FlxKey.MENU;
            // PORT-NOTE: 其余 Unity KeyCode 在 Flixel 里没有对应键，统一回落 FlxKey.NONE：
            //  · KeyCode.None(0) / Clear(12) / Help(315)：Unity 侧本来就不可检测；
            //  · F13~F15(294~296) / KeypadEquals(272)：FlxKey 没有这些成员，FlxKeyManager
            //    只跟踪 FlxKey.fromStringMap 里的键，这些键在 Flixel 里无法被检测到
            //    （TODO-PORT: MVZ2/Managers/InputManager_Keys.cs:89-91,64 把它们登记为可绑定键，
            //      因此 F13~F15 / 小键盘 = 的绑定在移植版永远触发不了）；
            //  · Mouse0~6(323~329)：不是键盘键，由 isMouseKeyCode 分支单独处理。
            // 原实现回落 "cast code"（即 Unity 的原始数值），而 FlxKey 里不存在这些数值：
            // release 下 checkStatus 恒为 false，debug 下 FlxKeyManager.checkStatus 会
            // throw 'Invalid key code: …'——而 InputManager_Keys.cs 的键表含 F13~F15，
            // InputManager.UpdateKeys 每帧都会遍历到，debug 构建因此在第一帧就抛异常。
            default: FlxKey.NONE;
        };
    }

    // PORT-NOTE: Unity 的 KeyCode.Mouse0..Mouse6（323..329）在 Unity 里可以走
    // Input.GetKey/GetKeyDown/GetKeyUp（C# 的 View/DebugConsole/DebugConsoleInputField.cs:1521
    // 用 Input.GetKeyDown(KeyCode.Mouse0) 判断鼠标左键单击），Flixel 没有对应的 FlxKey，
    // 这里在 GetKey 系列入口单独转发到鼠标按键。
    public static inline function isMouseKeyCode(key:KeyCode):Bool {
        var code:Int = key;
        return code >= 323 && code <= 329;
    }
    // Unity 的鼠标按键索引：KeyCode.Mouse0 → 0，依此类推。
    public static inline function getMouseButtonIndex(key:KeyCode):Int {
        var code:Int = key;
        return code - 323;
    }

    public static function isPressed(key:KeyCode):Bool {
        if (isMouseKeyCode(key)) return isMousePressed(getMouseButtonIndex(key));
        #if FLX_KEYBOARD
        var flxKey = toFlxKey(key);
        // PORT-NOTE: Flixel 的 FlxKey.NONE 语义是"当前没有任何键处于该状态"
        // （FlxBaseKeyList.get_NONE：所有键都不处于该状态时为 true），与 Unity 的
        // KeyCode.None（永远 false）语义相反，必须在这里短路成 false——否则
        // Input.GetKeyDown(KeyCode.None) 会在没有按键时返回 true，而
        // InputManager.UpdateKeys 每帧都会遍历到 KeyCode.None。
        if (flxKey == FlxKey.NONE) return false;
        return FlxG.keys.anyPressed([flxKey]);
        #else
        // PORT-NOTE: Project.xml 对 mobile 定义 FLX_NO_KEYBOARD，FlxDefines 会撤销 FLX_KEYBOARD，
        // 此时 Flixel 不提供 FlxG.keys；对应 Unity 在无键盘设备上 GetKey 恒为 false。
        return false;
        #end
    }
    public static function isJustPressed(key:KeyCode):Bool {
        if (isMouseKeyCode(key)) return isMouseJustPressed(getMouseButtonIndex(key));
        #if FLX_KEYBOARD
        var flxKey = toFlxKey(key);
        if (flxKey == FlxKey.NONE) return false;
        return FlxG.keys.anyJustPressed([flxKey]);
        #else
        return false;
        #end
    }
    public static function isJustReleased(key:KeyCode):Bool {
        if (isMouseKeyCode(key)) return isMouseJustReleased(getMouseButtonIndex(key));
        #if FLX_KEYBOARD
        var flxKey = toFlxKey(key);
        if (flxKey == FlxKey.NONE) return false;
        return FlxG.keys.anyJustReleased([flxKey]);
        #else
        return false;
        #end
    }

    // Unity 的鼠标按键索引：0 = 左键，1 = 右键，2 = 中键。
    // PORT-NOTE: Flixel 的 FlxMouse 只有左/右/中三个键，Unity 的 Mouse3~Mouse6（侧键）
    // 在移植版没有对应实现，按"无该键"返回 false。
    public static function isMousePressed(button:Int):Bool {
        #if !FLX_MOUSE
        return false;
        #else
        return switch (button) {
            case 0: FlxG.mouse.pressed;
            #if FLX_MOUSE_ADVANCED
            case 1: FlxG.mouse.pressedRight;
            case 2: FlxG.mouse.pressedMiddle;
            #end
            default: false;
        };
        #end
    }
    public static function isMouseJustPressed(button:Int):Bool {
        #if !FLX_MOUSE
        return false;
        #else
        return switch (button) {
            case 0: FlxG.mouse.justPressed;
            #if FLX_MOUSE_ADVANCED
            case 1: FlxG.mouse.justPressedRight;
            case 2: FlxG.mouse.justPressedMiddle;
            #end
            default: false;
        };
        #end
    }
    public static function isMouseJustReleased(button:Int):Bool {
        #if !FLX_MOUSE
        return false;
        #else
        return switch (button) {
            case 0: FlxG.mouse.justReleased;
            #if FLX_MOUSE_ADVANCED
            case 1: FlxG.mouse.justReleasedRight;
            case 2: FlxG.mouse.justReleasedMiddle;
            #end
            default: false;
        };
        #end
    }

    // PORT-NOTE: 有了 FLX_MOUSE_ADVANCED（Project.xml 不再定义 FLX_NO_MOUSE_ADVANCED）后，
    // FlxMouse 才提供右键/中键成员。FlxDefines.defineHelperDefines 的推导条件是
    // `!FLX_NO_MOUSE && !FLX_NO_MOUSE_ADVANCED && (!flash || flash11_2)`
    // （flixel/system/macros/FlxDefines.hx:195-196），所以只有显式关掉鼠标、
    // 关掉高级鼠标、或 flash 版本过低时这些分支才会退化为 default → false，
    // 与 Unity 在设备没有对应按键时的结果一致。
    // 本轮改动同时移除了 Project.xml 里的 FLX_NO_MOUSE_ADVANCED，因为原工程确实使用
    // 右键/中键：MVZ2/Map/MapController.cs:479-483（右键拖动地图）、
    // MVZ2/Managers/InputManager.cs:44-74（0..2 三键轮询）、Logic/Inputs/InputHelper.cs:35-39。

    // PORT-NOTE: Unity 的 GetAxis/GetAxisRaw 依赖 InputManager.asset 中的轴定义，
    // 本作 C# 源码未使用任何自定义轴，这里只提供内置默认轴的近似实现。
    public static function getAxis(axisName:String):Float {
        return switch (axisName) {
            case "Horizontal": axisValue(KeyCode.RightArrow, KeyCode.LeftArrow);
            case "Vertical": axisValue(KeyCode.UpArrow, KeyCode.DownArrow);
            case "Fire1", "Jump": (isPressed(KeyCode.LeftControl) || isMousePressed(0)) ? 1 : 0;
            case "Submit": (isJustPressed(KeyCode.Return) || isJustPressed(KeyCode.KeypadEnter)) ? 1 : 0;
            case "Cancel": isJustPressed(KeyCode.Escape) ? 1 : 0;
            default: 0;
        };
    }
    public static function getAxisRaw(axisName:String):Float {
        return switch (axisName) {
            case "Horizontal": axisRawValue(KeyCode.RightArrow, KeyCode.LeftArrow);
            case "Vertical": axisRawValue(KeyCode.UpArrow, KeyCode.DownArrow);
            default: getAxis(axisName);
        };
    }
    static function axisValue(positive:KeyCode, negative:KeyCode):Float {
        var smoothing = 0.1;
        return axisRawValue(positive, negative) * smoothing; // PORT-NOTE: 未模拟 InputManager 的 Gravity/Sensitivity 平滑。
    }
    static function axisRawValue(positive:KeyCode, negative:KeyCode):Float {
        var value = 0.0;
        if (isPressed(positive)) value += 1;
        if (isPressed(negative)) value -= 1;
        return value;
    }
}
