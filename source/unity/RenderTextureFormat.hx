package unity;

// Minimal UnityEngine.RenderTextureFormat shim.
// PORT-NOTE: 遍历枚举值请使用 values()（Haxe 无 Enum.GetValues）。
enum abstract RenderTextureFormat(Int) from Int to Int {
	var ARGB32 = 0;
	var Depth = 1;
	var ARGBHalf = 2;
	var Shadowmap = 3;
	var RGB565 = 4;
	var ARGB4444 = 5;
	var ARGB1555 = 6;
	var Default = 7;
	var ARGB2101010 = 8;
	var DefaultHDR = 9;
	var ARGB64 = 10;
	var ARGBFloat = 11;
	var RGFloat = 12;
	var RGHalf = 13;
	var RFloat = 14;
	var RHalf = 15;
	var R8 = 16;
	var ARGBInt = 17;
	var RGInt = 18;
	var RInt = 19;
	var BGRA32 = 20;
	var RGB111110Float = 21;
	var RG32 = 22;
	var RGBAUShort = 23;
	var RG16 = 24;
	var BGRA10101010_XR = 25;
	var BGR101010_XR = 26;
	var R16 = 27;

	public static function values():Array<RenderTextureFormat> {
		return [
			ARGB32, Depth, ARGBHalf, Shadowmap, RGB565, ARGB4444, ARGB1555, Default, ARGB2101010,
			DefaultHDR, ARGB64, ARGBFloat, RGFloat, RGHalf, RFloat, RHalf, R8, ARGBInt, RGInt, RInt,
			BGRA32, RGB111110Float, RG32, RGBAUShort, RG16, R16
		];
	}
}
