// Ported from: Assets/Scripts/MVZ2/Level/NightmareSkyAnimator.cs
package mvz2.level;

import mvz2.models.RendererElement;
import unity.*;
import unity.Debug;

// PORT-NOTE: C# 的 [ExecuteAlways] 特性在 Haxe 中无对应语义。
@:executeAlways
class NightmareSkyAnimator extends MonoBehaviour
{
	private function Update():Void
	{
		if (sky == null)
			return;
		sky.SetFloat("_WarpTime", warpTime);
		sky.ApplyShaderProperties();
	}
	@:serializeField
	private var sky:RendererElement = null;
	@:range(0, 1)
	@:serializeField
	private var warpTime:Float;
}
