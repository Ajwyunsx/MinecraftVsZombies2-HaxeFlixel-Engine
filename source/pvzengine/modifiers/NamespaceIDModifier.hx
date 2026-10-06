// Ported from: Assets/Scripts/Engine/Level/Modifiers/SetModifiers/NamespaceIDModifier.cs
package pvzengine.modifiers;

import pvzengine.NamespaceID;
import pvzengine.PropertyKey;

class NamespaceIDModifier extends SetModifier<NamespaceID>
{
	// PORT-NOTE: C# 的两个构造函数重载（第三参数为 NamespaceID 常量或 PropertyKey<NamespaceID>）合并为第三参数为 Dynamic 的构造函数。
	public function new(propertyName:PropertyKey<NamespaceID>, op:SetOperator, value:Dynamic, priority:Int = 0)
	{
		super(propertyName, op, value, priority);
	}
	public override function GetCalculator():ModifierCalculator
	{
		return CalculatorMap.namespaceIDCalculator;
	}
}
