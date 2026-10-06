// Ported from: Assets/Scripts/Logic/Placements/LogicPlaceProps.cs
package mvz2logic.placements;

import pvzengine.PropertyMeta;
import pvzengine.PropertyRegions;
import pvzengine.placements.PlaceParams;

@:propertyRegistryRegion(PropertyRegions.placeParams)
class LogicPlaceProps
{
	public static var COMMAND_BLOCK:PropertyMeta<Bool> = new PropertyMeta<Bool>("commandBlock");
	// PORT-NOTE: C# 扩展方法 -> 静态方法
	public static function IsCommandBlock(param:PlaceParams):Bool return param.GetProperty(COMMAND_BLOCK);
	public static function SetCommandBlock(param:PlaceParams, value:Bool):Void return param.SetProperty(COMMAND_BLOCK, value);
	public static var VARIANT:PropertyMeta<Int> = new PropertyMeta<Int>("variant");
	public static function GetVariant(param:PlaceParams):Int return param.GetProperty(VARIANT);
	public static function SetVariant(param:PlaceParams, value:Int):Void return param.SetProperty(VARIANT, value);
}
