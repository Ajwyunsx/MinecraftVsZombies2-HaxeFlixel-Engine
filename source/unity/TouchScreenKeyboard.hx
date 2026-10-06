package unity;

// Minimal UnityEngine.TouchScreenKeyboard shim.
class TouchScreenKeyboard {
    public static var isSupported:Bool = false;
    // C#: public static bool visible { get; }
    // PORT-NOTE: 移植层没有原生软键盘（见下方 Open 的 TODO-PORT），恒为不可见。
    public static var visible:Bool = false;
    // C#: public static Rect area { get; }
    // PORT-NOTE: Unity 用它取软键盘在屏幕上的矩形（DebugConsoleController 只需要 .height）；
    // 移植层无原生软键盘，返回零矩形。
    public static var area:Rect = new Rect(0, 0, 0, 0);
    public var text:String = "";
    public var active:Bool = false;
    public var done:Bool = false;
    public var wasCanceled:Bool = false;
    public var status:TouchScreenKeyboardStatus = TouchScreenKeyboardStatus.Done;
    public var canGetSelection:Bool = true;
    public var canSetSelection:Bool = true;
    public var selectionStart:Int = 0;
    public var selectionEnd:Int = 0;
    public var characterLimit:Int = 0;
    public var type:Int = 0;
    public var targetDisplay:Int = 0;

    public function new() {}

    public static function Open(text:String, ?keyboardType:Int = 0, ?autocorrect:Bool = true, ?multiline:Bool = false, ?secure:Bool = false, ?alert:Bool = false, ?textPlaceholder:String = "", ?characterLimit:Int = 0):TouchScreenKeyboard {
        // TODO-PORT: 移动端软键盘需要 lime 的原生输入支持。
        return new TouchScreenKeyboard();
    }
}

// Minimal UnityEngine.TouchScreenKeyboard.Status shim.
enum abstract TouchScreenKeyboardStatus(Int) {
    var Visible = 0;
    var Done = 1;
    var Canceled = 2;
    var LostFocus = 3;
}
