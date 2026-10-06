package system.text;

import haxe.io.Bytes;
import haxe.io.Encoding as HaxeEncoding;

// Minimal System.Text.Encoding shim.
class Encoding {
    public var webName(default, null):String;

    private function new(webName:String) {
        this.webName = webName;
    }

    public static var UTF8(get, never):Encoding;
    static function get_UTF8():Encoding {
        if (_utf8 == null) _utf8 = new Encoding("utf-8");
        return _utf8;
    }
    private static var _utf8:Encoding;

    public static var ASCII(get, never):Encoding;
    static function get_ASCII():Encoding {
        if (_ascii == null) _ascii = new Encoding("ascii");
        return _ascii;
    }
    private static var _ascii:Encoding;

    public static var Unicode(get, never):Encoding;
    static function get_Unicode():Encoding return UTF8;
    public static var BigEndianUnicode(get, never):Encoding;
    static function get_BigEndianUnicode():Encoding return UTF8;
    public static var Default(get, never):Encoding;
    static function get_Default():Encoding return UTF8;

    public function GetBytes(str:String):Bytes {
        // PORT-NOTE: Haxe 4.3 的 haxe.io.Encoding 只有 UTF8/RawNative，没有 ISO_8859_1，
        // ASCII 需要逐字节截断转换。
        if (webName == "ascii") {
            var bytes = Bytes.alloc(str.length);
            for (i in 0...str.length) bytes.set(i, str.charCodeAt(i) & 0xFF);
            return bytes;
        }
        return Bytes.ofString(str, HaxeEncoding.UTF8);
    }
    public function GetString(bytes:Bytes):String {
        return bytes.toString();
    }
    public function GetStringRange(bytes:Bytes, index:Int, count:Int):String {
        return bytes.sub(index, count).toString();
    }
}
