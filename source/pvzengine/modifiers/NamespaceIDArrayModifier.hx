// Ported from: Assets/Scripts/Engine/Level/Modifiers/SetModifiers/NamespaceIDArrayModifier.cs
package pvzengine.modifiers;

import pvzengine.NamespaceID;
import pvzengine.PropertyKey;

class NamespaceIDArrayModifier extends SetModifier<Array<NamespaceID>>
{
	// PORT-NOTE: C# 的两个构造函数重载（第三参数为 NamespaceID[] 常量或 PropertyKey<NamespaceID[]>）合并为第三参数为 Dynamic 的构造函数。
	public function new(propertyName:PropertyKey<Array<NamespaceID>>, op:SetOperator, value:Dynamic, priority:Int = 0)
	{
		super(propertyName, op, value, priority);
	}
	public override function GetCalculator():ModifierCalculator
	{
		return CalculatorMap.namespaceIDArrayCalculator;
	}
}
