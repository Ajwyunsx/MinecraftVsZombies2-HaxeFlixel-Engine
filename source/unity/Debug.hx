package unity;

// Minimal UnityEngine.Debug shim.
class Debug {
    public static var logger:Dynamic = null;

    public static function Log(message:Dynamic, ?context:UnityObject):Void {
        var text = Std.string(message);
        trace(text);
        Application.dispatchLog(text, haxe.CallStack.toString(haxe.CallStack.exceptionStack()), Application.LogType.Log);
    }
    public static function LogWarning(message:Dynamic, ?context:UnityObject):Void {
        var text = Std.string(message);
        trace('[WARN] ' + text);
        Application.dispatchLog(text, haxe.CallStack.toString(haxe.CallStack.exceptionStack()), Application.LogType.Warning);
    }
    public static function LogError(message:Dynamic, ?context:UnityObject):Void {
        var text = Std.string(message);
        trace('[ERROR] ' + text);
        Application.dispatchLog(text, haxe.CallStack.toString(haxe.CallStack.exceptionStack()), Application.LogType.Error);
    }
    public static function LogException(exception:Dynamic, ?context:UnityObject):Void {
        var text = Std.string(exception);
        trace('[EXCEPTION] ' + text);
        Application.dispatchLog(text, haxe.CallStack.toString(haxe.CallStack.exceptionStack()), Application.LogType.Exception);
    }
    public static function Assert(condition:Bool, ?message:Dynamic):Void {
        if (!condition) trace('[ASSERT] ' + message);
    }
}
