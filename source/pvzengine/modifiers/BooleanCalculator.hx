// Ported from: Assets/Scripts/Engine/Level/Modifiers/Calculators/BooleanCalculator.cs
package pvzengine.modifiers;

import pvzengine.modifiers.ModifierCalculator.TypedModifierCalculator;

class BooleanCalculator extends TypedModifierCalculator<Bool, BooleanModifier>
{
	public function new()
	{
		super();
	}
	// PORT-NOTE: C# 的 T? 对未约束泛型参数等价于 T；Haxe 用 Null<Bool> 表示可空。
	// 注意：在静态目标上 Null<Bool> 为 null 时会被当作 false 参与布尔运算（C# 中 bool? 运算会传播 null）。
	public override function CalculateGeneric(value:Null<Bool>, modifiers:Array<ModifierSourceItem>):Null<Bool>
	{
		if (modifiers == null || modifiers.length == 0)
			return value;

		var grouped = ModifierCalculator.GroupByPriority(modifiers);
		for (layerModifiers in grouped)
		{
			var setValue:Null<Bool> = value;
			var orValue = false;
			var xorValue = false;
			var andValue = true;
			var reverse = false;
			for (modi in layerModifiers)
			{
				var buff = modi.container;
				if (!Std.isOfType(modi.modifier, BooleanModifier))
					continue;
				var modifier:BooleanModifier = cast modi.modifier;
				var modifierValue = modifier.GetModifierValueGeneric(buff);
				if (!modifier.FitsConditionGeneric(modifierValue))
					continue;
				switch (modifier.Operator)
				{
					case BooleanOperator.Set:
						setValue = modifierValue;
					case BooleanOperator.SetNot:
						setValue = !modifierValue;
					case BooleanOperator.Not:
						reverse = !reverse;
					case BooleanOperator.Or:
						orValue = orValue || modifierValue;
					case BooleanOperator.Xor:
						xorValue = xorValue != modifierValue;
					case BooleanOperator.And:
						andValue = andValue && modifierValue;
				}
			}
			value = setValue;
			value = value || orValue;
			value = value != xorValue;
			value = value && andValue;
			if (reverse)
			{
				value = !value;
			}
		}
		return value;
	}
}
