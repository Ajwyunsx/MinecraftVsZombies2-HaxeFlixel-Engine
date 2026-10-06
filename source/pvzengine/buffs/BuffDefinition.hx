// Ported from: Assets/Scripts/Engine/Level/Buffs/BuffDefinition.cs
// PORT-NOTE: 上层 194 个 Buff 定义类以 `import pvzengine.definitions.BuffDefinition;` 引用本类
//   （另有少数文件用 `pvzengine.buffs.BuffDefinition`），故本类保留在 C# 命名空间对应的
//   pvzengine.buffs 包，并在 pvzengine.definitions 下提供同名 typedef 别名，两种 import 均可用。
package pvzengine.buffs;

import pvzengine.IPropertyKey;
import pvzengine.NamespaceID;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.modifiers.PropertyModifier;

// abstract
class BuffDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function GetModifiers():Array<PropertyModifier>
	{
		return modifiers.copy();
	}
	// PORT-NOTE: C# 重载 GetModifiers(IPropertyKey propName)（Haxe 不支持重载）在移植层命名为 GetModifiersForProperty。
	// PORT-NOTE: C# 用 PropertyKeyComparer/Equals 比较属性键，此处按移植层 PropertyKey 的值语义用 == 比较。
	public function GetModifiersForProperty(propName:IPropertyKey):Array<PropertyModifier>
	{
		return [for (m in modifiers) if (m.PropertyName == propName) m];
	}
	public function GetModelInsertions():Array<ModelInsertion>
	{
		return modelInsertions.copy();
	}
	public function GetAuras():Array<AuraEffectDefinition>
	{
		return auraDefinitions.copy();
	}
	public function OnCreate(buff:Buff):Void {}
	public function PostAdd(buff:Buff):Void {}
	public function PostRemove(buff:Buff):Void {}
	public function PostUpdate(buff:Buff):Void {}
	// C#: protected → Haxe private（Haxe 的 private 成员允许子类访问）
	private function AddModifier(modifier:PropertyModifier):Void
	{
		modifiers.push(modifier);
	}
	private function AddModelInsertion(anchorName:String, key:NamespaceID, modelID:NamespaceID):Void
	{
		modelInsertions.push(new ModelInsertion(anchorName, key, modelID));
	}
	private function AddAura(aura:AuraEffectDefinition):Void
	{
		auraDefinitions.push(aura);
	}
	public override function GetDefinitionType():String
	{
		// C#: sealed override
		return EngineDefinitionTypes.BUFF;
	}
	private var modifiers:Array<PropertyModifier> = [];
	private var auraDefinitions:Array<AuraEffectDefinition> = [];
	private var modelInsertions:Array<ModelInsertion> = [];
}
