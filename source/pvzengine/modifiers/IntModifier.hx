// Ported from: Assets/Scripts/Engine/Level/Modifiers/IntegerModifiers/IntModifier.cs
package pvzengine.modifiers;

import pvzengine.PropertyKey;

class IntModifier extends IntegerModifier<Int>
{
	// PORT-NOTE: C# 的两个构造函数重载（第三参数为 int 常量或 PropertyKey<int>）合并为第三参数为 Dynamic 的构造函数。
	public function new(propertyName:PropertyKey<Int>, op:IntegerOperator, value:Dynamic, priority:Int = 0)
	{
		super(propertyName, op, value, priority);
	}
	public override function GetCalculator():ModifierCalculator
	{
		return CalculatorMap.intCalculator;
	}
}
