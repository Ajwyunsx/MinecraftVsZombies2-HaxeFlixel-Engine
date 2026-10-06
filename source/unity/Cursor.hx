package unity;

// Minimal UnityEngine.Cursor shim.
class Cursor {
    public static var visible:Bool = true;
    public static var lockState:CursorLockMode = CursorLockMode.None;

    // C#: public static void SetCursor(Texture2D texture, Vector2 hotspot, CursorMode cursorMode)
    // PORT-NOTE: CursorManager 传了 CursorMode.Auto，故第三个参数做成可选的（Haxe 无重载）；
    // 光标贴图切换由移植层 UI 处理，这里保留调用点语义。
    public static function SetCursor(cursor:Dynamic, hotspot:Vector2, ?cursorMode:CursorMode = CursorMode.Auto):Void {}
}

// C#: UnityEngine.CursorMode
enum abstract CursorMode(Int) {
    var Auto = 0;
    var ForceSoftware = 1;
}
