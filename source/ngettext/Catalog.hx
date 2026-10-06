package ngettext;

import haxe.Int64;
import system.io.Stream;

// Ported shim of NGettext.Catalog (external library, not present in the repository).
// PORT-NOTE: only the members used by this project are implemented; translations are loaded
// from the PO/MO content stored in the archive entry.
class Catalog {
    private var translations:Map<String, String> = new Map();
    private var pluralForms:Map<String, Array<String>> = new Map();
    public var CultureInfo(get, never):Dynamic;
    private var culture:Dynamic;

    public function new(?stream:Stream, ?culture:Dynamic) {
        this.culture = culture;
        if (stream != null) {
            load(stream.ReadToEnd());
        }
    }

    private function load(content:String):Void {
        var currentId:String = null;
        for (line in content.split("\n")) {
            var trimmed = StringTools.trim(line);
            if (trimmed.length == 0 || trimmed.charAt(0) == "#")
                continue;
            if (StringTools.startsWith(trimmed, "msgid ")) {
                currentId = parseValue(trimmed.substr(6));
            } else if (StringTools.startsWith(trimmed, "msgstr ") && currentId != null) {
                var value = parseValue(trimmed.substr(7));
                translations.set(currentId, value);
                currentId = null;
            }
        }
    }
    private static function parseValue(raw:String):String {
        var value = StringTools.trim(raw);
        if (value.length >= 2 && value.charAt(0) == '"' && value.charAt(value.length - 1) == '"') {
            value = value.substr(1, value.length - 2);
        }
        return StringTools.replace(value, "\\n", "\n");
    }
    inline function get_CultureInfo():Dynamic return culture;

    // PORT-NOTE: NGettext 的 GetString(id) / GetString(id, args) 在 Haxe 中无法重载，
    //   合并为可选参数形式（args 省略时不做格式化）。
    public function GetString(id:String, ?args:Array<Dynamic>):String {
        var format = translations.exists(id) ? translations.get(id) : id;
        if (args == null) return format;
        return formatString(format, args);
    }
    // PORT-NOTE: NGettext 的 GetPluralString(id, plural, n) / (..., args) 合并为可选参数形式。
    public function GetPluralString(id:String, plural:String, n:haxe.Int64, ?args:Array<Dynamic>):String {
        var key = id + "\u0000" + plural;
        var result:String;
        if (pluralForms.exists(key)) {
            var forms = pluralForms.get(key);
            result = forms.length > 0 ? forms[pluralIndex(n, forms.length)] : id;
        } else {
            result = Int64.eq(n, 1) ? GetString(id) : GetString(plural);
        }
        return args == null ? result : formatString(result, args);
    }
    // C#: public string GetParticularString(string context, string id, params object[] args)
    public function GetParticularString(context:String, id:String, ?args:Array<Dynamic>):String {
        var format = GetString(context + "\u0004" + id);
        return args == null ? format : formatString(format, args);
    }
    // C#: public string GetParticularPluralString(string context, string id, string plural, long n, params object[] args)
    public function GetParticularPluralString(context:String, id:String, plural:String, n:haxe.Int64, ?args:Array<Dynamic>):String {
        return GetPluralString(context + "\u0004" + id, context + "\u0004" + plural, n, args);
    }
    // C#: public bool IsTranslationExist(string id)
    public function IsTranslationExist(id:String):Bool {
        return translations.exists(id);
    }
    private static inline function pluralIndex(n:haxe.Int64, count:Int):Int {
        // PORT-NOTE: 英文等两复数形式语言的简化实现（与 shim 的 PO 解析能力一致）。
        return Int64.eq(n, 1) ? 0 : (count > 1 ? 1 : 0);
    }

    private static function formatString(format:String, args:Array<Dynamic>):String {
        var result = format;
        if (args == null) return result;
        for (i in 0...args.length) {
            result = StringTools.replace(result, "{" + i + "}", Std.string(args[i]));
        }
        return result;
    }
}
