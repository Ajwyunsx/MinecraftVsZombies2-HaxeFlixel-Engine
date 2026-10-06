// Ported from: Assets/Scripts/Engine/Level/SeedPacks/EngineRechargeProps.cs
// PORT-NOTE: 该 C# 文件的 namespace 为 PVZEngine.Level（文件位于 Level/SeedPacks/ 目录，属 SeedPacks 工作包）。
//   既有上层调用点使用 `import pvzengine.seedpacks.EngineRechargeProps;`（4 处，无第二种写法），故实现放在本包。
package pvzengine.seedpacks;

import pvzengine.PropertyMeta;
import pvzengine.PropertyRegions;

@:propertyRegistryRegion(PropertyRegions.recharge)
class EngineRechargeProps
{
	public static var START_MAX_RECHARGE:PropertyMeta<Int> = new PropertyMeta<Int>("startMaxRecharge");
	public static function GetStartMaxRecharge(def:RechargeDefinition):Int
	{
		return def.GetProperty(START_MAX_RECHARGE);
	}
	public static var MAX_RECHARGE:PropertyMeta<Int> = new PropertyMeta<Int>("maxRecharge");
	public static function GetMaxRecharge(def:RechargeDefinition):Int
	{
		return def.GetProperty(MAX_RECHARGE);
	}
	public static var QUALITY:PropertyMeta<Int> = new PropertyMeta<Int>("quality");
	public static function GetQuality(def:RechargeDefinition):Int
	{
		return def.GetProperty(QUALITY);
	}
	public static var NAME:PropertyMeta<String> = new PropertyMeta<String>("name");
	public static function GetName(def:RechargeDefinition):Null<String>
	{
		return def.GetProperty(NAME);
	}
}
