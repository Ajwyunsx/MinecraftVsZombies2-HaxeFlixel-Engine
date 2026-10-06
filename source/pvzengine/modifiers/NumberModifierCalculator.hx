// Ported from: Assets/Scripts/Engine/Level/Modifiers/Calculators/NumberModifierCalculator.cs
package pvzengine.modifiers;

import pvzengine.modifiers.ModifierCalculator.TypedModifierCalculator;

import unity.Vector3;

class NumberModifierCalculator<T> extends TypedModifierCalculator<T, NumberModifier<T>>
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
			var setValue:Null<T> = value;
			var addValue:Null<T> = GetDefaultValue();
			var multiple:Null<T> = GetDefaultMultiple();
			var multiply:Null<T> = GetDefaultMultiple();
			for (modi in layerModifiers)
			{
				var buff = modi.container;
				if (!Std.isOfType(modi.modifier, NumberModifier))
					continue;
				var modifier:NumberModifier<T> = cast modi.modifier;
				var modifierValue = modifier.GetModifierValueGeneric(buff);
				if (!modifier.FitsConditionGeneric(modifierValue))
					continue;
				switch (modifier.Operator)
				{
					case NumberOperator.Set:
						setValue = modifierValue;
					case NumberOperator.Add:
						addValue = AddValue(addValue, modifierValue);
					case NumberOperator.AddMultiple:
						multiple = AddValue(multiple, modifierValue);
					case NumberOperator.Multiply:
						multiply = MultiplyValue(multiply, modifierValue);
				}
			}
			value = setValue;
			value = AddValue(value, addValue);
			value = MultiplyValue(value, multiple);
			value = MultiplyValue(value, multiply);
		}
		return value;
	}
	// abstract
	function GetDefaultMultiple():T
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
}

class FloatCalculator extends NumberModifierCalculator<Float>
{
	public function new()
	{
		super();
	}
	override function GetDefaultMultiple():Float
	{
		return 1;
	}
	override function GetDefaultValue():Float
	{
		return 0;
	}
	override function AddValue(value1:Null<Float>, value2:Null<Float>):Null<Float>
	{
		return value1 + value2;
	}
	override function MultiplyValue(value1:Null<Float>, value2:Null<Float>):Null<Float>
	{
		return value1 * value2;
	}
}

class Vector3Calculator extends NumberModifierCalculator<Vector3>
{
	public function new()
	{
		super();
	}
	override function GetDefaultMultiple():Vector3
	{
		return Vector3.one;
	}
	override function GetDefaultValue():Vector3
	{
		return Vector3.zero;
	}
	override function AddValue(value1:Null<Vector3>, value2:Null<Vector3>):Null<Vector3>
	{
		// PORT-NOTE: unity.Vector3 是 abstract，Null<Vector3> 上无法直接使用运算符，先 cast 掉可空包装。
		var a:Vector3 = cast value1;
		var b:Vector3 = cast value2;
		return new Vector3(a.x + b.x, a.y + b.y, a.z + b.z);
	}
	override function MultiplyValue(value1:Null<Vector3>, value2:Null<Vector3>):Null<Vector3>
	{
		var a:Vector3 = cast value1;
		var b:Vector3 = cast value2;
		return Vector3.Scale(a, b);
	}
}
