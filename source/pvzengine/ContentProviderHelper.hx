// Ported from: Assets/Scripts/Engine/Level/ContentProviderHelper.cs
// PORT-NOTE: C# 的扩展方法（this IGameContent provider）在移植层保留为「provider 为首参」的静态方法，
//   既有调用点通过 `using pvzengine.ContentProviderHelper;` 以实例形式调用
//   （见 mvz2logic/options/LogicOptionExt.hx 的 `Global.Game.GetAllDifficultyDefinitions()`、
//   mvz2/modding/ModLoader.hx 的 `mod.GetAllGridDefinitions()`）。
// PORT-NOTE: C# 的泛型方法（GetDefinitionByType<T>(type)、GetBuffDefinition<T>() 等）无法在 Haxe 调用点
//   书写类型参数，按工程既有约定（同 pvzengine.IGameContent.GetDefinition(Class<T>, ...)）改为传入类型对象；
//   与 C# 中同名的非泛型重载冲突的，泛型版加 ByType 后缀（Haxe 不支持重载）。
package pvzengine;

import pvzengine.NamespaceID;
import pvzengine.armors.ArmorBehaviourDefinition;
import pvzengine.armors.ArmorDefinition;
import pvzengine.base.Definition;
import pvzengine.buffs.BuffDefinition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.difficulties.DifficultyDefinition;
import pvzengine.entities.EntityBehaviourDefinition;
import pvzengine.entities.EntityDefinition;
import pvzengine.level.AreaDefinition;
import pvzengine.level.StageDefinition;
import pvzengine.placements.PlacementDefinition;
import pvzengine.seedpacks.RechargeDefinition;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.shells.ShellDefinition;
import pvzengine.spawns.SpawnDefinition;

class ContentProviderHelper
{
	public static function GetDefinitionByType<T:Definition>(provider:IGameContent, cls:Class<T>, type:String):T
	{
		var definitions = provider.GetDefinitions(cls, type);
		// C#: .FirstOrDefault()
		return definitions != null && definitions.length > 0 ? definitions[0] : null;
	}
	// C#: GetBuffDefinition<T>(this IGameContent provider) where T : BuffDefinition
	// PORT-NOTE: 与同名的非泛型重载 GetBuffDefinition(provider, defRef) 冲突，泛型版加 ByType 后缀。
	public static function GetBuffDefinitionByType<T:BuffDefinition>(provider:IGameContent, cls:Class<T>):T
	{
		return GetDefinitionByType(provider, cls, EngineDefinitionTypes.BUFF);
	}
	// C#: GetArmorDefinition<T>(this IGameContent provider) where T : ArmorDefinition
	// PORT-NOTE: 同上，泛型版加 ByType 后缀。
	public static function GetArmorDefinitionByType<T:ArmorDefinition>(provider:IGameContent, cls:Class<T>):T
	{
		return GetDefinitionByType(provider, cls, EngineDefinitionTypes.ARMOR);
	}
	public static function GetEntityDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<EntityDefinition>
	{
		return provider.GetDefinition(EntityDefinition, EngineDefinitionTypes.ENTITY, defRef);
	}
	public static function GetAllEntityDefinitions(provider:IGameContent):Array<EntityDefinition>
	{
		return provider.GetDefinitions(EntityDefinition, EngineDefinitionTypes.ENTITY);
	}
	public static function GetEntityBehaviourDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<EntityBehaviourDefinition>
	{
		return provider.GetDefinition(EntityBehaviourDefinition, EngineDefinitionTypes.ENTITY_BEHAVIOUR, defRef);
	}
	public static function GetSeedDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<SeedDefinition>
	{
		return provider.GetDefinition(SeedDefinition, EngineDefinitionTypes.SEED, defRef);
	}
	public static function GetRechargeDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<RechargeDefinition>
	{
		return provider.GetDefinition(RechargeDefinition, EngineDefinitionTypes.RECHARGE, defRef);
	}
	public static function GetShellDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<ShellDefinition>
	{
		return provider.GetDefinition(ShellDefinition, EngineDefinitionTypes.SHELL, defRef);
	}
	public static function GetPlacementDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<PlacementDefinition>
	{
		return provider.GetDefinition(PlacementDefinition, EngineDefinitionTypes.PLACEMENT, defRef);
	}
	public static function GetAreaDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<AreaDefinition>
	{
		return provider.GetDefinition(AreaDefinition, EngineDefinitionTypes.AREA, defRef);
	}
	public static function GetAllAreaDefinitions(provider:IGameContent):Array<AreaDefinition>
	{
		return provider.GetDefinitions(AreaDefinition, EngineDefinitionTypes.AREA);
	}
	public static function GetStageDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<StageDefinition>
	{
		return provider.GetDefinition(StageDefinition, EngineDefinitionTypes.STAGE, defRef);
	}
	public static function GetAllStageDefinitions(provider:IGameContent):Array<StageDefinition>
	{
		return provider.GetDefinitions(StageDefinition, EngineDefinitionTypes.STAGE);
	}
	public static function GetGridDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<pvzengine.grids.GridDefinition>
	{
		return provider.GetDefinition(pvzengine.grids.GridDefinition, EngineDefinitionTypes.GRID, defRef);
	}
	public static function GetAllGridDefinitions(provider:IGameContent):Array<pvzengine.grids.GridDefinition>
	{
		return provider.GetDefinitions(pvzengine.grids.GridDefinition, EngineDefinitionTypes.GRID);
	}
	public static function GetBuffDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<BuffDefinition>
	{
		return provider.GetDefinition(BuffDefinition, EngineDefinitionTypes.BUFF, defRef);
	}
	public static function GetAllBuffDefinitions(provider:IGameContent):Array<BuffDefinition>
	{
		return provider.GetDefinitions(BuffDefinition, EngineDefinitionTypes.BUFF);
	}
	public static function GetArmorDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<ArmorDefinition>
	{
		return provider.GetDefinition(ArmorDefinition, EngineDefinitionTypes.ARMOR, defRef);
	}
	public static function GetAllArmorDefinitions(provider:IGameContent):Array<ArmorDefinition>
	{
		return provider.GetDefinitions(ArmorDefinition, EngineDefinitionTypes.ARMOR);
	}
	public static function GetArmorBehaviourDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<ArmorBehaviourDefinition>
	{
		return provider.GetDefinition(ArmorBehaviourDefinition, EngineDefinitionTypes.ARMOR_BEHAVIOUR, defRef);
	}
	public static function GetSpawnDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<SpawnDefinition>
	{
		return provider.GetDefinition(SpawnDefinition, EngineDefinitionTypes.SPAWN, defRef);
	}
	public static function GetAllSpawnDefinitions(provider:IGameContent):Array<SpawnDefinition>
	{
		return provider.GetDefinitions(SpawnDefinition, EngineDefinitionTypes.SPAWN);
	}
	public static function GetDifficultyDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<DifficultyDefinition>
	{
		return provider.GetDefinition(DifficultyDefinition, EngineDefinitionTypes.DIFFICULTY, defRef);
	}
	public static function GetAllDifficultyDefinitions(provider:IGameContent):Array<DifficultyDefinition>
	{
		return provider.GetDefinitions(DifficultyDefinition, EngineDefinitionTypes.DIFFICULTY);
	}
}
