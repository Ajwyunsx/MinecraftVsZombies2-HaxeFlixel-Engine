package unity;

// Minimal UnityEngine.Experimental.Rendering.GraphicsFormat shim.
// PORT-NOTE: Unity 的该枚举有上百个成员，这里只保留本工程会用到/常见的格式。
// Haxe 没有 Enum.GetValues，遍历枚举值请使用 values()（等价于 C# 的 Enum.GetValues）。
enum abstract GraphicsFormat(Int) from Int to Int {
	var None = 0;
	var R8_SRGB = 1;
	var R8_UNorm = 2;
	var R8_SNorm = 3;
	var R8_UInt = 4;
	var R8_SInt = 5;
	var R16_UNorm = 6;
	var R16_SNorm = 7;
	var R16_SFloat = 8;
	var R8G8_SRGB = 9;
	var R8G8_UNorm = 10;
	var R8G8_SNorm = 11;
	var R8G8B8_SRGB = 12;
	var R8G8B8_UNorm = 13;
	var R8G8B8_SNorm = 14;
	var B8G8R8_SRGB = 15;
	var B8G8R8_UNorm = 16;
	var B8G8R8_SNorm = 17;
	var R8G8B8A8_SRGB = 18;
	var R8G8B8A8_UNorm = 19;
	var R8G8B8A8_SNorm = 20;
	var B8G8R8A8_SRGB = 21;
	var B8G8R8A8_UNorm = 22;
	var R4G4B4A4_UNormPack16 = 23;
	var B4G4R4A4_UNormPack16 = 24;
	var R5G6B5_UNormPack16 = 25;
	var B5G6R5_UNormPack16 = 26;
	var R8G8B8A8_SRGB_Signed = 27;
	var R16G16B16_SFloat = 28;
	var R16G16B16A16_SFloat = 29;
	var R16G16B16A16_UNorm = 30;
	var R16G16B16A16_SNorm = 31;
	var R32_SFloat = 32;
	var R32G32_SFloat = 33;
	var R32G32B32_SFloat = 34;
	var R32G32B32A32_SFloat = 35;
	var D16_UNorm = 36;
	var D24_UNorm_S8_UInt = 37;
	var D32_SFloat = 38;
	var D32_SFloat_S8_UInt = 39;
	var S8_UInt = 40;

	public static function values():Array<GraphicsFormat> {
		return [
			None,
			R8_SRGB, R8_UNorm, R8_SNorm, R8_UInt, R8_SInt,
			R16_UNorm, R16_SNorm, R16_SFloat,
			R8G8_SRGB, R8G8_UNorm, R8G8_SNorm,
			R8G8B8_SRGB, R8G8B8_UNorm, R8G8B8_SNorm,
			B8G8R8_SRGB, B8G8R8_UNorm, B8G8R8_SNorm,
			R8G8B8A8_SRGB, R8G8B8A8_UNorm, R8G8B8A8_SNorm,
			B8G8R8A8_SRGB, B8G8R8A8_UNorm,
			R4G4B4A4_UNormPack16, B4G4R4A4_UNormPack16, R5G6B5_UNormPack16, B5G6R5_UNormPack16,
			R16G16B16_SFloat, R16G16B16A16_SFloat, R16G16B16A16_UNorm, R16G16B16A16_SNorm,
			R32_SFloat, R32G32_SFloat, R32G32B32_SFloat, R32G32B32A32_SFloat,
			D16_UNorm, D24_UNorm_S8_UInt, D32_SFloat, D32_SFloat_S8_UInt, S8_UInt
		];
	}
}
