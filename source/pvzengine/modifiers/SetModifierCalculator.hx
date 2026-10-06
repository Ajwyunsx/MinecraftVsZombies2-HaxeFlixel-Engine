// Ported from: Assets/Scripts/Engine/Level/Modifiers/Calculators/SetModifierCalculator.cs
package pvzengine.modifiers;

import pvzengine.modifiers.ModifierCalculator.TypedModifierCalculator;

import pvzengine.NamespaceID;
import tools.EnumerableExt;

class SetModifierCalculator<T> extends TypedModifierCalculator<T, SetModifier<T>>
{
	public function new()
	{
		super();
	}
	public override function CalculateGeneric(value:Null<T>, modifiers:Array<ModifierSourceItem>):Null<T>
	{
		if (modifiers == null || modifiers.length == 0)
			return value;

		// C#: modifiers.Where(m => m.modifier is SetModifier<T>)
		// PORT-NOTE: Haxe 无法做带类型参数的运行期判断，改用非泛型的 SetModifier 进行判断。
		var validModifiers:Array<ModifierSourceItem> = [];
		for (item in modifiers)
		{
			if (Std.isOfType(item.modifier, SetModifier))
			{
				validModifiers.push(item);
			}
		}
		if (validModifiers.length == 0)
			return value;
		// C#: validModifiers.OrderByDescending(m => m.modifier.Priority)
		var reverseOrdered = EnumerableExt.OrderByDescending(validModifiers, function(item:ModifierSourceItem) return item.modifier.Priority);
		for (modifierContainer in reverseOrdered)
		{
			var modifier:SetModifier<T> = cast modifierContainer.modifier;
			var container = modifierContainer.container;
			var modifierValue = modifier.GetModifierValueGeneric(container);
			if (!modifier.FitsConditionGeneric(modifierValue))
				continue;
			if (modifier.Operator == SetOperator.SetIfNotNull && modifierValue == null)
				continue;
			return modifierValue;
		}
		return value;
	}
}

class NamespaceIDCalculator extends SetModifierCalculator<NamespaceID>
{
	public function new()
	{
		super();
	}
}

class NamespaceIDArrayCalculator extends SetModifierCalculator<Array<NamespaceID>>
{
	public function new()
	{
		super();
	}
}

class StringCalculator extends SetModifierCalculator<String>
{
	public function new()
	{
		super();
	}
}
