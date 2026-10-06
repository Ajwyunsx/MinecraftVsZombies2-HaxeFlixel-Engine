// Ported from: Assets/Scripts/MVZ2/Level/PoolAnimator.cs
package mvz2.level;

import mvz2.models.RendererElement;
import unity.*;
import unity.Debug;

// PORT-NOTE: C# 的 [ExecuteAlways] 特性在 Haxe 中无对应语义。
@:executeAlways
class PoolAnimator extends MonoBehaviour
{
	private function Update():Void
	{
		if (poolElement == null)
			return;
		poolElement.SetFloat("_WarpTime", warpTime);
		poolElement.SetFloat("_CausticTime", causticTime);
		poolElement.ApplyShaderProperties();
		if (animator != null)
		{
			animator.SetFloat("WarpSpeed", warpSpeed);
		}
	}
	@:serializeField
	private var animator:Animator = null;
	@:serializeField
	private var poolElement:RendererElement = null;
	@:range(0, 1)
	@:serializeField
	private var warpTime:Float;
	@:range(1, 3)
	@:serializeField
	private var warpSpeed:Float;
	@:range(0, 1)
	@:serializeField
	private var causticTime:Float;
}
