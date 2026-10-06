// Ported from: Assets/Scripts/View/Map/MapRaycastReceiver.cs
package mvz2.ui.map;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IBeginDragHandler;
import unity.eventsystems.IEventSystemHandler.IDragHandler;
import unity.eventsystems.IEventSystemHandler.IEndDragHandler;
import unity.eventsystems.IEventSystemHandler.IScrollHandler;
import flixel.util.FlxSignal;

class MapRaycastReceiver extends unity.MonoBehaviour implements IBeginDragHandler implements IDragHandler implements IEndDragHandler implements IScrollHandler
{
	public function OnBeginDrag(eventData:PointerEventData):Void
	{
		OnBeginDragSignal.dispatch(eventData);
	}

	public function OnDrag(eventData:PointerEventData):Void
	{
		OnDragSignal.dispatch(eventData);
	}

	public function OnEndDrag(eventData:PointerEventData):Void
	{
		OnEndDragSignal.dispatch(eventData);
	}

	public function OnScroll(eventData:PointerEventData):Void
	{
		OnScrollSignal.dispatch(eventData);
	}
	// PORT-NOTE: C# 的事件与接口方法名相同（OnBeginDrag/OnDrag/OnEndDrag/OnScroll），Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnBeginDragSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnDragSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnEndDragSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnScrollSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
}
