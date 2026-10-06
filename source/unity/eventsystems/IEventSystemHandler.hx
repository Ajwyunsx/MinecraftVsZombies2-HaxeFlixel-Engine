package unity.eventsystems;

// Minimal UnityEngine.EventSystems 事件接口集合。
interface IEventSystemHandler {}

interface IPointerEnterHandler extends IEventSystemHandler {
    function OnPointerEnter(eventData:PointerEventData):Void;
}
interface IPointerExitHandler extends IEventSystemHandler {
    function OnPointerExit(eventData:PointerEventData):Void;
}
interface IPointerDownHandler extends IEventSystemHandler {
    function OnPointerDown(eventData:PointerEventData):Void;
}
interface IPointerUpHandler extends IEventSystemHandler {
    function OnPointerUp(eventData:PointerEventData):Void;
}
interface IPointerClickHandler extends IEventSystemHandler {
    function OnPointerClick(eventData:PointerEventData):Void;
}
interface IPointerMoveHandler extends IEventSystemHandler {
    function OnPointerMove(eventData:PointerEventData):Void;
}
interface IBeginDragHandler extends IEventSystemHandler {
    function OnBeginDrag(eventData:PointerEventData):Void;
}
interface IDragHandler extends IEventSystemHandler {
    function OnDrag(eventData:PointerEventData):Void;
}
interface IEndDragHandler extends IEventSystemHandler {
    function OnEndDrag(eventData:PointerEventData):Void;
}
interface IDropHandler extends IEventSystemHandler {
    function OnDrop(eventData:PointerEventData):Void;
}
interface IScrollHandler extends IEventSystemHandler {
    function OnScroll(eventData:PointerEventData):Void;
}
interface IUpdateSelectedHandler extends IEventSystemHandler {
    function OnUpdateSelected(eventData:BaseEventData):Void;
}
interface ISelectHandler extends IEventSystemHandler {
    function OnSelect(eventData:BaseEventData):Void;
}
interface IDeselectHandler extends IEventSystemHandler {
    function OnDeselect(eventData:BaseEventData):Void;
}
interface IMoveHandler extends IEventSystemHandler {
    function OnMove(eventData:AxisEventData):Void;
}
interface ISubmitHandler extends IEventSystemHandler {
    function OnSubmit(eventData:BaseEventData):Void;
}
interface ICancelHandler extends IEventSystemHandler {
    function OnCancel(eventData:BaseEventData):Void;
}
interface IInitializePotentialDragHandler extends IEventSystemHandler {
    function OnInitializePotentialDrag(eventData:PointerEventData):Void;
}
