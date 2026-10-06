// Ported from: Assets/Scripts/Engine/Level/Aura/AuraEffectList.cs
// PORT-NOTE: C# 重载 Get<T>() / Get(AuraEffectDefinition)（Haxe 不支持重载）。
//   泛型版按上层已移植代码的约定命名 —— mvz2logic/artifacts/Artifact.hx：
//   `public function GetAuraEffect<T:AuraEffectDefinition>():AuraEffect { return auras.GetOfType(); }`，
//   即泛型版名为 GetOfType；非泛型版保留 C# 名字 Get。
// PORT-NOTE: 由于调用点（Artifact.GetAuraEffect）无法传入类型参数（Haxe 不支持显式类型参数调用），
//   GetOfType 的类对象参数为可选：未传入时退化为返回第一个光环效果（上层这些调用点每个来源只有一个光环定义）。
package pvzengine.auras;

import pvzengine.level.LevelEngine;

class AuraEffectList
{
	// PORT-NOTE: Haxe 4.3 不再为无构造函数的类自动生成默认构造函数，C# 的隐式默认构造需显式写出。
	public function new() {}
	public function Add(level:LevelEngine, auraEffect:AuraEffect):Void
	{
		auraEffects.push(auraEffect);
	}
	public function Remove(level:LevelEngine, auraEffect:AuraEffect):Bool
	{
		return auraEffects.remove(auraEffect);
	}
	public function PostAdd():Void
	{
		for (auraEffect in auraEffects)
		{
			auraEffect.PostAdd();
		}
	}
	public function PostRemove():Void
	{
		for (auraEffect in auraEffects)
		{
			auraEffect.PostRemove();
		}
	}
	// C#: public AuraEffect Get<T>() where T : AuraEffectDefinition
	public function GetOfType<T:AuraEffectDefinition>(?type:Class<T>):AuraEffect
	{
		if (type == null)
		{
			// PORT-NOTE: 调用点无法提供类型时的退化行为，见文件头说明。
			return auraEffects.length > 0 ? auraEffects[0] : null;
		}
		return Lambda.find(auraEffects, a -> Std.isOfType(a.Definition, type));
	}
	public function Get(auraDef:AuraEffectDefinition):AuraEffect
	{
		return Lambda.find(auraEffects, a -> a.Definition == auraDef);
	}
	public function GetAll():Array<AuraEffect>
	{
		return auraEffects.copy();
	}
	public function Update():Void
	{
		for (aura in auraEffects)
		{
			aura.UpdateAuraInterval();
		}
	}
	public function LoadFromSerializable(level:LevelEngine, effects:Array<SerializableAuraEffect>):Void
	{
		if (effects == null)
			return;
		for (aura in auraEffects)
		{
			var seri = Lambda.find(effects, e -> e != null && e.id == aura.ID);
			if (seri == null)
				continue;
			aura.LoadFromSerializable(level, seri);
		}
	}
	private var auraEffects:Array<AuraEffect> = [];
}
