// Ported from: Assets/Scripts/Logic/Game/LogicGameDefinitionsExt.cs
// PORT-NOTE: C# 泛型方法 GetDefinition<T>(type, defRef)/GetDefinitions<T>(type) 在 Haxe 中无法
// 从参数推断 T（C# 显式写了类型实参），按工程既有约定（同 unity.GameObject.GetComponent）改为
// 传入类型对象：GetDefinition(HeldItemDefinition, type, defRef)。
package mvz2logic.games;

import mvz2logic.armors.ArmorSlotDefinition;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.blueprints.EntitySeedDefinition;
import mvz2logic.blueprints.SeedOptionDefinition;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.definitions.LogicDefinitionTypes;
import mvz2logic.entities.EntityCounterDefinition;
import mvz2logic.errors.ErrorMessageDefinition;
import mvz2logic.grids.GridLayerDefinition;
import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.HeldItemDefinition;
import mvz2logic.izombie.IZombieLayoutDefinition;
import mvz2logic.maps.MapElementBehaviourDefinition;
import mvz2logic.maps.MapElementDefinition;
import mvz2logic.notes.NoteDefinition;
import mvz2logic.options.OptionWidgetDefinition;
import mvz2logic.shapes.ShapeDefinition;
import pvzengine.IGameContent;
import pvzengine.NamespaceID;

class LogicGameDefinitionsExt
{
	public static function GetHeldItemDefinition(provider:IGameContent, heldType:Null<NamespaceID>):Null<HeldItemDefinition>
	{
		return provider.GetDefinition(HeldItemDefinition, LogicDefinitionTypes.HELD_ITEM, heldType);
	}
	public static function GetHeldItemBehaviourDefinition(provider:IGameContent, heldType:Null<NamespaceID>):Null<HeldItemBehaviourDefinition>
	{
		return provider.GetDefinition(HeldItemBehaviourDefinition, LogicDefinitionTypes.HELD_ITEM_BEHAVIOUR, heldType);
	}
	public static function GetArtifactDefinition(provider:IGameContent, defRef:Null<NamespaceID>):Null<ArtifactDefinition>
	{
		return provider.GetDefinition(ArtifactDefinition, LogicDefinitionTypes.ARTIFACT, defRef);
	}
	public static function GetAllArtifactDefinitions(provider:IGameContent):Array<ArtifactDefinition>
	{
		return provider.GetDefinitions(ArtifactDefinition, LogicDefinitionTypes.ARTIFACT);
	}
	public static function GetSeedOptionDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<SeedOptionDefinition>
	{
		return provider.GetDefinition(SeedOptionDefinition, LogicDefinitionTypes.SEED_OPTION, id);
	}
	public static function GetNoteDefinition(provider:IGameContent, heldType:Null<NamespaceID>):Null<NoteDefinition>
	{
		return provider.GetDefinition(NoteDefinition, LogicDefinitionTypes.NOTE, heldType);
	}
	public static function GetAllNoteDefinitions(provider:IGameContent):Array<NoteDefinition>
	{
		return provider.GetDefinitions(NoteDefinition, LogicDefinitionTypes.NOTE);
	}
	public static function GetIZombieLayoutDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<IZombieLayoutDefinition>
	{
		return provider.GetDefinition(IZombieLayoutDefinition, LogicDefinitionTypes.I_ZOMBIE_LAYOUT, id);
	}
	public static function GetArmorSlotDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<ArmorSlotDefinition>
	{
		return provider.GetDefinition(ArmorSlotDefinition, LogicDefinitionTypes.ARMOR_SLOT, id);
	}
	public static function GetAllArmorSlotDefinitions(provider:IGameContent):Array<ArmorSlotDefinition>
	{
		return provider.GetDefinitions(ArmorSlotDefinition, LogicDefinitionTypes.ARMOR_SLOT);
	}
	public static function GetSeedErrorDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<ErrorMessageDefinition>
	{
		return provider.GetDefinition(ErrorMessageDefinition, LogicDefinitionTypes.SEED_ERROR, id);
	}
	public static function GetGridErrorDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<ErrorMessageDefinition>
	{
		return provider.GetDefinition(ErrorMessageDefinition, LogicDefinitionTypes.GRID_ERROR, id);
	}
	public static function GetGridLayerDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<GridLayerDefinition>
	{
		return provider.GetDefinition(GridLayerDefinition, LogicDefinitionTypes.GRID_LAYER, id);
	}
	public static function GetEntityCounterDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<EntityCounterDefinition>
	{
		return provider.GetDefinition(EntityCounterDefinition, LogicDefinitionTypes.ENTITY_COUNTER, id);
	}
	public static function GetCommandDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<CommandDefinition>
	{
		return provider.GetDefinition(CommandDefinition, LogicDefinitionTypes.COMMAND, id);
	}
	public static function GetAllCommandDefinitions(provider:IGameContent):Array<CommandDefinition>
	{
		return provider.GetDefinitions(CommandDefinition, LogicDefinitionTypes.COMMAND);
	}
	public static function GetEntitySeedDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<EntitySeedDefinition>
	{
		return provider.GetDefinition(EntitySeedDefinition, LogicDefinitionTypes.ENTITY_SEED, id);
	}
	public static function GetShapeDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<ShapeDefinition>
	{
		return provider.GetDefinition(ShapeDefinition, LogicDefinitionTypes.SHAPE, id);
	}
	public static function GetAllShapeDefinitions(provider:IGameContent):Array<ShapeDefinition>
	{
		return provider.GetDefinitions(ShapeDefinition, LogicDefinitionTypes.SHAPE);
	}
	public static function GetOptionWidgetDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<OptionWidgetDefinition>
	{
		return provider.GetDefinition(OptionWidgetDefinition, LogicDefinitionTypes.OPTION_WIDGET, id);
	}
	public static function GetAllOptionWidgetDefinitions(provider:IGameContent):Array<OptionWidgetDefinition>
	{
		return provider.GetDefinitions(OptionWidgetDefinition, LogicDefinitionTypes.OPTION_WIDGET);
	}
	public static function GetMapElementDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<MapElementDefinition>
	{
		return provider.GetDefinition(MapElementDefinition, LogicDefinitionTypes.MAP_ELEMENT, id);
	}
	public static function GetAllMapElementDefinitions(provider:IGameContent):Array<MapElementDefinition>
	{
		return provider.GetDefinitions(MapElementDefinition, LogicDefinitionTypes.MAP_ELEMENT);
	}
	public static function GetMapElementBehaviourDefinition(provider:IGameContent, id:Null<NamespaceID>):Null<MapElementBehaviourDefinition>
	{
		return provider.GetDefinition(MapElementBehaviourDefinition, LogicDefinitionTypes.MAP_ELEMENT_BEHAVIOUR, id);
	}
	public static function GetAllMapElementBehaviourDefinitions(provider:IGameContent):Array<MapElementBehaviourDefinition>
	{
		return provider.GetDefinitions(MapElementBehaviourDefinition, LogicDefinitionTypes.MAP_ELEMENT_BEHAVIOUR);
	}

	private function new() {}
}
