// Ported from: Assets/Scripts/Engine/Level/Modifiers/IntegerModifiers/IntegerModifier.cs
package pvzengine.modifiers;

import pvzengine.modifiers.PropertyModifier.PropertyModifierT;
import pvzengine.PropertyKey;

class IntegerModifier<T> extends PropertyModifierT<T>
{
	// PORT-NOTE: C# 的两个构造函数重载（第三参数为 T 常量或 PropertyKey<T>）合并为第三参数为 Dynamic 的构造函数，
	// 由基类 PropertyModifierT<T> 在运行期区分（详见 PropertyModifier.hx）。
	public function new(propertyName:PropertyKey<T>, op:IntegerOperator, value:Dynamic, priority:Int = 0)
	{
		super(propertyName, value, priority);
		Operator = op;
	}
	public var Operator(default, null):IntegerOperator;
}
