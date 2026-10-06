// Ported from: Assets/Scripts/Engine/Level/Modifiers/PropertyCalculator.cs
package pvzengine.modifiers;

class PropertyCalculator
{
	// PORT-NOTE: C# 有两个同名扩展方法重载：非泛型的 `CalculateProperty(this IEnumerable<ModifierSourceItem>, object?)`
	// 与泛型的 `CalculateProperty<T>(this IEnumerable<ModifierSourceItem>, T?)`。
	// Haxe 不支持重载，合并为统一的泛型方法：非泛型调用点（value 为 object）会推断为 T = Dynamic。
	// PORT-NOTE: 泛型重载中 C# 会用 `c is not ModifierCalculator<T>` 过滤计算器，Haxe 泛型被擦除无法做该判断；
	// 由调用方保证属性值与计算器的 TValue 一致（CalculatorMap 中每种属性只有唯一的计算器）。
	public static function CalculateProperty<T>(modifiers:Array<ModifierSourceItem>, value:Null<T>):Null<T>
	{
		if (modifiers == null || modifiers.length == 0)
			return value;

		var calculators:Array<ModifierCalculator> = [];
		for (item in modifiers)
		{
			var calculator = item.modifier.GetCalculator();
			if (calculator == null)
				continue;
			if (!calculators.contains(calculator))
			{
				calculators.push(calculator);
			}
		}
		var result:ModifierCalculator = null;
		for (calc in calculators)
		{
			if (result != null)
				// PORT-NOTE: C# 抛出 MultipleValueModifierException（定义于 Level/Buffs/BuffList.cs）；此处用 haxe.Exception 代替。
				throw new haxe.Exception('Modifiers of property has multiple different calculators: ${calculators.join(",")}');
			result = calc;
		}
		if (result == null)
			// PORT-NOTE: C# 抛出 NullReferenceException。
			throw new haxe.Exception('Calculator for property does not exists.');
		return cast result.Calculate(value, modifiers);
	}
}
