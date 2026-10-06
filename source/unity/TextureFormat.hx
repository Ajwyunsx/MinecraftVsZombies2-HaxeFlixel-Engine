package unity;

// Minimal UnityEngine.TextureFormat shim.
enum abstract TextureFormat(Int) {
    var Alpha8 = 1;
    var ARGB4444 = 2;
    var RGB24 = 3;
    var RGBA32 = 4;
    var ARGB32 = 5;
    var RGB565 = 7;
    var R16 = 9;
    var DXT1 = 10;
    var DXT5 = 12;
    var RGBA4444 = 13;
    var BGRA32 = 14;
    var RHalf = 15;
    var RGHalf = 16;
    var RGBAHalf = 17;
    var RFloat = 18;
    var RGFloat = 19;
    var RGBAFloat = 20;
    var RGB9e5Float = 22;
    var BC4 = 26;
    var BC5 = 27;
    var BC6H = 24;
    var BC7 = 25;

    // PORT-NOTE: Haxe 无 Enum.GetValues，遍历枚举值使用 values()（等价于 C# 的 Enum.GetValues）。
    public static function values():Array<TextureFormat> {
        return [Alpha8, ARGB4444, RGB24, RGBA32, ARGB32, RGB565, R16, DXT1, DXT5, RGBA4444, BGRA32,
            RHalf, RGHalf, RGBAHalf, RFloat, RGFloat, RGBAFloat, RGB9e5Float, BC4, BC5, BC6H, BC7];
    }
}
