package unity;

// Minimal UnityEngine.ColorUtility shim.
//
// PORT-NOTE: 原实现用 `Std.parseInt(pair)` 解析十六进制对，而 Haxe 的 `Std.parseInt` 不认裸十六进制：
// `Std.parseInt("FF")` → null、`Std.parseInt("7F")` → 7（静默截断到 "7"）。结果是所有 `#RRGGBB` /
// `#RRGGBBAA` 颜色都解析失败或取到错值（cpp 全量 Meta 加载日志里 106 条
// `Cannot create property "mvz2:bloodColor"/"tint"/"lightColor" ... of type "color"`）。
// 现按 UnityEngine.ColorUtility 的语义重写（对照 UnityCsReference
// Runtime/Export/Math/ColorUtility.cs）：
//   * 以 '#' 开头 → 十六进制：#RGB / #RGBA / #RRGGBB / #RRGGBBAA（大小写不敏感；逐位校验必须
//     全是十六进制字符；缺省 alpha = FF；长度为 5、7 或 >9 等非法长度一律 false）。
//   * 不以 '#' 开头 → 具名颜色表（red/cyan/…/magenta，大小写不敏感），表外名字 false。
//     （Unity 2022.3 文档列出的表以 "magenta.." 结尾，此处的 "transparent" 取自同版本 UnityCsReference
//     的 HtmlColorNames；游戏数据里没有非 '#' 前缀的颜色串用到它。）
class ColorUtility {
    private static var HTML_COLOR_NAMES:Array<String> = [
        "red", "cyan", "blue", "darkblue", "lightblue", "purple", "yellow", "lime",
        "fuchsia", "white", "silver", "grey", "black", "orange", "brown", "maroon",
        "green", "olive", "navy", "teal", "aqua", "magenta", "transparent"
    ];
    // 与 HTML_COLOR_NAMES 一一对应，按 [r, g, b, a] 展开成字节
    // （不用 0xRRGGBBAA 打包：32 位字面量在 hxcpp 上会超出 Int32 范围）。
    private static var HTML_COLOR_BYTES:Array<Int> = [
        0xff, 0x00, 0x00, 0xff, // red
        0x00, 0xff, 0xff, 0xff, // cyan
        0x00, 0x00, 0xff, 0xff, // blue
        0x00, 0x00, 0x8b, 0xff, // darkblue
        0xad, 0xd8, 0xe6, 0xff, // lightblue
        0x80, 0x00, 0x80, 0xff, // purple
        0xff, 0xff, 0x00, 0xff, // yellow
        0x00, 0xff, 0x00, 0xff, // lime
        0xff, 0x00, 0xff, 0xff, // fuchsia
        0xff, 0xff, 0xff, 0xff, // white
        0xc0, 0xc0, 0xc0, 0xff, // silver
        0x80, 0x80, 0x80, 0xff, // grey
        0x00, 0x00, 0x00, 0xff, // black
        0xff, 0xa5, 0x00, 0xff, // orange
        0xa5, 0x2a, 0x2a, 0xff, // brown
        0x80, 0x00, 0x00, 0xff, // maroon
        0x00, 0x80, 0x00, 0xff, // green
        0x80, 0x80, 0x00, 0xff, // olive
        0x00, 0x00, 0x80, 0xff, // navy
        0x00, 0x80, 0x80, 0xff, // teal
        0x00, 0xff, 0xff, 0xff, // aqua
        0xff, 0x00, 0xff, 0xff, // magenta
        0x00, 0x00, 0x00, 0x00  // transparent
    ];

    public static function TryParseHtmlString(htmlString:String, color:{value:Color}):Bool {
        if (htmlString == null) return false;
        var s = StringTools.trim(htmlString);
        if (s.length == 0) return false;
        if (s.charAt(0) == "#") {
            if (s.length > 9) return false; // 最长 "#RRGGBBAA"
            var hex = s.substr(1);
            if (!isHexString(hex)) return false;
            if (hex.length == 3 || hex.length == 4) {
                // "#RGB" → "#RRGGBB"，"#RGBA" → "#RRGGBBAA"
                var expanded = new StringBuf();
                for (i in 0...hex.length) {
                    var c = hex.charAt(i);
                    expanded.add(c);
                    expanded.add(c);
                }
                hex = expanded.toString();
            }
            return tryParseHexColor(hex, color);
        }
        var lower = s.toLowerCase();
        for (i in 0...HTML_COLOR_NAMES.length) {
            if (lower == HTML_COLOR_NAMES[i]) {
                var base = i * 4;
                color.value = new Color(
                    HTML_COLOR_BYTES[base] / 255,
                    HTML_COLOR_BYTES[base + 1] / 255,
                    HTML_COLOR_BYTES[base + 2] / 255,
                    HTML_COLOR_BYTES[base + 3] / 255);
                return true;
            }
        }
        return false;
    }

    private static function isHexString(s:String):Bool {
        for (i in 0...s.length) {
            if (hexDigitValue(s.charCodeAt(i)) < 0) return false;
        }
        return true;
    }

    // 逐对解析字节：任一位不是十六进制字符即失败。返回 -1 表示失败（字节值域 0..255）。
    private static function hexByteAt(hex:String, index:Int):Int {
        var hi = hexDigitValue(hex.charCodeAt(index));
        var lo = hexDigitValue(hex.charCodeAt(index + 1));
        if (hi < 0 || lo < 0) return -1;
        return (hi << 4) | lo;
    }

    private static function hexDigitValue(c:Int):Int {
        if (c >= "0".code && c <= "9".code) return c - "0".code;
        if (c >= "a".code && c <= "f".code) return c - "a".code + 10;
        if (c >= "A".code && c <= "F".code) return c - "A".code + 10;
        return -1;
    }

    private static function tryParseHexColor(hex:String, color:{value:Color}):Bool {
        if (hex.length != 6 && hex.length != 8) return false;
        var r = hexByteAt(hex, 0);
        var g = hexByteAt(hex, 2);
        var b = hexByteAt(hex, 4);
        if (r < 0 || g < 0 || b < 0) return false;
        var a = 0xff;
        if (hex.length == 8) {
            a = hexByteAt(hex, 6);
            if (a < 0) return false;
        }
        color.value = new Color(r / 255, g / 255, b / 255, a / 255);
        return true;
    }

    public static function ToHtmlStringRGB(color:Color):String {
        return '${hex(color.r)}${hex(color.g)}${hex(color.b)}';
    }
    public static function ToHtmlStringRGBA(color:Color):String {
        return '${hex(color.r)}${hex(color.g)}${hex(color.b)}${hex(color.a)}';
    }
    // PORT-NOTE: Unity 用 `Mathf.Clamp(Mathf.RoundToInt(v * 255), 0, 255)`（四舍五入，修复 1.0 被截成 FE 的
    // 历史 bug）并以 "X2" 输出大写十六进制；原实现用 `Std.int(v * 255)`（截断）+ 小写输出，已改齐。
    // 注：Unity 的 Mathf.RoundToInt 是银行家舍入，本机 unity.Mathf shim 用 Math.round（.5 远离零），
    // 只有恰好落在 x.5 的值才有差异，颜色数据不可达。
    private static function hex(v:Float):String {
        var i = Std.int(Mathf.Clamp(Mathf.RoundToInt(v * 255), 0, 255));
        return StringTools.hex(i, 2).toUpperCase();
    }
}
