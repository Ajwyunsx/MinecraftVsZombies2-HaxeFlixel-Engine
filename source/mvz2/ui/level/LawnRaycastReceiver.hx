// Ported from: Assets/Scripts/View/Level/LawnRaycastReceiver.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2logic.helditems.HeldItemDefinition;
import mvz2logic.helditems.HeldItemTargetLawn;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.inputs.InputHelper;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.level.LawnArea;
import pvzengine.level.LevelEngine;
import unity.Canvas;
import unity.eventsystems.PointerEventData;
import mvz2.view.level.LevelPointerInteractionHandler;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class LawnRaycastReceiver extends unity.MonoBehaviour implements ILevelRaycastReceiver
{
	public function GetArea():LawnArea
	{
		return area;
	}
	function Awake():Void
	{
		holdStreakHandler.OnPointerInteraction.add((_, d, i) -> OnPointerInteraction.dispatch(this, d, i));
	}
	public function IsValidReceiver(level:LevelEngine, definition:HeldItemDefinition, data:IHeldItemData, eventData:PointerEventData):Bool
	{
		if (definition == null)
			return false;
		var target = new HeldItemTargetLawn(level, area);
		var pointer = InputHelper.GetPointerDataFromEventData(eventData);
		return definition.IsValidFor(target, data, pointer);
	}
	public function GetSortingLayer():Int
	{
		return canvas.sortingLayerID;
	}
	public function GetSortingOrder():Int
	{
		return canvas.sortingOrder;
	}
	public var OnPointerInteraction:FlxTypedSignal<LawnRaycastReceiver->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	@:serializeField
	private var canvas:Canvas;
	@:serializeField
	private var area:LawnArea;
	@:serializeField
	private var holdStreakHandler:LevelPointerInteractionHandler;
}
