// Ported from: Assets/Scripts/Engine/Level/Armors/ArmorBehaviourDefinition.cs
// PORT-NOTE: 上层 5 个文件以 `import pvzengine.definitions.ArmorBehaviourDefinition;` 引用本类
//   （C# 命名空间为 PVZEngine.Armors），故本类保留在 pvzengine.armors，
//   并在 pvzengine.definitions 下提供同名 typedef 别名，两种 import 均可用。
package pvzengine.armors;

import pvzengine.auras.AuraEffectDefinition;
import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;

// abstract
class ArmorBehaviourDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	// virtual
	public function PostUpdate(armor:Armor):Void {}
	public function GetAuras():Array<AuraEffectDefinition>
	{
		return auraDefinitions.copy();
	}
	// C#: protected → Haxe private（Haxe 的 private 成员允许子类访问）
	private function AddAura(aura:AuraEffectDefinition):Void
	{
		auraDefinitions.push(aura);
	}
	public override function GetDefinitionType():String
	{
		// C#: sealed override
		return EngineDefinitionTypes.ARMOR_BEHAVIOUR;
	}
	private var auraDefinitions:Array<AuraEffectDefinition> = [];
}
