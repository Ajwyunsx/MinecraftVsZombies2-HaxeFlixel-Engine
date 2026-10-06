// Ported from: Assets/Scripts/Logic/ParseHelper.cs
package mvz2logic;

import unity.Vector2;
import unity.Vector2Int;
import unity.Vector3;
import unity.Vector3Int;

// C# 的 out 参数在 Haxe 中用 { value : T } 引用包装代替。
typedef OutInt = { value:Int }
typedef OutLong = { value:haxe.Int64 }
typedef OutFloat = { value:Float }
typedef OutVector2 = { value:Vector2 }
typedef OutVector3 = { value:Vector3 }
typedef OutVector2Int = { value:Vector2Int }
typedef OutVector3Int = { value:Vector3Int }

class ParseHelper {
    // PORT-NOTE: ParseInt/ParseFloat 对应 C# 的 int.Parse/float.Parse（失败抛异常）。Haxe 侧
    // Std.parseInt/Std.parseFloat 失败时返回 null/NaN 而不是抛异常，语义无法完全对齐（调用点见
    // TalkController.ParseArgumentInt/ParseArgumentFloat、CommandUtility.ParseInt/ParseFloat）。
    public static function ParseInt(str:String):Int {
        return Std.parseInt(str);
    }

    public static function ParseFloat(str:String):Float {
        return Std.parseFloat(str);
    }

    // PORT-NOTE: 以下 Try* 系列对应 C# 的
    //   int.TryParse(str, NumberStyles.Integer, InvariantCulture, out …)
    //   long.TryParse(str, NumberStyles.Integer, InvariantCulture, out …)
    //   float.TryParse(str, NumberStyles.Float, InvariantCulture, out …)
    //   double.TryParse(str, NumberStyles.Float, InvariantCulture, out …)
    // 原实现直接包了 Std.parseInt/Std.parseFloat，但 Haxe 的宽容度与 .NET 不同：
    //   Std.parseInt("0x10")  → 16     （C#：false，NumberStyles.Integer 不认十六进制）
    //   Std.parseInt("12abc") → 12     （C#：false，不接受尾随垃圾）
    //   Std.parseInt("9999999999")     （C#：false，溢出即失败）
    //   Std.parseFloat("1.5x") → 1.5   （C#：false）
    // 结果是 XML 里的坏数据会被静默当成合法数字（如 int 属性 "12abc" 变成 12）。现按 .NET 的
    // 语法 + 范围严格校验（允许首尾空白、前导 +/-；只认十进制与科学计数法；其余一律 false）。
    public static function TryParseInt(str:String, parsed:OutInt):Bool {
        var v = tryParseIntStrict(str);
        if (v == null) {
            parsed.value = 0;
            return false;
        }
        parsed.value = v;
        return true;
    }

    public static function TryParseLong(str:String, parsed:OutLong):Bool {
        var v = tryParseLongStrict(str);
        if (v == null) {
            parsed.value = haxe.Int64.ofInt(0);
            return false;
        }
        parsed.value = v;
        return true;
    }

    public static function TryParseFloat(str:String, parsed:OutFloat):Bool {
        var v = tryParseFloatStrict(str);
        if (v == null) {
            parsed.value = 0;
            return false;
        }
        parsed.value = v;
        return true;
    }

    public static function TryParseDouble(str:String, parsed:OutFloat):Bool {
        return TryParseFloat(str, parsed);
    }

    // #region .NET 数字语法严格解析
    private static inline function digitValue(c:Int):Int {
        return (c >= "0".code && c <= "9".code) ? c - "0".code : -1;
    }

    // 剥掉首尾空白与可选前导符号并校验「纯十进制数字」，返回去前导零后的数字串；失败返回 null。
    // 范围校验（Int32/Int64 溢出即失败）由调用方按各自的 limit 完成。
    private static function scanDigits(str:String, negative:{value:Bool}):Null<String> {
        if (str == null)
            return null;
        var s = StringTools.trim(str);
        negative.value = false;
        var i = 0;
        if (i < s.length) {
            var c = s.charCodeAt(i);
            if (c == "-".code) {
                negative.value = true;
                i++;
            } else if (c == "+".code) {
                i++;
            }
        }
        if (i >= s.length)
            return null;
        var digits = new StringBuf();
        while (i < s.length) {
            var d = digitValue(s.charCodeAt(i));
            if (d < 0)
                return null;
            digits.addChar("0".code + d);
            i++;
        }
        var text = digits.toString();
        var start = 0;
        while (start < text.length - 1 && text.charCodeAt(start) == "0".code)
            start++;
        return text.substr(start);
    }

    // 同长度的纯数字串按字典序比较即数值比较（Float/Int 都不能安全承载 19 位数字，故不走数值）。
    private static function exceedsLimit(text:String, limit:String):Bool {
        if (text.length != limit.length)
            return text.length > limit.length;
        return compareNumericStrings(text, limit) > 0;
    }

    // C# NumberStyles.Integer（Int32）。
    private static function tryParseIntStrict(str:String):Null<Int> {
        var negative = {value: false};
        var text = scanDigits(str, negative);
        if (text == null)
            return null;
        if (exceedsLimit(text, negative.value ? "2147483648" : "2147483647"))
            return null;
        // PORT-NOTE: 不能用 Float/Int 累加器判溢出 —— Haxe 会把 `accum = accum * 10 + d` 按 Int32 运算
        // （实测 214748364*10+8 → -2147483648，neko/cpp 同），到不了溢出阈值就已经回绕。
        // 先做字符串级范围校验，再交给 Int64 累加，避免任何回绕假设。
        var value = parseDigitStringAsInt64(text);
        return haxe.Int64.toInt(negative.value ? haxe.Int64.neg(value) : value);
    }

    // C# NumberStyles.Integer 的 64 位版本。
    private static function tryParseLongStrict(str:String):Null<haxe.Int64> {
        var negative = {value: false};
        var text = scanDigits(str, negative);
        if (text == null)
            return null;
        var limit = negative.value ? "9223372036854775808" : "9223372036854775807";
        if (exceedsLimit(text, limit))
            return null;
        if (negative.value && compareNumericStrings(text, limit) == 0)
            return haxe.Int64.make(0x80000000, 0); // Int64.MinValue：累加会先回绕，直接给出
        var value = parseDigitStringAsInt64(text);
        return negative.value ? haxe.Int64.neg(value) : value;
    }

    // 纯数字串 → Int64（调用方需保证不会溢出）。
    private static function parseDigitStringAsInt64(text:String):haxe.Int64 {
        var value = haxe.Int64.ofInt(0);
        var ten = haxe.Int64.ofInt(10);
        for (k in 0...text.length) {
            value = haxe.Int64.add(haxe.Int64.mul(value, ten), haxe.Int64.ofInt(text.charCodeAt(k) - "0".code));
        }
        return value;
    }

    // 两个等长纯数字串的数值比较（字典序等价）。
    private static function compareNumericStrings(a:String, b:String):Int {
        for (i in 0...a.length) {
            var d = a.charCodeAt(i) - b.charCodeAt(i);
            if (d != 0)
                return d > 0 ? 1 : -1;
        }
        return 0;
    }

    // C# NumberStyles.Float：允许首尾空白、前导 +/-、十进制小数点与指数。
    // 语法：[+/-] ( 数字[.数字*] | .数字+ ) [eE [+/-] 数字+ ]
    private static function tryParseFloatStrict(str:String):Null<Float> {
        if (str == null)
            return null;
        var s = StringTools.trim(str);
        var i = 0;
        var len = s.length;
        if (i < len && (s.charCodeAt(i) == "-".code || s.charCodeAt(i) == "+".code))
            i++;
        var intDigits = 0;
        while (i < len && digitValue(s.charCodeAt(i)) >= 0) {
            i++;
            intDigits++;
        }
        var fracDigits = 0;
        if (i < len && s.charCodeAt(i) == ".".code) {
            i++;
            while (i < len && digitValue(s.charCodeAt(i)) >= 0) {
                i++;
                fracDigits++;
            }
        }
        if (intDigits + fracDigits == 0)
            return null;
        if (i < len && (s.charCodeAt(i) == "e".code || s.charCodeAt(i) == "E".code)) {
            i++;
            if (i < len && (s.charCodeAt(i) == "-".code || s.charCodeAt(i) == "+".code))
                i++;
            var expDigits = 0;
            while (i < len && digitValue(s.charCodeAt(i)) >= 0) {
                i++;
                expDigits++;
            }
            if (expDigits == 0)
                return null;
        }
        if (i != len)
            return null;
        var value = Std.parseFloat(s);
        // .NET（Unity 用的 Mono 运行时同 .NET Framework）遇到超出 Single 范围的值返回 false，
        // Haxe 得到 ±Infinity；这里同样判失败。注：C# 会把 "NaN"/"Infinity" 字面量解析成功，
        // 本实现按语法拒绝（游戏数据里不存在，不影响 1:1 还原）。
        if (!Math.isFinite(value))
            return null;
        return value;
    }
    // #endregion

    public static function GetVectorNumberStrings(str:String):Array<String> {
        var left = str.indexOf("[");
        var right = str.indexOf("]");
        var substring = str.substring(left + 1, right);
        return substring.split(",");
    }

    public static function TryParseVector2(str:String, parsed:OutVector2):Bool {
        parsed.value = Vector2.zero;
        var numbers = GetVectorNumberStrings(str);
        if (numbers.length != 2)
            return false;
        var v = new Vector2();
        for (i in 0...2) {
            var number = numbers[i];
            var trimed = StringTools.trim(number);
            var component:OutFloat = { value: 0 };
            if (TryParseFloat(trimed, component)) {
                // PORT-NOTE: unity.Vector2 值语义类不支持下标访问，改为按分量赋值。
                switch (i)
                {
                	case 0: v.x = component.value;
                	case 1: v.y = component.value;
                	default:
                }
            } else {
                return false;
            }
        }
        parsed.value = v;
        return true;
    }

    public static function TryParseVector3(str:String, parsed:OutVector3):Bool {
        parsed.value = Vector3.zero;
        var numbers = GetVectorNumberStrings(str);
        if (numbers.length != 3)
            return false;
        var v = new Vector3();
        for (i in 0...3) {
            var number = numbers[i];
            var trimed = StringTools.trim(number);
            var component:OutFloat = { value: 0 };
            if (TryParseFloat(trimed, component)) {
                // PORT-NOTE: unity.Vector3 值语义类不支持下标访问，改为按分量赋值。
                switch (i)
                {
                	case 0: v.x = component.value;
                	case 1: v.y = component.value;
                	case 2: v.z = component.value;
                	default:
                }
            } else {
                return false;
            }
        }
        parsed.value = v;
        return true;
    }

    public static function TryParseVector2Int(str:String, parsed:OutVector2Int):Bool {
        parsed.value = Vector2Int.zero;
        var numbers = GetVectorNumberStrings(str);
        if (numbers.length != 2)
            return false;
        var v = new Vector2Int();
        for (i in 0...2) {
            var number = numbers[i];
            var trimed = StringTools.trim(number);
            var component:OutInt = { value: 0 };
            if (TryParseInt(trimed, component)) {
                // PORT-NOTE: unity.Vector2Int 值语义类不支持下标访问，改为按分量赋值。
                switch (i)
                {
                	case 0: v.x = component.value;
                	case 1: v.y = component.value;
                	default:
                }
            } else {
                return false;
            }
        }
        parsed.value = v;
        return true;
    }

    public static function TryParseVector3Int(str:String, parsed:OutVector3Int):Bool {
        parsed.value = Vector3Int.zero;
        var left = str.indexOf("[");
        var right = str.indexOf("]");
        var substring = str.substring(left + 1, right);
        var numbers = substring.split(",");
        if (numbers.length != 3)
            return false;
        var v = new Vector3Int();
        for (i in 0...3) {
            var number = numbers[i];
            var trimed = StringTools.trim(number);
            var component:OutInt = { value: 0 };
            if (TryParseInt(trimed, component)) {
                // PORT-NOTE: unity.Vector3Int 值语义类不支持下标访问，改为按分量赋值。
                switch (i)
                {
                	case 0: v.x = component.value;
                	case 1: v.y = component.value;
                	case 2: v.z = component.value;
                	default:
                }
            } else {
                return false;
            }
        }
        parsed.value = v;
        return true;
    }
}
