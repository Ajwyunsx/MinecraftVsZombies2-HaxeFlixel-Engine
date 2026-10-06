package unity;

// Minimal UnityEngine.Font shim (openfl 文本字型).
class Font extends UnityObject {
    public var material:Material;
    public var fontSize:Int = 12;
    // PORT-NOTE: UnityEngine.Font.dynamic cannot use that name in Haxe (`dynamic` is a keyword);
    // renamed to dynamicFont.
    public var dynamicFont:Bool = true;

    public function new(?name:String) {
        super();
        if (name != null) this.name = name;
    }

    public static function CreateDynamicFontFromOSFont(fontname:String, size:Int):Font {
        var font = new Font(fontname);
        font.fontSize = size;
        return font;
    }
}
