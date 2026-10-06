// Ported from: Assets/Scripts/View/Rendering/RenderDowngrade.cs
package mvz2.rendering;

import unity.Graphics;
import unity.RenderTexture;

class RenderDowngrade extends unity.MonoBehaviour
{
	function OnRenderImage(src:RenderTexture, dest:RenderTexture):Void
	{
		// 1. 将场景渲染到低分辨率RT
		Graphics.Blit(src, lowResRT);
		// 2. 将低分辨率RT放大到屏幕
		Graphics.Blit(lowResRT, dest);
	}
	@:serializeField
	private var lowResRT:RenderTexture;
}
