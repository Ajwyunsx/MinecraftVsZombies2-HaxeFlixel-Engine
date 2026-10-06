// Ported from: Assets/Scripts/Engine/Level/Modifiers/SetModifiers/StringModifier.cs
package pvzengine.modifiers;

import pvzengine.PropertyKey;

class StringModifier extends SetModifier<String>
{
	// PORT-NOTE: C# 的两个构造函数重载（第三参数为 string 常量或 PropertyKey<string>）合并为第三参数为 Dynamic 的构造函数。
	public function new(propertyName:PropertyKey<String>, op:SetOperator, value:Dynamic, priority:Int = 0)
	{
		super(propertyName, op, value, priority);
	}
	public override function GetCalculator():ModifierCalculator
	{
		return CalculatorMap.stringCalculator;
	}
}
