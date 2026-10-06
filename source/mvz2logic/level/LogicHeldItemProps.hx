// Ported from: Assets/Scripts/Logic/HeldItems/LogicHeldItemProps.cs
// PORT-NOTE: 源文件 namespace 为 MVZ2Logic.Level，按 namespace→package 规则放在 mvz2logic.level 包。
package mvz2logic.level;

import haxe.Int64;
import mvz2logic.helditems.IHeldItemPropertyContainer;
import mvz2logic.LogicPropertyRegions;
import pvzengine.PropertyMeta;

@:propertyRegistryRegion(LogicPropertyRegions.heldItem)
class LogicHeldItemProps
{
	static function Get<T>(name:String, ?defaultValue:T):PropertyMeta<T>
	{
		return new PropertyMeta<T>(name, defaultValue);
	}

	//region 种子包索引
	public static var SEED_PACK_INDEX:PropertyMeta<Int> = new PropertyMeta<Int>("seed_pack_index");
	public static function GetSeedPackIndex(container:IHeldItemPropertyContainer):Int
	{
		return container.GetProperty(SEED_PACK_INDEX);
	}
	public static function SetSeedPackIndex(container:IHeldItemPropertyContainer, value:Int):Void
	{
		container.SetProperty(SEED_PACK_INDEX, value);
	}
	//endregion

	//region 实体ID
	public static var ENTITY_ID:PropertyMeta<Int64> = new PropertyMeta<Int64>("entity_id");
	public static function GetEntityID(container:IHeldItemPropertyContainer):Int64
	{
		return container.GetProperty(ENTITY_ID);
	}
	public static function SetEntityID(container:IHeldItemPropertyContainer, value:Int64):Void
	{
		container.SetProperty(ENTITY_ID, value);
	}
	//endregion

	//region 立即触发
	public static var INSTANT_TRIGGER:PropertyMeta<Bool> = new PropertyMeta<Bool>("instant_trigger");
	public static function IsInstantTrigger(container:IHeldItemPropertyContainer):Bool
	{
		return container.GetProperty(INSTANT_TRIGGER);
	}
	public static function SetInstantTrigger(container:IHeldItemPropertyContainer, value:Bool):Void
	{
		container.SetProperty(INSTANT_TRIGGER, value);
	}
	//endregion

	//region 立即触发
	public static var INSTANT_EVOKE:PropertyMeta<Bool> = new PropertyMeta<Bool>("instant_evoke");
	public static function IsInstantEvoke(container:IHeldItemPropertyContainer):Bool
	{
		return container.GetProperty(INSTANT_EVOKE);
	}
	public static function SetInstantEvoke(container:IHeldItemPropertyContainer, value:Bool):Void
	{
		container.SetProperty(INSTANT_EVOKE, value);
	}
	//endregion

	//region 无法取消
	public static var CANNOT_CANCEL:PropertyMeta<Bool> = new PropertyMeta<Bool>("cannot_cancel");
	public static function CannotCancel(container:IHeldItemPropertyContainer):Bool
	{
		return container.GetProperty(CANNOT_CANCEL);
	}
	public static function SetCannotCancel(container:IHeldItemPropertyContainer, value:Bool):Void
	{
		container.SetProperty(CANNOT_CANCEL, value);
	}
	//endregion

	private function new() {}
}
