// Ported from: Assets/Scripts/Engine/Level/Entities/EntityBehaviourDefinition.cs
package pvzengine.entities;

import pvzengine.NamespaceID;
import pvzengine.armors.Armor;
import pvzengine.armors.ArmorDestroyInfo;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.base.Definition;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageInput;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.modifiers.PropertyModifier;
import unity.Vector3;

// PORT-NOTE: C# abstract class → Haxe 普通 class（PORTING.md §abstract）。
// PORT-NOTE: C# 的 virtual 空实现方法在 Haxe 中保留为「空体的普通方法」，子类可用 override 覆盖。
// PORT-NOTE: C# 的 protected 成员在 Haxe 中写作 private（Haxe 的 private 允许子类访问）。
class EntityBehaviourDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function Init(entity:Entity):Void {}
	public function Update(entity:Entity):Void {}
	public function PreTakeDamage(input:DamageInput, result:CallbackResult):Void {}
	public function PostTakeDamage(result:DamageOutput):Void {}
	public function PostContactGround(entity:Entity, velocity:Vector3):Void {}
	public function PostLeaveGround(entity:Entity):Void {}
	public function PreCollision(collision:EntityCollision, result:CallbackResult):Void {}
	public function PostCollision(collision:EntityCollision, state:Int):Void {}
	public function PreDeath(entity:Entity, deathInfo:DeathInfo, result:CallbackResult):Void {}
	public function PostDeath(entity:Entity, deathInfo:DeathInfo):Void {}
	public function PostRemove(entity:Entity):Void {}
	public function PostEquipArmor(entity:Entity, slot:NamespaceID, armor:Armor):Void {}
	public function PostDestroyArmor(entity:Entity, slot:NamespaceID, armor:Armor, result:ArmorDestroyInfo):Void {}
	public function PostRemoveArmor(entity:Entity, slot:NamespaceID, armor:Armor):Void {}
	public function GetModelID(origin:NamespaceID):NamespaceID
	{
		return origin;
	}
	public function GetAuras():Array<AuraEffectDefinition>
	{
		// PORT-NOTE: C# 返回的是内部 List 的副本（ToArray），此处同样返回副本。
		return auraDefinitions.copy();
	}
	private function AddAura(aura:AuraEffectDefinition):Void
	{
		auraDefinitions.push(aura);
	}
	public function GetModifiers():Array<PropertyModifier>
	{
		return modifiers.copy();
	}
	private function AddModifier(modifier:PropertyModifier):Void
	{
		modifiers.push(modifier);
	}
	// C#: public sealed override string GetDefinitionType()
	override public function GetDefinitionType():String
	{
		return EngineDefinitionTypes.ENTITY_BEHAVIOUR;
	}
	private var auraDefinitions:Array<AuraEffectDefinition> = [];
	private var modifiers:Array<PropertyModifier> = [];
}
