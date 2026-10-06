// Ported from: Assets/Scripts/Engine/Level/Modifiers/NumberModifiers/FloatModifier.cs
package pvzengine.modifiers;

import pvzengine.PropertyKey;

class FloatModifier extends NumberModifier<Float>
{
	// PORT-NOTE: C# 的两个构造函数重载（第三参数为 float 常量或 PropertyKey<float>）合并为第三参数为 Dynamic 的构造函数。
	public function new(propertyName:PropertyKey<Float>, op:NumberOperator, value:Dynamic, priority:Int = 0)
	{
		super(propertyName, op, value, priority);
	}
	public override function GetCalculator():ModifierCalculator
	{
		return CalculatorMap.floatCalculator;
	}
}
