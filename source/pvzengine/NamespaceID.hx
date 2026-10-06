// Ported from: Assets/Scripts/Engine/Base/NamespaceID.cs
package pvzengine;

import system.FormatException;

// PORT-NOTE: C# 的 NamespaceID 是 class，并重载了 `==` / `!=`（值语义）以及 Equals/GetHashCode。
// Haxe 中 class 的 `==` 是引用比较，`Map<NamespaceID, V>` 也会退化成 ObjectMap（按引用查键），
// 而既有移植代码（`mvz2*` / `mvz2logic*`）大量使用 `idA == idB`、`id != someID` 和
// `Map<NamespaceID, ...>`，全部依赖值语义。因此这里把 NamespaceID 移植为
// `abstract NamespaceID(String)`（底层字符串就是 "spacename:path"）：
//   * `==` / `!=` 走字符串比较 → 与 C# 一致；
//   * `Map<NamespaceID, V>` 走 StringMap → 与 C# 的 Dictionary 一致；
//   * 字符串插值与 `Std.string` 直接得到 `nsp:path`（等价于 C# 的 ToString）。
// PORT-NOTE: 代价是 `Std.isOfType(x, NamespaceID)` 无法编译（abstract 不能作为运行期值）。
// 既有 3 处调用点（LanguageManager:176、AlmanacVariableFunctions:83、OptionsManager:178）
// 需改为 `Std.isOfType(x, String)`，语义等价（NamespaceID 本身就是其字符串）。
// PORT-NOTE: C# 的 private 字段 `valid` 由构造时的 CheckValidation() 计算；abstract 没有独立存储，
// 这里保持同名私有方法并在需要时即时计算（结果与 C# 相同，因为只依赖于 spacename/path）。
// PORT-NOTE: C# 的 EngineModelID.ToModelID(this NamespaceID id, string type) 是扩展方法，既有上层调用点
//   写作 `new NamespaceID(...).ToModelID(TYPE_ENTITY)`（3 处），故在此标注 @:using 提供实例调用形式。
@:using(pvzengine.EngineModelID)
abstract NamespaceID(String)
{
    public inline function new(nsp:String, name:String)
    {
        this = nsp + ":" + name;
    }
    public function GetHashCode():Int
    {
        // C#: HashCode.Combine(nsp, path)。Haxe 无对应 API，用等价的字符串哈希。
        var hash = 17;
        for (i in 0...this.length)
        {
            hash = hash * 31 + this.charCodeAt(i);
        }
        return hash;
    }
    public function Equals(other:Null<NamespaceID>):Bool
    {
        if (other == null)
            return false;
        return (this : String) == (other : String);
    }
    public static function ConvertName(text:String):String
    {
        var sb = new StringBuf();
        var lastWasUnderscore = false;

        for (i in 0...text.length)
        {
            var chr = text.charCodeAt(i);

            if (!isLetterOrDigit(chr))
            {
                if (!lastWasUnderscore)
                    sb.add("_");
                lastWasUnderscore = true;
                continue;
            }

            if (isUpper(chr) && i > 0 && !lastWasUnderscore)
                sb.add("_");

            sb.add(String.fromCharCode(toLowerInvariant(chr)));
            lastWasUnderscore = false;
        }
        return sb.toString();
    }
    // PORT-NOTE: C# 的 `out NamespaceID? parsed` 在 Haxe 中无法表达，且既有调用点同时使用了
    // 2 参数形式（`TryParse(str, nsp)` 直接取返回值）和 3 参数形式（`TryParse(str, nsp, outValue)`，
    // outValue 为 `{value:T}` 结构）。Haxe 不支持重载，故此处把第 3 参数做成可选：
    //   * 传入 parsed 时按 C# 语义写入 `parsed.value` 并返回 Bool；
    //   * 不传 parsed 时返回解析出的 NamespaceID（失败返回 null），供 2 参数调用点使用。
    public static function TryParseStrict(str:String, ?parsed:{ value:Dynamic }):Dynamic
    {
        var colonIndex = str.indexOf(':');
        var nsp:String;
        var path:String;
        if (parsed != null)
        {
            parsed.value = null;
        }
        if (colonIndex < 0)
        {
            // 没有冒号，失败。
            return parsed != null ? false : null;
        }
        else if (colonIndex == 0)
        {
            // 冒号前没有内容，错误。
            return parsed != null ? false : null;
        }
        else
        {
            // 冒号前有内容，获取命名空间和路径。
            nsp = str.substr(0, colonIndex);
            path = str.substr(colonIndex + 1);
        }
        if (!ValidateNamespace(nsp))
            return parsed != null ? false : null;
        if (!ValidatePath(path))
            return parsed != null ? false : null;
        var result = new NamespaceID(nsp, path);
        if (parsed != null)
        {
            parsed.value = result;
            return true;
        }
        return result;
    }
    public static function TryParse(str:String, defaultNsp:String, ?parsed:{ value:Dynamic }):Dynamic
    {
        var colonIndex = str.indexOf(':');
        var nsp:String;
        var path:String;
        if (parsed != null)
        {
            parsed.value = null;
        }
        if (colonIndex < 0)
        {
            // 没有冒号，使用默认命名空间。
            nsp = defaultNsp;
            path = str;
        }
        else if (colonIndex == 0)
        {
            // 冒号前没有内容，错误。
            return parsed != null ? false : null;
        }
        else
        {
            // 冒号前有内容，获取命名空间和路径。
            nsp = str.substr(0, colonIndex);
            path = str.substr(colonIndex + 1);
        }
        if (!ValidateNamespace(nsp))
            return parsed != null ? false : null;
        if (!ValidatePath(path))
            return parsed != null ? false : null;
        var result = new NamespaceID(nsp, path);
        if (parsed != null)
        {
            parsed.value = result;
            return true;
        }
        return result;
    }
    public static function ParseStrict(str:String):NamespaceID
    {
        var parsed = TryParseStrict(str);
        if (parsed != null)
        {
            return cast parsed;
        }
        throw new FormatException('Invalid NamespaceID $str.');
    }
    public static function Parse(str:String, defaultNsp:String):NamespaceID
    {
        var parsed = TryParse(str, defaultNsp);
        if (parsed != null)
        {
            return cast parsed;
        }
        throw new FormatException('Invalid NamespaceID $str.');
    }
    public static function ValidateNamespace(nsp:String):Bool
    {
        if (nsp == null || nsp.length == 0)
            return false;
        for (i in 0...nsp.length)
        {
            var character = nsp.charCodeAt(i);
            if (isLetterOrDigit(character) || character == "_".code || character == "-".code || character == ".".code)
                continue;
            return false;
        }
        return true;
    }
    public static function ValidatePath(path:String):Bool
    {
        if (path == null || path.length == 0)
            return false;
        for (i in 0...path.length)
        {
            var character = path.charCodeAt(i);
            if (isLetterOrDigit(character) || character == "_".code || character == "-".code || character == ".".code || character == "/".code)
                continue;
            return false;
        }
        return true;
    }
    public static function IsValid(id:Null<NamespaceID>):Bool
    {
        if (id == null)
            return false;
        if (!id.CheckValidation())
            return false;
        return true;
    }
    private function CheckValidation():Bool
    {
        if (SpaceName == null || SpaceName.length == 0 || Path == null || Path.length == 0)
            return false;
        if (!ValidateNamespace(SpaceName) || !ValidatePath(Path))
            return false;
        return true;
    }
    // PORT-NOTE: C# 的 `char.IsLetterOrDigit` / `char.IsUpper` / `char.ToLowerInvariant` 在 Haxe 无直接对应，
    // 用 ASCII + 拉丁字母范围实现（与 C# 对 ASCII 标识符的行为一致）。
    private static inline function isLetterOrDigit(chr:Int):Bool
    {
        return isLetter(chr) || (chr >= "0".code && chr <= "9".code);
    }
    private static inline function isLetter(chr:Int):Bool
    {
        return (chr >= "a".code && chr <= "z".code) || (chr >= "A".code && chr <= "Z".code);
    }
    private static inline function isUpper(chr:Int):Bool
    {
        return chr >= "A".code && chr <= "Z".code;
    }
    private static inline function toLowerInvariant(chr:Int):Int
    {
        return isUpper(chr) ? chr + 32 : chr;
    }
    public function ToString():String
    {
        return this;
    }
    // PORT-NOTE: 既有移植代码大量使用 C# 风格的 `.toString()`（小写 t，68 处），Haxe 的 String 也提供
    // 同名方法，这里显式补上以保持调用形式一致。
    public function toString():String
    {
        return this;
    }
    @:to public inline function asString():String
    {
        return this;
    }
    public var SpaceName(get, never):String;
    inline function get_SpaceName():String
    {
        var colonIndex = this.indexOf(':');
        return colonIndex < 0 ? "" : this.substr(0, colonIndex);
    }
    public var Path(get, never):String;
    inline function get_Path():String
    {
        var colonIndex = this.indexOf(':');
        return colonIndex < 0 ? this : this.substr(colonIndex + 1);
    }
}
