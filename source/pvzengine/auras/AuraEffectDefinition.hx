// Ported from: Assets/Scripts/Engine/Level/Aura/AuraEffectDefinition.cs
// PORT-NOTE: C# abstract class → Haxe 普通 class，抽象方法 GetAuraTargets 用 throw "abstract"（PORTING.md）。
// PORT-NOTE: C# { get; protected set; } → Haxe (default, null)（private 写在 Haxe 中允许子类访问）。
package pvzengine.auras;

import pvzengine.NamespaceID;
import pvzengine.buffs.Buff;

// abstract
class AuraEffectDefinition
{
	public function new(buffID:NamespaceID, updateInterval:Int = 1)
	{
		BuffID = buffID;
		UpdateInterval = updateInterval;
	}
	public function PostAdd(auraEffect:AuraEffect):Void {}
	public function PostRemove(auraEffect:AuraEffect):Void {}
	public function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
	{
		// abstract
		throw 'abstract';
	}
	public function UpdateTargetBuff(effect:AuraEffect, target:IBuffTarget, buff:Buff):Void {}
	public var BuffID(default, null):NamespaceID;
	public var UpdateInterval(default, null):Int = 1;
}
