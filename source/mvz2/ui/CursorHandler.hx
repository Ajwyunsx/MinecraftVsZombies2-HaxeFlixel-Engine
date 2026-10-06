// Ported from: Assets/Scripts/View/Widgets/CursorHandler.cs
package mvz2.ui;

import mvz2logic.Global;
import mvz2logic.cursor.CursorSource;
import mvz2logic.cursor.CursorType;
import unity.GameObject;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.ui.Selectable;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import flixel.addons.editors.ogmo.FlxOgmo3Loader.Point;

class CursorHandler extends unity.MonoBehaviour implements IPointerEnterHandler implements IPointerExitHandler
{
	function OnDisable():Void
	{
		if (isHovered)
		{
			isHovered = false;
			UpdateCursor();
		}
	}
	function LateUpdate():Void
	{
		UpdateCursor();
	}
	function UpdateCursor():Void
	{
		if (isHovered && Interactable)
		{
			Enter();
		}
		else
		{
			Exit();
		}
	}
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		if (Interactable)
		{
			isHovered = true;
			UpdateCursor();
		}
	}

	public function OnPointerExit(eventData:PointerEventData):Void
	{
		if (isHovered)
		{
			isHovered = false;
			UpdateCursor();
		}
	}
	private function Enter():Void
	{
		if (_cursorSource == null)
		{
			_cursorSource = new HandlerCursorSource(gameObject, cursorType);
			Global.Cursors.AddCursorSource(_cursorSource);
		}
	}
	private function Exit():Void
	{
		if (_cursorSource != null)
		{
			Global.Cursors.RemoveCursorSource(_cursorSource);
			_cursorSource = null;
		}
	}
	public var Interactable(get, set):Bool;
	function get_Interactable():Bool
	{
		// PORT-NOTE: C# 的 `!trackSelectable` 依赖 UnityEngine.Object 的隐式 bool 转换；Haxe 中写成 null 判断。
		return (trackSelectable == null || (trackSelectable.interactable && trackSelectable.isActiveAndEnabled)) && interactable;
	}
	function set_Interactable(value:Bool):Bool
	{
		interactable = value;
		UpdateCursor();
		return value;
	}
	public var cursorType:CursorType = CursorType.Point;
	@:serializeField
	private var trackSelectable:Selectable;
	private var isHovered:Bool;
	private var interactable:Bool = true;
	private var _cursorSource:Null<HandlerCursorSource>;
}

class HandlerCursorSource extends CursorSource
{
	public function new(target:GameObject, type:CursorType, ?priority:Int = 0)
	{
		// PORT-NOTE: mvz2logic.cursor.CursorSource 没有显式构造函数，Haxe 中无需（也不能）调用 super()。
		this.target = target;
		this.type = type;
		this.priority = priority;
	}

	override public function IsValid():Bool
	{
		return target != null && target.activeInHierarchy;
	}

	public var target:GameObject;
	private var priority:Int;
	override public function get_Priority():Int return priority;
	private var type:CursorType;
	override public function get_CursorType():CursorType return type;
}
