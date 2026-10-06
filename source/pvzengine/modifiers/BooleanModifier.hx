// Ported from: Assets/Scripts/Engine/Level/Modifiers/BooleanModifiers/BooleanModifier.cs
package pvzengine.modifiers;

import pvzengine.modifiers.PropertyModifier.PropertyModifierT;
import pvzengine.PropertyKey;

class BooleanModifier extends PropertyModifierT<Bool>
{
	// PORT-NOTE: C# 有四个构造函数重载：
	//   (propertyName, valueConst, priority = 0)
	//   (propertyName, buffPropertyName, priority = 0)
	//   (propertyName, op, valueConst, priority = 0)
	//   (propertyName, op, buffPropertyName, priority = 0)
	// Haxe 不支持重载，合并为单一构造函数；第 3/4 个参数在运行期按类型区分。
	public function new(propertyName:PropertyKey<Bool>, a:Dynamic, ?b:Dynamic, ?c:Dynamic, priority:Int = 0)
	{
		var op = BooleanOperator.Set;
		var value:Dynamic = a;
		if (c != null)
		{
			// (propertyName, op, valueConst|buffPropertyName, priority)
			op = cast a;
			value = b;
			priority = cast c;
		}
		else if (b != null)
		{
			// TODO-PORT: 3 参数调用时 (propertyName, op, value) 与 (propertyName, value, priority)
			// 无法在编译期区分，此处按「第 3 个参数是否为 Bool 或属性键」启发式判定。
			if (Std.isOfType(b, Bool) || PropertyModifier.IsPropertyKeyLike(b))
			{
				// (propertyName, op, valueConst|buffPropertyName)
				op = cast a;
				value = b;
			}
			else
			{
				// (propertyName, valueConst|buffPropertyName, priority)
				priority = cast b;
			}
		}
		super(propertyName, value, priority);
		Operator = op;
	}
	public var Operator(default, null):BooleanOperator;
	public override function GetCalculator():ModifierCalculator
	{
		return CalculatorMap.booleanCalculator;
	}
}
