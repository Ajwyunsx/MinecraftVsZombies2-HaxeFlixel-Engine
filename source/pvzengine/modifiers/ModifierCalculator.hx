// Ported from: Assets/Scripts/Engine/Level/Modifiers/Calculators/ModifierCalculator.cs
package pvzengine.modifiers;

// PORT-NOTE: C# 中 ModifierCalculator 有三个同名不同类型（arity 0 / 1 / 2）。
// Haxe 同一模块内不能有同名类型，因此：
//   ModifierCalculator                     → 保留原名（非泛型基类）
//   ModifierCalculator<TValue>             → ValueModifierCalculator<TValue>
//   ModifierCalculator<TValue, TModifier>  → TypedModifierCalculator<TValue, TModifier>
// PORT-NOTE: C# 中的 struct ModifierSourceItem 拆分为独立模块 ModifierSourceItem.hx
// （便于跨文件 `import pvzengine.modifiers.ModifierSourceItem;`）。
class ModifierCalculator
{
	public function new()
	{
	}
	// abstract
	public function Calculate(value:Dynamic, modifiers:Array<ModifierSourceItem>):Dynamic
	{
		return value;
	}
	// PORT-NOTE: 替代 C# 的 LINQ `GroupBy(m => m.modifier?.Priority ?? 0).OrderBy(g => g.Key)`。
	public static function GroupByPriority(modifiers:Array<ModifierSourceItem>):Array<Array<ModifierSourceItem>>
	{
		var order:Array<Int> = [];
		var groups:Map<Int, Array<ModifierSourceItem>> = new Map();
		for (modi in modifiers)
		{
			var priority = modi.modifier == null ? 0 : modi.modifier.Priority;
			if (!groups.exists(priority))
			{
				groups.set(priority, []);
				order.push(priority);
			}
			groups.get(priority).push(modi);
		}
		order.sort(function(a, b) return a - b);
		var result:Array<Array<ModifierSourceItem>> = [];
		for (priority in order)
		{
			result.push(groups.get(priority));
		}
		return result;
	}
}

class ValueModifierCalculator<TValue> extends ModifierCalculator
{
	public function new()
	{
		super();
	}
	public override function Calculate(value:Dynamic, modifiers:Array<ModifierSourceItem>):Dynamic
	{
		// PORT-NOTE: C# 用 `value.TryToGeneric<TValue>(out var tValue)` 做运行期泛型检查；
		// Haxe 泛型被擦除，无法做等价的运行期检查，直接按 TValue 处理（由调用方保证类型一致）。
		return CalculateGeneric(cast value, modifiers);
	}
	// abstract
	public function CalculateGeneric(value:Null<TValue>, modifiers:Array<ModifierSourceItem>):Null<TValue>
	{
		throw "abstract";
	}
}

class TypedModifierCalculator<TValue, TModifier> extends ValueModifierCalculator<TValue>
{
	public function new()
	{
		super();
	}
}
