// Ported from: Assets/Scripts/Engine/Level/Modifiers/NumberModifiers/MaxHealthModifier.cs (class ArmorMaxHealthModifier)
// PORT-NOTE: 原 C# 文件同时定义了 MaxHealthModifier 与 ArmorMaxHealthModifier 两个顶层类。
// 既有上层调用点写作 `import pvzengine.modifiers.ArmorMaxHealthModifier;`，因此按调用点为准，
// 将 ArmorMaxHealthModifier 拆到本独立模块中。
package pvzengine.modifiers;

import pvzengine.armors.EngineArmorProps;

class ArmorMaxHealthModifier extends FloatModifier
{
	// PORT-NOTE: C# 的两个构造函数重载（第二参数为 float 常量或 PropertyKey<float>）合并为第二参数为 Dynamic 的构造函数。
	public function new(op:NumberOperator, value:Dynamic, priority:Int = 0)
	{
		super(EngineArmorProps.MAX_HEALTH, op, value, priority);
	}
}
