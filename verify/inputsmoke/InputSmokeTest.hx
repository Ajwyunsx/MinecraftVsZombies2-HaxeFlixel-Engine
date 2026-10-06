// PORT-NOTE: 验证用（不参与游戏构建，Project.xml 的 source path 只含 source/）。
// 鼠标/键盘输入路径（unity.KeyCodeMap / unity.Input）的冒烟测试：
//   ① Unity KeyCode → FlxKey 的映射表（97 组：字母/数字/功能键/小键盘/符号键/修饰键/导航键，
//      其中 87 组可映射、10 组在 Flixel 里无法检测（必须回落 FlxKey.NONE））；
//   ② KeyCode 全域穷举：0..359 里每个值映射后只能是 FlxKey 里真实存在的键或 NONE，
//      否则 FlxKeyManager.checkStatus 在 debug 构建下会 throw 'Invalid key code: …'
//      （InputManager_Keys.cs 的键表含 F13~F15，InputManager.UpdateKeys 每帧都会查到）；
//   ③ 编译期 define 断言（FLX_MOUSE_ADVANCED / FLX_NO_MOUSE_ADVANCED / FLX_KEYBOARD / FLX_MOUSE…）；
//   ④ 运行期（需要真实 FlxGame，见 InputSmokeState）：鼠标三键的路由（0 左 / 1 右 / 2 中）、
//      与 Unity KeyCode.Mouse0~2 在 GetKey/GetKeyDown/GetKeyUp 里的转发。
//
// 运行：
//   bash HaxePort/tools_build/check_input.sh --neko    # ①②③（无 FlxGame，自动跳过 ④）
//   bash HaxePort/tools_build/check_input.sh --cpp     # 同上，跑在游戏同一目标上
//   bash HaxePort/tools_build/check_input.sh --window  # 真实 lime 窗口工程，④ 全跑
package inputsmoke;

import flixel.FlxG;
import flixel.input.mouse.FlxMouseButton;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import unity.Input;
import unity.KeyCode;
import unity.KeyCodeMap;

private typedef KeyRow = {code:KeyCode, expected:Int, label:String};
private typedef FK = flixel.input.keyboard.FlxKey;

class InputSmokeTest {
    private static var checks:Int = 0;
    private static var failures:Array<String> = [];
    private static var notes:Array<String> = [];

    public static function main():Void {
        runAll(false);
    }

    public static function runAll(liveMouse:Bool):Void {
        section('① Unity KeyCode → FlxKey 映射表');
        checkKeyTable();
        section('② KeyCode 全域穷举（只允许 FlxKey 里真实存在的键）');
        checkKeyDomain();
        section('③ 编译期 define');
        checkDefines();
        section('④ 运行期：鼠标三键路由 + KeyCode.MouseN 转发');
        if (liveMouse) {
            checkMouseRouting();
        } else {
            note('当前没有 FlxGame（控制台模式），④ 跳过；用 tools_build/check_input.sh --window 跑真实窗口工程。');
        }
        finish();
    }

    // ───────────────────────── ① 映射表 ─────────────────────────

    private static function checkKeyTable():Void {
        var rows:Array<KeyRow> = [
            // 字母（Unity 97..122 → FlxKey 65..90）
            row(KeyCode.A, FK.A, "KeyCode.A → FlxKey.A"),
            row(KeyCode.M, FK.M, "KeyCode.M → FlxKey.M"),
            row(KeyCode.Z, FK.Z, "KeyCode.Z → FlxKey.Z"),
            // 主键区数字（Unity 48..57 与 FlxKey 同值）
            row(KeyCode.Alpha0, FK.ZERO, "KeyCode.Alpha0 → FlxKey.ZERO"),
            row(KeyCode.Alpha5, FK.FIVE, "KeyCode.Alpha5 → FlxKey.FIVE"),
            row(KeyCode.Alpha9, FK.NINE, "KeyCode.Alpha9 → FlxKey.NINE"),
            // 功能键（Unity 282..293 → FlxKey 112..123）
            row(KeyCode.F1, FK.F1, "KeyCode.F1 → FlxKey.F1"),
            row(KeyCode.F2, FK.F2, "KeyCode.F2 → FlxKey.F2"),
            row(KeyCode.F5, FK.F5, "KeyCode.F5 → FlxKey.F5"),
            row(KeyCode.F10, FK.F10, "KeyCode.F10 → FlxKey.F10"),
            row(KeyCode.F12, FK.F12, "KeyCode.F12 → FlxKey.F12"),
            // 小键盘（Unity 256..271 → FlxKey 96..111 / ENTER）
            row(KeyCode.Keypad0, FK.NUMPADZERO, "KeyCode.Keypad0 → FlxKey.NUMPADZERO"),
            row(KeyCode.Keypad3, FK.NUMPADTHREE, "KeyCode.Keypad3 → FlxKey.NUMPADTHREE"),
            row(KeyCode.Keypad5, FK.NUMPADFIVE, "KeyCode.Keypad5 → FlxKey.NUMPADFIVE"),
            row(KeyCode.Keypad9, FK.NUMPADNINE, "KeyCode.Keypad9 → FlxKey.NUMPADNINE"),
            row(KeyCode.KeypadPeriod, FK.NUMPADPERIOD, "KeyCode.KeypadPeriod → FlxKey.NUMPADPERIOD"),
            row(KeyCode.KeypadDivide, FK.NUMPADSLASH, "KeyCode.KeypadDivide → FlxKey.NUMPADSLASH"),
            row(KeyCode.KeypadMultiply, FK.NUMPADMULTIPLY, "KeyCode.KeypadMultiply → FlxKey.NUMPADMULTIPLY"),
            row(KeyCode.KeypadMinus, FK.NUMPADMINUS, "KeyCode.KeypadMinus → FlxKey.NUMPADMINUS"),
            row(KeyCode.KeypadPlus, FK.NUMPADPLUS, "KeyCode.KeypadPlus → FlxKey.NUMPADPLUS"),
            row(KeyCode.KeypadEnter, FK.ENTER, "KeyCode.KeypadEnter → FlxKey.ENTER"),
            // 编辑 / 控制键
            row(KeyCode.Backspace, FK.BACKSPACE, "KeyCode.Backspace → FlxKey.BACKSPACE"),
            row(KeyCode.Tab, FK.TAB, "KeyCode.Tab → FlxKey.TAB"),
            row(KeyCode.Return, FK.ENTER, "KeyCode.Return → FlxKey.ENTER"),
            row(KeyCode.Escape, FK.ESCAPE, "KeyCode.Escape → FlxKey.ESCAPE"),
            row(KeyCode.Space, FK.SPACE, "KeyCode.Space → FlxKey.SPACE"),
            row(KeyCode.Delete, FK.DELETE, "KeyCode.Delete → FlxKey.DELETE"),
            // 导航键
            row(KeyCode.UpArrow, FK.UP, "KeyCode.UpArrow → FlxKey.UP"),
            row(KeyCode.DownArrow, FK.DOWN, "KeyCode.DownArrow → FlxKey.DOWN"),
            row(KeyCode.LeftArrow, FK.LEFT, "KeyCode.LeftArrow → FlxKey.LEFT"),
            row(KeyCode.RightArrow, FK.RIGHT, "KeyCode.RightArrow → FlxKey.RIGHT"),
            row(KeyCode.Insert, FK.INSERT, "KeyCode.Insert → FlxKey.INSERT"),
            row(KeyCode.Home, FK.HOME, "KeyCode.Home → FlxKey.HOME"),
            row(KeyCode.End, FK.END, "KeyCode.End → FlxKey.END"),
            row(KeyCode.PageUp, FK.PAGEUP, "KeyCode.PageUp → FlxKey.PAGEUP"),
            row(KeyCode.PageDown, FK.PAGEDOWN, "KeyCode.PageDown → FlxKey.PAGEDOWN"),
            // 需要 Shift 的符号（Unity 给每个符号一个 KeyCode，FlxKey 里回到它所在的物理键）
            row(KeyCode.Exclaim, FK.ONE, "KeyCode.Exclaim(!) → FlxKey.ONE"),
            row(KeyCode.At, FK.TWO, "KeyCode.At(@) → FlxKey.TWO"),
            row(KeyCode.Hash, FK.THREE, "KeyCode.Hash(#) → FlxKey.THREE"),
            row(KeyCode.Dollar, FK.FOUR, "KeyCode.Dollar($) → FlxKey.FOUR"),
            row(KeyCode.Percent, FK.FIVE, "KeyCode.Percent(%) → FlxKey.FIVE"),
            row(KeyCode.Caret, FK.SIX, "KeyCode.Caret(^) → FlxKey.SIX"),
            row(KeyCode.Ampersand, FK.SEVEN, "KeyCode.Ampersand(&) → FlxKey.SEVEN"),
            row(KeyCode.Asterisk, FK.EIGHT, "KeyCode.Asterisk(*) → FlxKey.EIGHT"),
            row(KeyCode.LeftParen, FK.NINE, "KeyCode.LeftParen('(') → FlxKey.NINE"),
            row(KeyCode.RightParen, FK.ZERO, "KeyCode.RightParen(')') → FlxKey.ZERO"),
            row(KeyCode.Underscore, FK.MINUS, "KeyCode.Underscore(_) → FlxKey.MINUS"),
            row(KeyCode.Plus, FK.PLUS, "KeyCode.Plus(+) → FlxKey.PLUS"),
            row(KeyCode.Tilde, FK.GRAVEACCENT, "KeyCode.Tilde(~) → FlxKey.GRAVEACCENT"),
            row(KeyCode.Pipe, FK.BACKSLASH, "KeyCode.Pipe(|) → FlxKey.BACKSLASH"),
            row(KeyCode.LeftCurlyBracket, FK.LBRACKET, "KeyCode.LeftCurlyBracket('{') → FlxKey.LBRACKET"),
            row(KeyCode.RightCurlyBracket, FK.RBRACKET, "KeyCode.RightCurlyBracket('}') → FlxKey.RBRACKET"),
            row(KeyCode.Colon, FK.SEMICOLON, "KeyCode.Colon(:) → FlxKey.SEMICOLON"),
            row(KeyCode.DoubleQuote, FK.QUOTE, "KeyCode.DoubleQuote('\"') → FlxKey.QUOTE"),
            row(KeyCode.Quote, FK.QUOTE, "KeyCode.Quote(\"'\") → FlxKey.QUOTE"),
            row(KeyCode.Question, FK.SLASH, "KeyCode.Question(?) → FlxKey.SLASH"),
            row(KeyCode.Less, FK.COMMA, "KeyCode.Less(<) → FlxKey.COMMA"),
            row(KeyCode.Greater, FK.PERIOD, "KeyCode.Greater(>) → FlxKey.PERIOD"),
            // 普通符号键
            row(KeyCode.Comma, FK.COMMA, "KeyCode.Comma(,) → FlxKey.COMMA"),
            row(KeyCode.Period, FK.PERIOD, "KeyCode.Period(.) → FlxKey.PERIOD"),
            row(KeyCode.Minus, FK.MINUS, "KeyCode.Minus(-) → FlxKey.MINUS"),
            row(KeyCode.Slash, FK.SLASH, "KeyCode.Slash(/) → FlxKey.SLASH"),
            row(KeyCode.Semicolon, FK.SEMICOLON, "KeyCode.Semicolon(;) → FlxKey.SEMICOLON"),
            row(KeyCode.Equals, FK.PLUS, "KeyCode.Equals(=) → FlxKey.PLUS"),
            row(KeyCode.LeftBracket, FK.LBRACKET, "KeyCode.LeftBracket('[') → FlxKey.LBRACKET"),
            row(KeyCode.RightBracket, FK.RBRACKET, "KeyCode.RightBracket(']') → FlxKey.RBRACKET"),
            row(KeyCode.Backslash, FK.BACKSLASH, "KeyCode.Backslash(\\) → FlxKey.BACKSLASH"),
            row(KeyCode.BackQuote, FK.GRAVEACCENT, "KeyCode.BackQuote(`) → FlxKey.GRAVEACCENT"),
            // 锁 / 修饰 / 系统键
            row(KeyCode.Numlock, FK.NUMLOCK, "KeyCode.Numlock → FlxKey.NUMLOCK"),
            row(KeyCode.CapsLock, FK.CAPSLOCK, "KeyCode.CapsLock → FlxKey.CAPSLOCK"),
            row(KeyCode.ScrollLock, FK.SCROLL_LOCK, "KeyCode.ScrollLock → FlxKey.SCROLL_LOCK"),
            row(KeyCode.Print, FK.PRINTSCREEN, "KeyCode.Print → FlxKey.PRINTSCREEN"),
            row(KeyCode.Menu, FK.MENU, "KeyCode.Menu → FlxKey.MENU"),
            row(KeyCode.Pause, FK.BREAK, "KeyCode.Pause → FlxKey.BREAK"),
            row(KeyCode.SysReq, FK.BREAK, "KeyCode.SysReq → FlxKey.BREAK"),
            row(KeyCode.Break, FK.BREAK, "KeyCode.Break → FlxKey.BREAK"),
            row(KeyCode.LeftShift, FK.SHIFT, "KeyCode.LeftShift → FlxKey.SHIFT"),
            row(KeyCode.RightShift, FK.SHIFT, "KeyCode.RightShift → FlxKey.SHIFT"),
            row(KeyCode.LeftControl, FK.CONTROL, "KeyCode.LeftControl → FlxKey.CONTROL"),
            row(KeyCode.RightControl, FK.CONTROL, "KeyCode.RightControl → FlxKey.CONTROL"),
            row(KeyCode.LeftAlt, FK.ALT, "KeyCode.LeftAlt → FlxKey.ALT"),
            row(KeyCode.RightAlt, FK.ALT, "KeyCode.RightAlt → FlxKey.ALT"),
            row(KeyCode.AltGr, FK.ALT, "KeyCode.AltGr → FlxKey.ALT"),
            row(KeyCode.LeftWindows, FK.WINDOWS, "KeyCode.LeftWindows → FlxKey.WINDOWS"),
            row(KeyCode.RightWindows, FK.WINDOWS, "KeyCode.RightWindows → FlxKey.WINDOWS"),
            row(KeyCode.LeftCommand, FK.WINDOWS, "KeyCode.LeftCommand → FlxKey.WINDOWS"),
            row(KeyCode.RightCommand, FK.WINDOWS, "KeyCode.RightCommand → FlxKey.WINDOWS"),
            // Flixel 里无法检测（FlxKey 没有对应成员）→ 必须回落 NONE，由 isPressed 系列短路成 false
            row(KeyCode.None, FK.NONE, "KeyCode.None → FlxKey.NONE（不可检测）"),
            row(KeyCode.Clear, FK.NONE, "KeyCode.Clear → FlxKey.NONE（不可检测）"),
            row(KeyCode.Help, FK.NONE, "KeyCode.Help → FlxKey.NONE（不可检测）"),
            row(KeyCode.F13, FK.NONE, "KeyCode.F13 → FlxKey.NONE（不可检测）"),
            row(KeyCode.F14, FK.NONE, "KeyCode.F14 → FlxKey.NONE（不可检测）"),
            row(KeyCode.F15, FK.NONE, "KeyCode.F15 → FlxKey.NONE（不可检测）"),
            row(KeyCode.KeypadEquals, FK.NONE, "KeyCode.KeypadEquals → FlxKey.NONE（不可检测）"),
            row(KeyCode.Mouse0, FK.NONE, "KeyCode.Mouse0 → FlxKey.NONE（走鼠标分支）"),
            row(KeyCode.Mouse1, FK.NONE, "KeyCode.Mouse1 → FlxKey.NONE（走鼠标分支）"),
            row(KeyCode.Mouse2, FK.NONE, "KeyCode.Mouse2 → FlxKey.NONE（走鼠标分支）"),
        ];
        Sys.println('  映射表条目=' + rows.length);
        for (r in rows) {
            var actualInt:Int = KeyCodeMap.toFlxKey(r.code);
            checks++;
            if (actualInt != r.expected) {
                failures.push(r.label + ' 实际=' + keyName(actualInt));
            }
        }
    }

    // ───────────────────────── ② 全域穷举 ─────────────────────────

    // PORT-NOTE: FlxKeyboard 只用 FlxKey.fromStringMap 里的键建立 _keyListMap
    // （FlxKeyboard.hx:27-36），落到别的数值上会在 debug 构建下触发
    // FlxKeyManager.checkStatus 的 `throw 'Invalid key code: …'`。
    private static function checkKeyDomain():Void {
        var tracked = new Map<Int, Bool>();
        var trackedCount = 0;
        for (value in FK.fromStringMap) {
            var iv:Int = value;
            if (!tracked.exists(iv)) {
                tracked.set(iv, true);
                trackedCount++;
            }
        }
        Sys.println('  FlxKey 实际跟踪的键数=' + trackedCount);
        var scanned = 0;
        var bad = 0;
        for (code in 0...360) {
            var mapped:Int = KeyCodeMap.toFlxKey(code);
            scanned++;
            if (mapped == FK.NONE) continue; // 语义为"不可检测"
            if (mapped == FK.ANY) {
                bad++;
                failures.push('KeyCode ' + code + ' 映射到了 FlxKey.ANY（语义是"任意键"，会被误判）');
                continue;
            }
            if (!tracked.exists(mapped)) {
                bad++;
                failures.push('KeyCode ' + code + ' 映射到 FlxKey 未跟踪的数值 ' + mapped
                    + '（debug 构建下 FlxKeyManager.checkStatus 会 throw Invalid key code）');
            }
        }
        checks++;
        Sys.println('  扫描 KeyCode 0..' + (scanned - 1) + ' 共 ' + scanned + ' 个值，非法映射=' + bad);
    }

    // ───────────────────────── ③ define ─────────────────────────

    private static function checkDefines():Void {
        requireDefine('FLX_MOUSE_ADVANCED', #if FLX_MOUSE_ADVANCED true #else false #end);
        absentDefine('FLX_NO_MOUSE_ADVANCED', #if FLX_NO_MOUSE_ADVANCED true #else false #end);
        requireDefine('FLX_MOUSE', #if FLX_MOUSE true #else false #end);
        #if desktop
        requireDefine('FLX_KEYBOARD', #if FLX_KEYBOARD true #else false #end);
        #end
        // Project.xml 只在 release 定义 FLX_NO_DEBUG，故它随构建类型变化，仅报告不判定。
        reportDefine('FLX_NO_TOUCH', #if FLX_NO_TOUCH true #else false #end);
        reportDefine('FLX_NO_DEBUG', #if FLX_NO_DEBUG true #else false #end);
    }

    // ───────────────────────── ④ 运行期鼠标 ─────────────────────────

    private static function checkMouseRouting():Void {
        #if FLX_MOUSE
        if (FlxG.mouse == null) {
            note('FlxG.mouse 为 null，④ 全部跳过');
            return;
        }
        if (FlxG.keys == null) {
            note('FlxG.keys 为 null（FLX_KEYBOARD 关闭）');
        } else {
            // PORT-NOTE: 机制探测（不计入断言，只作为证据打印）：FlxKeyManager.checkStatus 对
            // "FlxKey 里不存在的键码" 在 debug 构建下 throw 'Invalid key code: …'、release 下返回 false。
            // 这正是 KeyCodeMap 不能把无法映射的 Unity 键回落成原始数值的原因
            // （InputManager.UpdateKeys 每帧都会查 F13~F15，debug 构建会在第一帧就抛异常）。
            var untrackedProbe = 294; // Unity KeyCode.F13，FlxKey 里没有这个成员
            try {
                var result = FlxG.keys.anyJustPressed([untrackedProbe]);
                probe('FlxG.keys.anyJustPressed([' + untrackedProbe + ']) 返回 ' + result + '（release 行为：静默 false）');
            } catch (e:Dynamic) {
                probe('FlxG.keys.anyJustPressed([' + untrackedProbe + ']) 抛出 ' + Std.string(e) + '（debug 行为：throw Invalid key code）');
            }
        }
        #if FLX_MOUSE_ADVANCED
        // PORT-NOTE: 直接把 FlxMouseButton 推进 PRESSED / JUST_RELEASED 状态，等价于真实鼠标事件
        // 经 FlxMouseButton.onDown/onUp 的效果（onDown 只是多查一个 FlxG.mouse.enabled 与录像取消键，
        // 见 FlxMouseButton.hx:47-73）。每个断言之间都 reset，避免互相污染。
        var ids:Array<FlxMouseButtonID> = [FlxMouseButtonID.LEFT, FlxMouseButtonID.RIGHT, FlxMouseButtonID.MIDDLE];
        for (i in 0...3) {
            resetMouseButtons();
            var button = FlxMouseButton.getByID(ids[i]);
            if (button == null) {
                failures.push('FlxMouseButton.getByID(' + mouseIDName(i) + ') 返回 null');
                continue;
            }
            button.press();
            eq(KeyCodeMap.isMouseJustPressed(i), true, '按下鼠标键 ' + mouseIDName(i) + '（索引 ' + i + '）后 isMouseJustPressed(' + i + ')');
            eq(KeyCodeMap.isMousePressed(i), true, '按下鼠标键 ' + mouseIDName(i) + ' 后 isMousePressed(' + i + ')');
            eq(KeyCodeMap.isMouseJustReleased(i), false, '按下鼠标键 ' + mouseIDName(i) + ' 后 isMouseJustReleased(' + i + ') 应为 false');
            for (j in 0...3) {
                if (j != i) eq(KeyCodeMap.isMousePressed(j), false, '按下鼠标键 ' + mouseIDName(i) + ' 时 isMousePressed(' + j + ') 应为 false');
            }
            if (i == 0) eq(Input.anyKeyDown, true, '无键盘输入、仅鼠标左键刚按下时 Input.anyKeyDown 应为 true');
            button.release();
            eq(KeyCodeMap.isMouseJustReleased(i), true, '松开鼠标键 ' + mouseIDName(i) + ' 后 isMouseJustReleased(' + i + ')');
            eq(KeyCodeMap.isMousePressed(i), false, '松开鼠标键 ' + mouseIDName(i) + ' 后 isMousePressed(' + i + ') 应为 false');
        }
        resetMouseButtons();

        // Unity KeyCode.Mouse0~2 在 GetKey 系列里转发到鼠标按键（C# 用 GetKeyDown(KeyCode.Mouse0)）
        var mouseKeys:Array<KeyCode> = [KeyCode.Mouse0, KeyCode.Mouse1, KeyCode.Mouse2];
        for (i in 0...3) {
            resetMouseButtons();
            var button = FlxMouseButton.getByID(ids[i]);
            if (button == null) continue;
            button.press();
            eq(Input.GetKey(mouseKeys[i]), true, 'Input.GetKey(KeyCode.Mouse' + i + ') 跟随鼠标键 ' + mouseIDName(i));
            eq(Input.GetKeyDown(mouseKeys[i]), true, 'Input.GetKeyDown(KeyCode.Mouse' + i + ') 跟随鼠标键 ' + mouseIDName(i));
            for (j in 0...3) {
                if (j != i) eq(Input.GetKey(mouseKeys[j]), false, '按下鼠标键 ' + mouseIDName(i) + ' 时 GetKey(KeyCode.Mouse' + j + ') 应为 false');
            }
            button.release();
            eq(Input.GetKeyUp(mouseKeys[i]), true, 'Input.GetKeyUp(KeyCode.Mouse' + i + ') 跟随鼠标键 ' + mouseIDName(i));
        }
        resetMouseButtons();
        #else
        note('当前构建没有 FLX_MOUSE_ADVANCED，鼠标三键断言跳过（右键/中键不可用）');
        #end

        // Unity 侧不可检测的键必须返回 false（不能因为 FlxKey.NONE 的"无键按下即为 true"语义而反判）
        var undetectable:Array<KeyCode> = [
            KeyCode.None, KeyCode.Clear, KeyCode.Help, KeyCode.F13, KeyCode.F14, KeyCode.F15, KeyCode.KeypadEquals
        ];
        for (code in undetectable) {
            eq(Input.GetKey(code), false, 'Input.GetKey(' + code + ') 应为 false（不可检测）');
            eq(Input.GetKeyDown(code), false, 'Input.GetKeyDown(' + code + ') 应为 false（不可检测）');
            eq(Input.GetKeyUp(code), false, 'Input.GetKeyUp(' + code + ') 应为 false（不可检测）');
        }
        #else
        note('当前构建没有 FLX_MOUSE，鼠标断言跳过');
        #end
    }

    private static function resetMouseButtons():Void {
        #if (FLX_MOUSE && FLX_MOUSE_ADVANCED)
        var ids:Array<FlxMouseButtonID> = [FlxMouseButtonID.LEFT, FlxMouseButtonID.RIGHT, FlxMouseButtonID.MIDDLE];
        for (id in ids) {
            var b = FlxMouseButton.getByID(id);
            if (b != null) b.reset();
        }
        #end
    }

    private static function mouseIDName(index:Int):String {
        return switch (index) {
            case 0: '左键';
            case 1: '右键';
            case 2: '中键';
            default: '<' + index + '>';
        };
    }

    // ───────────────────────── 工具 ─────────────────────────

    private static function row(code:KeyCode, expected:Int, label:String):KeyRow {
        return {code: code, expected: expected, label: label};
    }

    private static function keyName(value:Int):String {
        var name = flixel.input.keyboard.FlxKey.toStringMap.get(value);
        return name == null ? '<' + value + '>' : name + '(' + value + ')';
    }

    private static function eq(actual:Dynamic, expected:Dynamic, label:String):Void {
        checks++;
        if (actual != expected) {
            failures.push(label + ' 期望=' + Std.string(expected) + ' 实际=' + Std.string(actual));
        }
    }

    private static function requireDefine(name:String, defined:Bool):Void {
        Sys.println('  [define] ' + name + ' = ' + (defined ? '已定义' : '未定义') + (defined ? ' ✓' : ' ✗'));
        if (!defined) {
            checks++;
            failures.push('define ' + name + ' 应定义但未定义');
        }
    }

    private static function absentDefine(name:String, defined:Bool):Void {
        Sys.println('  [define] ' + name + ' = ' + (defined ? '已定义 ✗' : '未定义 ✓'));
        if (defined) {
            checks++;
            failures.push('define ' + name + ' 不应定义');
        }
    }

    private static function reportDefine(name:String, defined:Bool):Void {
        Sys.println('  [define] ' + name + ' = ' + (defined ? '已定义' : '未定义') + '（仅报告）');
    }

    private static function section(title:String):Void {
        Sys.println('\n[InputSmoke] ' + title);
    }

    private static function note(msg:String):Void {
        notes.push(msg);
        Sys.println('  [skip] ' + msg);
    }

    // PORT-NOTE: 只打印、不计入断言/失败（用于把"机制/环境事实"留在日志里作为证据）。
    private static function probe(msg:String):Void {
        Sys.println('  [probe] ' + msg);
    }

    private static function finish():Void {
        Sys.println('');
        for (f in failures) Sys.println('[InputSmoke] FAIL ' + f);
        Sys.println('[InputSmoke] 断言数=' + checks + ' 失败=' + failures.length + ' 跳过/说明=' + notes.length);
        Sys.exit(failures.length == 0 ? 0 : 1);
    }
}
