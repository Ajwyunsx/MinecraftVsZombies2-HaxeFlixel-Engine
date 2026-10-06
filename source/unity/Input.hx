package unity;

import flixel.FlxG;

// Minimal UnityEngine.Input shim.
class Input {
    public static var mousePosition(get, never):Vector3;
    static function get_mousePosition():Vector3 {
        // PORT-NOTE: FLX_NO_MOUSE 时 Flixel 不提供 FlxG.mouse（Project.xml 未使用该定义，这里做防御）。
        #if FLX_MOUSE
        return new Vector3(FlxG.mouse.screenX, FlxG.mouse.screenY, 0);
        #else
        return new Vector3(0, 0, 0);
        #end
    }
    public static var mouseScrollDelta(get, never):Vector2;
    static function get_mouseScrollDelta():Vector2 {
        #if FLX_MOUSE
        return new Vector2(0, FlxG.mouse.wheel);
        #else
        return new Vector2(0, 0);
        #end
    }
    public static var anyKeyDown(get, never):Bool;
    static function get_anyKeyDown():Bool {
        // PORT-NOTE: Unity 的 Input.anyKeyDown 是"任意键**或鼠标按键**在本帧被按下"
        // （官方文档：Returns true the first frame the user hits any key or mouse button）。
        // 原实现只查键盘，会让 MVZ2/Scene/KeybindingController.cs:137 的
        // "if (!Input.anyKeyDown) return;" 在只点鼠标时不成立——Unity 上鼠标按下同样进入
        // GetCurrentPressedKey()（返回 None 后取消绑定），这里按 Unity 语义补上鼠标。
        // PORT-NOTE: Project.xml 对 mobile 定义 FLX_NO_KEYBOARD，此时 FlxG.keys 不存在。
        #if FLX_KEYBOARD
        if (FlxG.keys.anyJustPressed(ALL_KEYS)) return true;
        #end
        return anyMouseJustPressed();
    }
    public static var anyKey(get, never):Bool;
    static function get_anyKey():Bool {
        #if FLX_KEYBOARD
        if (FlxG.keys.anyPressed(ALL_KEYS)) return true;
        #end
        return anyMousePressed();
    }
    // PORT-NOTE: FlxG.mouse 由 FlxGame 构造时建立（FlxG.init），在游戏启动前为 null；
    // 这里判空，未初始化时按"没有按键按下"处理。
    static function anyMousePressed():Bool {
        #if FLX_MOUSE
        if (FlxG.mouse == null) return false;
        if (FlxG.mouse.pressed) return true;
        #if FLX_MOUSE_ADVANCED
        if (FlxG.mouse.pressedRight || FlxG.mouse.pressedMiddle) return true;
        #end
        #end
        return false;
    }
    static function anyMouseJustPressed():Bool {
        #if FLX_MOUSE
        if (FlxG.mouse == null) return false;
        if (FlxG.mouse.justPressed) return true;
        #if FLX_MOUSE_ADVANCED
        if (FlxG.mouse.justPressedRight || FlxG.mouse.justPressedMiddle) return true;
        #end
        #end
        return false;
    }
    public static var mousePresent(get, never):Bool;
    static function get_mousePresent():Bool return true;

    // PORT-NOTE: 触屏输入需要 lime 的原生触摸支持，这里给出最小占位实现。
    public static var touchCount(get, never):Int;
    static function get_touchCount():Int return 0;
    public static var touches(get, never):Array<Touch>;
    static function get_touches():Array<Touch> return [];
    public static function GetTouch(index:Int):Touch return new Touch();

    public static function GetKey(key:KeyCode):Bool return KeyCodeMap.isPressed(key);
    public static function GetKeyDown(key:KeyCode):Bool return KeyCodeMap.isJustPressed(key);
    public static function GetKeyUp(key:KeyCode):Bool return KeyCodeMap.isJustReleased(key);
    public static function GetMouseButton(button:Int):Bool return KeyCodeMap.isMousePressed(button);
    public static function GetMouseButtonDown(button:Int):Bool return KeyCodeMap.isMouseJustPressed(button);
    public static function GetMouseButtonUp(button:Int):Bool return KeyCodeMap.isMouseJustReleased(button);
    public static function GetAxis(axisName:String):Float return KeyCodeMap.getAxis(axisName);
    public static function GetAxisRaw(axisName:String):Float return KeyCodeMap.getAxisRaw(axisName);
    public static function GetButton(buttonName:String):Bool return false;
    public static function GetButtonDown(buttonName:String):Bool return false;

    // PORT-NOTE: FlxKey.ANY 是 Flixel 的“任意键”哨兵值，anyPressed/anyJustPressed 支持它。
    private static var ALL_KEYS:Array<flixel.input.keyboard.FlxKey> = [flixel.input.keyboard.FlxKey.ANY];

    public static function ResetInputAxes():Void {}
    public static function SetCursorVisible(visible:Bool):Void {}

    // C#: public static bool simulateMouseWithTouches { get; set; }
    // PORT-NOTE: 移植层没有把触摸转成鼠标点击的行为（MainManager.InitGameSettings 会置为 false），
    // 这里只保留该开关的取值，不产生副作用。
    public static var simulateMouseWithTouches:Bool = true;
}
