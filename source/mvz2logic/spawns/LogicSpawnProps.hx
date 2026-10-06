// Ported from: Assets/Scripts/Logic/Spawns/LogicSpawnProps.cs
package mvz2logic.spawns;

import pvzengine.NamespaceID;
import pvzengine.PropertyMeta;
import pvzengine.PropertyRegions;
import pvzengine.spawns.SpawnDefinition;

@:propertyRegistryRegion(PropertyRegions.spawn)
class LogicSpawnProps
{
	static function Get<T>(name:String):PropertyMeta<T>
	{
		return new PropertyMeta<T>(name);
	}
	//region 最小生成波次
	public static var MIN_SPAWN_WAVE:PropertyMeta<Int> = Get("minSpawnWave");
	public static function GetMinSpawnWave(def:SpawnDefinition):Int
	{
		return def.GetProperty(MIN_SPAWN_WAVE);
	}
	//endregion

	//region 生成等级
	public static var SPAWN_LEVEL:PropertyMeta<Int> = Get("spawn_level");
	public static function GetSpawnLevel(def:SpawnDefinition):Int
	{
		return def.GetProperty(SPAWN_LEVEL);
	}
	//endregion

	//region 水路生成
	public static var SPAWN_IN_WATER:PropertyMeta<Bool> = Get("spawn_in_water");
	public static function SpawnInWater(def:SpawnDefinition):Bool
	{
		return def.GetProperty(SPAWN_IN_WATER);
	}
	//endregion

	//region 空路生成
	public static var SPAWN_IN_AIR:PropertyMeta<Bool> = Get("spawn_in_air");
	public static function SpawnInAir(def:SpawnDefinition):Bool
	{
		return def.GetProperty(SPAWN_IN_AIR);
	}
	//endregion

	//region 生成实体
	public static var SPAWN_ENTITY:PropertyMeta<NamespaceID> = Get("spawn_entity");
	public static function GetSpawnEntity(def:SpawnDefinition):Null<NamespaceID>
	{
		return def.GetProperty(SPAWN_ENTITY);
	}
	//endregion

	//region 生成实体变种
	public static var SPAWN_ENTITY_VARIANT:PropertyMeta<Int> = Get("spawn_entity_variant");
	public static function GetSpawnEntityVariant(def:SpawnDefinition):Int
	{
		return def.GetProperty(SPAWN_ENTITY_VARIANT);
	}
	//endregion

	//region 无尽模式禁用
	public static var NO_ENDLESS:PropertyMeta<Bool> = Get("no_endless");
	public static function IsNoEndless(def:SpawnDefinition):Bool
	{
		return def.GetProperty(NO_ENDLESS);
	}
	//endregion

	//region 排除的场地标签
	public static var EXCLUDED_AREA_TAGS:PropertyMeta<Array<NamespaceID>> = Get("excluded_area_tags");
	public static function GetExcludedAreaTags(def:SpawnDefinition):Null<Array<NamespaceID>>
	{
		return def.GetProperty(EXCLUDED_AREA_TAGS);
	}
	//endregion

	//region 预览实体
	public static var PREVIEW_ENTITY:PropertyMeta<NamespaceID> = Get("preview_entity");
	public static function GetPreviewEntity(def:SpawnDefinition):Null<NamespaceID>
	{
		return def.GetProperty(PREVIEW_ENTITY);
	}
	//endregion

	//region 预览实体变种
	public static var PREVIEW_VARIANT:PropertyMeta<Int> = Get("preview_variant");
	public static function GetPreviewVariant(def:SpawnDefinition):Int
	{
		return def.GetProperty(PREVIEW_VARIANT);
	}
	//endregion

	//region 预览实体数量
	public static var PREVIEW_COUNT:PropertyMeta<Int> = Get("previewCount");
	public static function GetPreviewCount(def:SpawnDefinition):Int
	{
		// C#: return def.TryGetProperty(PREVIEW_COUNT, out int value) ? value : 1;
		var value:tools.Ref<Int> = tools.Ref.to(0);
		return def.TryGetProperty(PREVIEW_COUNT, value) ? value.value : 1;
	}
	//endregion

	//region 权重基数
	public static var WEIGHT_BASE:PropertyMeta<Int> = Get("weightBase");
	public static function GetWeightBase(def:SpawnDefinition):Int
	{
		return def.GetProperty(WEIGHT_BASE);
	}
	//endregion

	//region 权重衰减开始旗
	public static var WEIGHT_DECAY_START:PropertyMeta<Int> = Get("weightDecayStart");
	public static function GetWeightDecayStartFlag(def:SpawnDefinition):Int
	{
		return def.GetProperty(WEIGHT_DECAY_START);
	}
	//endregion

	//region 权重衰减结束旗
	public static var WEIGHT_DECAY_END:PropertyMeta<Int> = Get("weightDecayEnd");
	public static function GetWeightDecayEndFlag(def:SpawnDefinition):Int
	{
		return def.GetProperty(WEIGHT_DECAY_END);
	}
	//endregion

	//region 每旗权重衰减
	public static var WEIGHT_DECAY:PropertyMeta<Int> = Get("weightDecay");
	public static function GetWeightDecayPerFlag(def:SpawnDefinition):Int
	{
		return def.GetProperty(WEIGHT_DECAY);
	}
	//endregion

	private function new() {}
}
