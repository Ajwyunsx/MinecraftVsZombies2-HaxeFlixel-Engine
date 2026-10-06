// Ported from: Assets/Scripts/Engine/Level/Modifiers/Calculators/ModifierCalculator.cs (struct ModifierSourceItem)
// PORT-NOTE: 原 C# 文件为 Calculators/ModifierCalculator.cs，其中 ModifierSourceItem 是 struct。
// 该类型被 Level/Buffs/BuffList.cs、Level/Entities/Entity_Modifiers.cs、Level/Level/LevelEngine_Modifiers.cs、
// Level/Properties/ModifiableProperties.cs 等多个文件跨模块引用，故在 Haxe 中拆分为独立模块，
// 以便 `import pvzengine.modifiers.ModifierSourceItem;` 可以直接解析。
// PORT-NOTE: C# struct 是值语义，Haxe 无 struct，改用普通 class（引用语义）。
package pvzengine.modifiers;

class ModifierSourceItem
{
	public var container:IModifierSource;
	public var modifier:PropertyModifier;

	public function new(container:IModifierSource, modifier:PropertyModifier)
	{
		this.container = container;
		this.modifier = modifier;
	}
}
