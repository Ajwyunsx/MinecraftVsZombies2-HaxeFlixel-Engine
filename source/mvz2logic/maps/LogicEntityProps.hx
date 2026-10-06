// Ported from: Assets/Scripts/Logic/Maps/LogicEntityProps.cs
// PORT-NOTE: 本 C# 文件名为 LogicEntityProps.cs，但其中定义的类为 LogicMapElementProps，模块名与主类型名不一致。
package mvz2logic.maps;

import mvz2logic.LogicPropertyRegions;
import mvz2logic.conditions.IConditionList;
import pvzengine.PropertyMeta;

@:propertyRegistryRegion(LogicPropertyRegions.mapElement)
class LogicMapElementProps
{
	private static function Get<T>(name:String, ?defaultValue:T):PropertyMeta<T>
	{
		return new PropertyMeta<T>(name, defaultValue);
	}
	// #region 形状ID
	public static var UNLOCK_CONDITIONS:PropertyMeta<IConditionList> = Get("unlock_conditions");
	// PORT-NOTE: C# extension method -> static
	public static function GetUnlockConditionsFromDefinition(definition:MapElementDefinition):Null<IConditionList>
	{
		return definition.GetProperty(UNLOCK_CONDITIONS);
	}
	public static function GetUnlockConditions(entity:IMapElement):Null<IConditionList>
	{
		return entity.GetProperty(UNLOCK_CONDITIONS);
	}
	public static function SetUnlockConditions(definition:MapElementDefinition, value:Null<IConditionList>):Void
	{
		definition.SetProperty(UNLOCK_CONDITIONS, value);
	}
	// #endregion
}
