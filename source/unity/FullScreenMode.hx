package unity;

// Minimal UnityEngine.FullScreenMode shim.
enum abstract FullScreenMode(Int)
{
	var ExclusiveFullScreen = 0;
	var FullScreenWindow = 1;
	var MaximizedWindow = 2;
	var Windowed = 3;
}
