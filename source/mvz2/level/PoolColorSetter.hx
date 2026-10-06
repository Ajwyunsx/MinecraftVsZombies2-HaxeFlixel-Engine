// Ported from: Assets/Scripts/MVZ2/Level/PoolColorSetter.cs
package mvz2.level;

import mvz2.managers.MainManager;
import mvz2logic.options.LogicOptionItemID;
import unity.*;
import unity.Debug;
import mvz2.options.OptionsManager;
// PORT-NOTE: C# 的扩展方法（this 参数形式）在 Haxe 中需显式 using 才能以 `obj.Method()` 调用。
using mvz2logic.options.LogicOptionExt;            // HasBloodAndGore(this IGlobalOptions)

class PoolColorSetter extends MonoBehaviour
{
	private function OnEnable():Void
	{
		if (poolRenderer == null)
			return;
		var main = MainManager.Instance;
		var color = main.OptionsManager.HasBloodAndGore() ? normalColor : censoredColor;
		poolRenderer.color = color;
	}
	@:serializeField
	private var poolRenderer:SpriteRenderer = null;
	@:serializeField
	private var normalColor:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 null 解引用（该字段在 Unity 由 prefab 序列化赋值，移植层由 prefab 数据覆盖）
	@:serializeField
	private var censoredColor:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 null 解引用（该字段在 Unity 由 prefab 序列化赋值，移植层由 prefab 数据覆盖）
}
