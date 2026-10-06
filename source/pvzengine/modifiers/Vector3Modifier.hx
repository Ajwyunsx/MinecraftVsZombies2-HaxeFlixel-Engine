// Ported from: Assets/Scripts/Engine/Level/Modifiers/NumberModifiers/Vector3Modifier.cs
package pvzengine.modifiers;

import pvzengine.PropertyKey;
import unity.Vector3;

class Vector3Modifier extends NumberModifier<Vector3>
{
	// PORT-NOTE: C# 的两个构造函数重载（第三参数为 Vector3 常量或 PropertyKey<Vector3>）合并为第三参数为 Dynamic 的构造函数。
	public function new(propertyName:PropertyKey<Vector3>, op:NumberOperator, value:Dynamic, priority:Int = 0)
	{
		super(propertyName, op, value, priority);
	}
	public override function GetCalculator():ModifierCalculator
	{
		return CalculatorMap.vector3Calculator;
	}
}
