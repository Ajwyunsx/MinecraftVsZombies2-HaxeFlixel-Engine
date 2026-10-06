// Ported from: Assets/Scripts/View/Widgets/DragMover.cs
package mvz2.ui;

import unity.Canvas;
import unity.RectTransform;
import unity.UnityObject;
import unity.Vector3;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IBeginDragHandler;
import unity.eventsystems.IEventSystemHandler.IDragHandler;
import unity.eventsystems.IEventSystemHandler.IEndDragHandler;

class DragMover extends unity.MonoBehaviour implements IBeginDragHandler implements IDragHandler implements IEndDragHandler
{
	public function OnBeginDrag(eventData:PointerEventData):Void
	{
		if (!eventData.pointerCurrentRaycast.isValid)
			return;
		var rootCanvas = UIHelper.GetRootCanvasNonAlloc(dragTarget, canvasListCache);
		if (rootCanvas == null)
			return;
		dragging = true;
		var worldPos = rootCanvas.worldCamera.ScreenToWorldPoint(new Vector3(eventData.position.x, eventData.position.y, 0));
		dragTargetOffset = worldPos - dragTarget.position;
	}
	public function OnDrag(eventData:PointerEventData):Void
	{
		if (!dragging)
			return;
		var rootCanvas = UIHelper.GetRootCanvasNonAlloc(dragTarget, canvasListCache);
		if (!UnityObject.exists(rootCanvas))
			return;

		var worldPos = rootCanvas.worldCamera.ScreenToWorldPoint(new Vector3(eventData.position.x, eventData.position.y, 0));
		dragTarget.position = worldPos - dragTargetOffset;

		var rectTrans:RectTransform = cast rootCanvas.transform;
		if (rectTrans != null)
		{
			UIHelper.LimitInsideScreenWithRoot(dragTarget, rectTrans);
		}
	}
	public function OnEndDrag(eventData:PointerEventData):Void
	{
		dragging = false;
	}
	public var Dragging(get, never):Bool;
	function get_Dragging():Bool return dragging;
	@:serializeField
	private var dragTarget:RectTransform;
	private var dragging:Bool;
	private var dragTargetOffset:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var canvasListCache:Array<Canvas> = [];
}
