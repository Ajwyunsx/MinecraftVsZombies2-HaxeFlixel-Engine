package unity;

// Minimal UnityEngine.Experimental.Rendering.DefaultFormat shim.
enum abstract DefaultFormat(Int) from Int to Int {
	var LDR = 0;
	var DepthStencil = 1;
	var Shadow = 2;
	var Video = 3;
}
