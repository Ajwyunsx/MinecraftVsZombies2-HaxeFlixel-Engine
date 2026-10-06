// Ported from: Assets/Scripts/Engine/Level/SeedPacks/RechargeDefinition.cs
package pvzengine.seedpacks;

import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.seedpacks.EngineRechargeProps;

class RechargeDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function GetDefinitionType():String return EngineDefinitionTypes.RECHARGE;

	// PORT-NOTE: C# 中 EngineRechargeProps 的 GetStartMaxRecharge/GetMaxRecharge/GetQuality/GetName
	//   是 RechargeDefinition 的扩展方法，既有上层代码以实例形式调用（rechargeDef.GetQuality() 等，
	//   见 mvz2/gamecontent/contraptions/SoulFurnace.hx），故在此提供实例转发方法；
	//   EngineRechargeProps 中的静态版本保持 C# 原样。
	// #region 调用点兼容（C# 扩展方法 → 实例转发）
	public function GetStartMaxRecharge():Int
	{
		return EngineRechargeProps.GetStartMaxRecharge(this);
	}
	public function GetMaxRecharge():Int
	{
		return EngineRechargeProps.GetMaxRecharge(this);
	}
	public function GetQuality():Int
	{
		return EngineRechargeProps.GetQuality(this);
	}
	public function GetName():Null<String>
	{
		return EngineRechargeProps.GetName(this);
	}
	// #endregion
}
