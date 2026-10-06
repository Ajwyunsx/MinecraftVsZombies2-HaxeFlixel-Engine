// Ported from: Assets/Scripts/Engine/Level/Modifiers/Calculators/IntegerModifierCalculator.cs
package pvzengine.modifiers;

import pvzengine.modifiers.ModifierCalculator.TypedModifierCalculator;

class IntegerModifierCalculator<T> extends TypedModifierCalculator<T, IntegerModifier<T>>
{
	public function new()
	{
		super();
	}
	public override function CalculateGeneric(value:Null<T>, modifiers:Array<ModifierSourceItem>):Null<T>
	{
		if (modifiers == null || modifiers.length == 0)
			return value;

		var grouped = ModifierCalculator.GroupByPriority(modifiers);
		for (layerModifiers in grouped)
		{
			// PORT-NOTE: C# 中 T? 对未约束泛型参数等价于 T，`default` 即 default(T)；
			// Haxe 无法表达 default(T)，改为调用 GetDefaultValue()（见下）。
			var orValue:Null<T> = GetDefaultValue();
			var xorValue:Null<T> = GetDefaultValue();
			var andValue:Null<T> = GetDefaultAndValue();
			var shiftBits = 0;
			var bitReverse = false;
			var setValue:Null<T> = value;
			var addValue:Null<T> = GetDefaultValue();
			var multiple:Null<T> = GetDefaultMultiple();
			var multiply:Null<T> = GetDefaultMultiple();
			for (modi in layerModifiers)
			{
				var buff = modi.container;
				if (!Std.isOfType(modi.modifier, IntegerModifier))
					continue;
				var modifier:IntegerModifier<T> = cast modi.modifier;
				var modifierValue = modifier.GetModifierValueGeneric(buff);
				if (!modifier.FitsConditionGeneric(modifierValue))
					continue;
				switch (modifier.Operator)
				{
					case IntegerOperator.Set:
						setValue = modifierValue;
					case IntegerOperator.Add:
						addValue = AddValue(addValue, modifierValue);
					case IntegerOperator.AddMultiple:
						multiple = AddValue(multiple, modifierValue);
					case IntegerOperator.Multiply:
						multiply = MultiplyValue(multiply, modifierValue);
					case IntegerOperator.BitReverse:
						bitReverse = !bitReverse;
					case IntegerOperator.BitOr:
						orValue = OrValue(orValue, modifierValue);
					case IntegerOperator.BitXor:
						xorValue = XorValue(xorValue, modifierValue);
					case IntegerOperator.BitAnd:
						andValue = AndValue(andValue, modifierValue);
					case IntegerOperator.BitLeftShift:
						shiftBits = LeftShiftBits(shiftBits, modifierValue);
					case IntegerOperator.BitRightShift:
						shiftBits = RightShiftBits(shiftBits, modifierValue);
				}
			}
			value = setValue;
			value = OrValue(value, orValue);
			value = XorValue(value, xorValue);
			value = AndValue(value, andValue);
			value = ShiftValue(value, shiftBits);
			value = AddValue(value, addValue);
			value = MultiplyValue(value, multiple);
			value = MultiplyValue(value, multiply);
			if (bitReverse)
			{
				value = ReverseValue(value);
			}
		}
		return value;
	}
	// abstract
	function GetDefaultMultiple():T
	{
		throw "abstract";
	}
	// abstract
	function GetDefaultAndValue():T
	{
		throw "abstract";
	}
	// PORT-NOTE: 对应 C# 的 `default(T)`（零值）。Haxe 泛型无法表达 default(T)，故新增该抽象方法。
	// abstract
	function GetDefaultValue():T
	{
		throw "abstract";
	}
	// abstract
	function AddValue(value1:Null<T>, value2:Null<T>):Null<T>
	{
		throw "abstract";
	}
	// abstract
	function MultiplyValue(value1:Null<T>, value2:Null<T>):Null<T>
	{
		throw "abstract";
	}
	// abstract
	function OrValue(value1:Null<T>, value2:Null<T>):Null<T>
	{
		throw "abstract";
	}
	// abstract
	function XorValue(value1:Null<T>, value2:Null<T>):Null<T>
	{
		throw "abstract";
	}
	// abstract
	function AndValue(value1:Null<T>, value2:Null<T>):Null<T>
	{
		throw "abstract";
	}
	// abstract
	function LeftShiftBits(bits:Int, offset:Null<T>):Int
	{
		throw "abstract";
	}
	// abstract
	function RightShiftBits(bits:Int, offset:Null<T>):Int
	{
		throw "abstract";
	}
	// abstract
	function ShiftValue(value1:Null<T>, bits:Int):Null<T>
	{
		throw "abstract";
	}
	// abstract
	function ReverseValue(value:Null<T>):Null<T>
	{
		throw "abstract";
	}
}

class IntCalculator extends IntegerModifierCalculator<Int>
{
	public function new()
	{
		super();
	}
	override function GetDefaultMultiple():Int
	{
		return 1;
	}
	override function GetDefaultValue():Int
	{
		return 0;
	}
	override function AddValue(value1:Null<Int>, value2:Null<Int>):Null<Int>
	{
		return value1 + value2;
	}
	override function MultiplyValue(value1:Null<Int>, value2:Null<Int>):Null<Int>
	{
		return value1 * value2;
	}
	override function GetDefaultAndValue():Int
	{
		return ~0;
	}
	override function OrValue(value1:Null<Int>, value2:Null<Int>):Null<Int>
	{
		return value1 | value2;
	}
	override function XorValue(value1:Null<Int>, value2:Null<Int>):Null<Int>
	{
		return value1 ^ value2;
	}
	override function AndValue(value1:Null<Int>, value2:Null<Int>):Null<Int>
	{
		return value1 & value2;
	}
	override function LeftShiftBits(bits:Int, offset:Null<Int>):Int
	{
		return bits + offset;
	}
	override function RightShiftBits(bits:Int, offset:Null<Int>):Int
	{
		return bits - offset;
	}
	override function ShiftValue(value1:Null<Int>, bits:Int):Null<Int>
	{
		if (bits > 0)
		{
			return value1 << bits;
		}
		else if (bits < 0)
		{
			return value1 >> (-bits);
		}
		return value1;
	}
	override function ReverseValue(value:Null<Int>):Null<Int>
	{
		return ~value;
	}
}
