// Ported from: Assets/Scripts/Engine/Level/SeedPacks/SeedDefinition.cs
package pvzengine.seedpacks;

import pvzengine.NamespaceID;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.seedpacks.EngineSeedProps;

class SeedDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
		SetProperty(EngineSeedProps.RECHARGE_SPEED, 1.0);
	}
	public function Update(seedPack:SeedPack, rechargeSpeed:Float):Void
	{
	}
	public override function GetDefinitionType():String return EngineDefinitionTypes.SEED;
	public function GetAuraCount():Int
	{
		return auraDefinitions.length;
	}
	public function GetAuraAt(index:Int):AuraEffectDefinition
	{
		return auraDefinitions[index];
	}
	// C#: protected void AddAura(AuraEffectDefinition aura)
	// PORT-NOTE: Haxe 无 protected，private 成员对子类可见，语义等价。
	private function AddAura(aura:AuraEffectDefinition):Void
	{
		auraDefinitions.push(aura);
	}
	private var auraDefinitions:Array<AuraEffectDefinition> = [];

	// PORT-NOTE: C# 中 EngineSeedProps 的 GetRechargeID/GetCost 是 SeedDefinition 的扩展方法，
	//   既有上层代码以实例形式调用（definition.GetRechargeID() / definition.GetCost()，见
	//   mvz2/modding/ModLoader.hx、mvz2logic/blueprints/LogicSeedProps.hx 等），且接收者常为子类
	//   （EntitySeed / OptionSeed）静态类型，Haxe 的 @:using 不会沿继承链生效，故在此提供实例转发方法；
	//   EngineSeedProps 中的静态版本保持 C# 原样。
	// #region 调用点兼容（C# 扩展方法 → 实例转发）
	public function GetRechargeID():Null<NamespaceID>
	{
		return EngineSeedProps.GetRechargeIDOfDefinition(this);
	}
	public function GetCost():Float
	{
		return EngineSeedProps.GetCost(this);
	}
	// #endregion
}
