// Ported from: Assets/Scripts/Logic/Definitions/DefinitionAttribute.cs
package mvz2logic.definitions;

import pvzengine.DefinitionAttribute;

// PORT-NOTE: 本 C# 文件并不定义 DefinitionAttribute 本身（它来自 PVZEngine），只定义其 Auto* 子类，
// 因此模块名与主类型名不一致（模块 DefinitionAttribute，主类型 AutoSeedOptionDefinitionAttribute）。
// PORT-NOTE: C# 特性类在 Haxe 中用于 `@:autoXxxDefinition("name")` 元数据标注（无反射注册），
// 仍保留这些类以 1:1 记录原类型/名称常量映射。
class AutoSeedOptionDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.SEED_OPTION);
	}
}

class AutoNoteDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.NOTE);
	}
}

class AutoArtifactDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.ARTIFACT);
	}
}

class AutoHeldItemDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.HELD_ITEM);
	}
}

class AutoHeldItemBehaviourDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.HELD_ITEM_BEHAVIOUR);
	}
}

class AutoIZombieLayoutDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.I_ZOMBIE_LAYOUT);
	}
}

class AutoCommandDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.COMMAND);
	}
}

class AutoOptionWidgetDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.OPTION_WIDGET);
	}
}

class AutoMapElementDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.MAP_ELEMENT);
	}
}

class AutoMapElementBehaviourDefinitionAttribute extends DefinitionAttribute
{
	public function new(name:String)
	{
		super(name, LogicDefinitionTypes.MAP_ELEMENT_BEHAVIOUR);
	}
}
