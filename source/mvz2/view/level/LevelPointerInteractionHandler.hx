// Ported from: Assets/Scripts/View/Level/LevelPointerInteractionHandler.cs
package mvz2.view.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2logic.inputs.InputHelper;
import mvz2logic.inputs.PointerInteraction;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IBeginDragHandler;
import unity.eventsystems.IEventSystemHandler.IDragHandler;
import unity.eventsystems.IEventSystemHandler.IDropHandler;
import unity.eventsystems.IEventSystemHandler.IEndDragHandler;
import unity.eventsystems.IEventSystemHandler.IPointerClickHandler;
import unity.eventsystems.IEventSystemHandler.IPointerDownHandler;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import unity.eventsystems.IEventSystemHandler.IPointerUpHandler;
import flixel.util.FlxSignal;

class LevelPointerInteractionHandler extends unity.MonoBehaviour implements IPointerEnterHandler implements IPointerExitHandler implements IPointerDownHandler implements IPointerUpHandler implements IPointerReleaseHandler implements IBeginDragHandler implements IEndDragHandler implements IDragHandler implements IPointerClickHandler implements IDropHandler
{
	public function ResetData():Void
	{
		// PORT-NOTE: C# List<T>.Clear() → Haxe Array 没有 clear()，用 resize(0)。
		hoveredPointerDatas.resize(0);
		pressedPointerDatas.resize(0);
	}
	public function UpdateHoldAndStreak():Void
	{
		hoveredPointerDataBuffer.resize(0);
		for (data in hoveredPointerDatas) hoveredPointerDataBuffer.push(data);
		for (eventData in hoveredPointerDataBuffer)
		{
			OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Stay);
			if (Lambda.exists(pressedPointerDatas, e -> e.pointerId == eventData.pointerId))
			{
				OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Hold);
			}
			if (InputHelper.IsPointerHolding(eventData.pointerId))
			{
				OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Streak);
			}
		}
	}
	public function IsHovered():Bool
	{
		return hoveredPointerDatas.length > 0;
	}
	public function IsPressed():Bool
	{
		return hoveredPointerDatas.length > 0;
	}
	public function GetHoveredPointerCount():Int
	{
		return hoveredPointerDatas.length;
	}
	public function GetHoveredPointerEventData(index:Int):PointerEventData
	{
		return hoveredPointerDatas[index];
	}

	// #region 接口实现
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		hoveredPointerDatas.push(eventData);
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Enter);
	}
	public function OnPointerExit(eventData:PointerEventData):Void
	{
		hoveredPointerDatas = Lambda.array(Lambda.filter(hoveredPointerDatas, e -> e.pointerId != eventData.pointerId));
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Exit);
	}
	public function OnPointerDown(eventData:PointerEventData):Void
	{
		pressedPointerDatas.push(eventData);
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Down);
	}
	public function OnPointerUp(eventData:PointerEventData):Void
	{
		pressedPointerDatas = Lambda.array(Lambda.filter(pressedPointerDatas, e -> e.pointerId != eventData.pointerId));
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Up);
	}
	public function OnPointerRelease(eventData:PointerEventData):Void
	{
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Release);
	}
	public function OnBeginDrag(eventData:PointerEventData):Void
	{
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.BeginDrag);
	}
	public function OnDrag(eventData:PointerEventData):Void
	{
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Drag);
	}
	public function OnEndDrag(eventData:PointerEventData):Void
	{
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.EndDrag);
	}
	public function OnDrop(eventData:PointerEventData):Void
	{
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Drop);
	}
	public function OnPointerClick(eventData:PointerEventData):Void
	{
		OnPointerInteraction.dispatch(this, eventData, PointerInteraction.Click);
	}
	// #endregion

	// #region 事件
	public var OnPointerInteraction:FlxTypedSignal<LevelPointerInteractionHandler->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	// #endregion

	// #region 属性字段
	private var hoveredPointerDataBuffer:Array<PointerEventData> = [];
	private var hoveredPointerDatas:Array<PointerEventData> = [];
	private var pressedPointerDatas:Array<PointerEventData> = [];
	// #endregion
}

// C# 中为 MVZ2.View.Level 的 IPointerReleaseHandler 接口。
interface IPointerReleaseHandler extends IEventSystemHandler
{
	function OnPointerRelease(eventData:PointerEventData):Void;
}
