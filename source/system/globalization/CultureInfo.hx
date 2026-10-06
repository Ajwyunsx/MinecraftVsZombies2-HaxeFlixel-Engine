// Ported from: System.Globalization.CultureInfo (minimal shim)
package system.globalization;

// PORT-NOTE: 使用 openfl/lime 的 Locale 作为区域信息数据源，缺失时降级为纯语言代码解析。
class CultureInfo {
    public static var CurrentCulture(get, never):CultureInfo;
    static var _current:CultureInfo;
    static function get_CurrentCulture():CultureInfo {
        if (_current == null) {
            #if (lime && !macro)
            _current = new CultureInfo(lime.system.Locale.currentLocale.language);
            #else
            _current = new CultureInfo("en-US");
            #end
        }
        return _current;
    }

    public static function GetCultureInfo(name:String):CultureInfo {
        if (name == null) throw new CultureNotFoundException("Culture name is null", name);
        return new CultureInfo(name);
    }

    public var Name(default, null):String;
    public var NativeName(get, never):String;
    public var TwoLetterISOLanguageName(get, never):String;
    public var Parent(get, never):CultureInfo;

    private var parentCache:CultureInfo = null;
    private var hasParentCache:Bool = false;

    public function new(name:String) {
        Name = name;
    }

    function get_NativeName():String {
        return Name;
    }

    function get_TwoLetterISOLanguageName():String {
        var i = Name.indexOf("-");
        return i < 0 ? Name : Name.substr(0, i);
    }

    function get_Parent():CultureInfo {
        if (!hasParentCache) {
            hasParentCache = true;
            var neutral = get_TwoLetterISOLanguageName();
            parentCache = neutral == Name ? new CultureInfo("") : new CultureInfo(neutral);
        }
        return parentCache;
    }

    public function ToString():String {
        return Name;
    }
}
