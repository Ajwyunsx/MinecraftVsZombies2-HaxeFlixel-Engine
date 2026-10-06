// Ported from: Assets/Scripts/View/Level/Blueprints/LevelUIBlueprints.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.SortingLayerPicker;
import mvz2.ui.Blueprint;
import mvz2logic.inputs.PointerInteraction;
import unity.Canvas;
import unity.GameObject;
import unity.Vector3;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

interface ILevelBlueprintRuntimeUI
{
	function SetBlueprintsActive(active:Bool):Void;
	function SetConveyorMode(mode:Bool):Void;
	function CreateClassicBlueprint():Blueprint;
	function InsertClassicBlueprint(index:Int, blueprint:Blueprint):Void;
	function SetClassicBlueprintSlotCount(count:Int):Void;
	function DestroyClassicBlueprintAt(index:Int):Void;
	function ForceAlignBlueprint(index:Int):Void;

	function ConveyBlueprint():Blueprint;
	function InsertConveyorBlueprint(index:Int, blueprint:Blueprint):Void;
	function SetConveyorBlueprintSlotCount(count:Int):Void;
	function DestroyConveyorBlueprintAt(index:Int):Void;
	function SetConveyorBlueprintNormalizedPosition(index:Int, position:Float):Void;
}

class LevelUIBlueprints extends unity.MonoBehaviour implements ILevelBlueprintRuntimeUI
{
	public function SetConveyorMode(value:Bool):Void
	{
		isConveyor = value;
		for (classic in blueprintClassicModeObjects)
		{
			classic.SetActive(!value);
		}
		for (conveyor in blueprintConveyorModeObjects)
		{
			conveyor.SetActive(value);
		}
	}
	public function IsConveyorMode():Bool
	{
		return isConveyor;
	}
	public function GetCurrentModeBlueprint(index:Int):Null<Blueprint>
	{
		return isConveyor ? GetConveyorBlueprintAt(index) : GetClassicBlueprintAt(index);
	}
	public function SetSortingToChoosing(choosing:Bool):Void
	{
		var layer = choosing ? choosingSortingLayer : battleSortingLayer;
		for (canvas in blueprintSortingCanvases)
		{
			canvas.sortingLayerID = layer.id;
		}
	}
	private function Awake():Void
	{
		blueprints.OnBlueprintPointerInteraction.add(OnBlueprintPointerInteractionCallback);
		conveyor.OnBlueprintPointerInteraction.add(OnConveyorPointerInteractionCallback);
	}
	private function OnBlueprintPointerInteractionCallback(index:Int, eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		OnBlueprintPointerInteraction.dispatch(index, eventData, interaction, false);
	}
	private function OnConveyorPointerInteractionCallback(index:Int, eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		OnBlueprintPointerInteraction.dispatch(index, eventData, interaction, true);
	}

	// #region 经典模式蓝图
	public function SetBlueprintsActive(visible:Bool):Void
	{
		blueprintClassicEnabledObj.SetActive(visible);
		blueprintConveyorEnabledObj.SetActive(visible);
	}
	public function SetClassicBlueprintSlotCount(count:Int):Void
	{
		blueprints.SetSlotCount(count);
	}
	public function CreateClassicBlueprint():Blueprint
	{
		return blueprints.CreateBlueprint();
	}
	public function InsertClassicBlueprint(index:Int, blueprint:Blueprint):Void
	{
		blueprints.InsertBlueprint(index, blueprint);
	}
	public function RemoveClassicBlueprint(blueprint:Blueprint):Bool
	{
		return blueprints.RemoveBlueprint(blueprint);
	}
	public function RemoveClassicBlueprintAt(index:Int):Void
	{
		blueprints.RemoveBlueprintAt(index);
	}
	public function DestroyClassicBlueprint(blueprint:Blueprint):Bool
	{
		return blueprints.DestroyBlueprint(blueprint);
	}
	public function DestroyClassicBlueprintAt(index:Int):Void
	{
		blueprints.DestroyBlueprintAt(index);
	}
	public function GetClassicBlueprintAt(index:Int):Null<Blueprint>
	{
		return blueprints.GetBlueprintAt(index);
	}
	public function GetClassicBlueprintIndex(blueprint:Blueprint):Int
	{
		return blueprints.GetBlueprintIndex(blueprint);
	}
	public function ForceAlignBlueprint(index:Int):Void
	{
		blueprints.ForceAlign(index);
	}
	// #endregion

	// #region 传送带模式蓝图
	public function GetClassicBlueprintPosition(index:Int):Vector3
	{
		return blueprints.GetBlueprintPosition(index);
	}
	public function ConveyBlueprint():Blueprint
	{
		return conveyor.CreateBlueprint();
	}
	public function InsertConveyorBlueprint(index:Int, blueprint:Blueprint):Void
	{
		conveyor.InsertBlueprint(index, blueprint);
	}
	public function DestroyConveyorBlueprint(blueprint:Blueprint):Bool
	{
		return conveyor.DestroyBlueprint(blueprint);
	}
	public function DestroyConveyorBlueprintAt(index:Int):Void
	{
		conveyor.DestroyBlueprintAt(index);
	}
	public function GetConveyorBlueprintAt(index:Int):Null<Blueprint>
	{
		return conveyor.GetBlueprintAt(index);
	}
	public function GetConveyorBlueprintIndex(blueprint:Blueprint):Int
	{
		return conveyor.GetBlueprintIndex(blueprint);
	}
	public function SetConveyorBlueprintSlotCount(count:Int):Void
	{
		conveyor.SetSlotCount(count);
	}
	public function SetConveyorBlueprintNormalizedPosition(index:Int, position:Float):Void
	{
		conveyor.SetBlueprintNormalizedPosition(index, position);
	}
	// #endregion

	public var OnBlueprintPointerInteraction:FlxTypedSignal<Int->PointerEventData->PointerInteraction->Bool->Void> = new FlxTypedSignal();

	private var isConveyor:Bool;
	@:serializeField
	private var blueprintClassicEnabledObj:GameObject;
	@:serializeField
	private var blueprintConveyorEnabledObj:GameObject;
	@:serializeField
	private var blueprintClassicModeObjects:Array<GameObject>;
	@:serializeField
	private var blueprintConveyorModeObjects:Array<GameObject>;

	// [Header("Sorting")]
	@:serializeField
	private var blueprintSortingCanvases:Array<Canvas>;
	@:serializeField
	private var battleSortingLayer:SortingLayerPicker;
	@:serializeField
	private var choosingSortingLayer:SortingLayerPicker;

	// [Header("Blueprints")]
	@:serializeField
	private var blueprints:BlueprintArray;
	@:serializeField
	private var conveyor:Conveyor;
}
