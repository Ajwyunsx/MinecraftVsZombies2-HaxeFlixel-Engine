package unity;

// Minimal UnityEngine.Experimental.Rendering.FormatUsage shim.
enum abstract FormatUsage(Int) from Int to Int {
	var None = 0;
	var Sample = 1;
	var Linear = 2;
	var SRGBRead = 3;
	var SRGBWrite = 4;
	var Blend = 5;
	var GetPixels = 6;
	var SetPixels = 7;
	var SetPixels32 = 8;
	var ReadPixels = 9;
	var LoadStore = 10;
	var MSAA2x = 11;
	var MSAA4x = 12;
	var MSAA8x = 13;
	var Render = 14;
	var BeginRender = 15;
}
