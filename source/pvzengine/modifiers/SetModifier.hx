// Ported from: Assets/Scripts/Engine/Level/Modifiers/SetModifiers/SetModifier.cs
package pvzengine.modifiers;

import pvzengine.modifiers.PropertyModifier.PropertyModifierT;
import pvzengine.PropertyKey;

class SetModifier<T> extends PropertyModifierT<T>
{
	public function new(propertyName:PropertyKey<T>, op:SetOperator, value:Dynamic, priority:Int = 0)
	{
		super(propertyName, value, priority);
		Operator = op;
	}
	public var Operator(default, null):SetOperator;
}
