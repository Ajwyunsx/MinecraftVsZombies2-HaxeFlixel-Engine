// Ported from: Assets/Scripts/View/Widgets/Tooltip/TooltipHandler.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import mukioi18n.ITranslateComponent;
import unity.MonoBehaviour;
import system.io.Path;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import flixel.addons.ui.Anchor;
import flixel.util.FlxSignal;

class TooltipHandler extends unity.MonoBehaviour implements IPointerEnterHandler implements IPointerExitHandler implements ITooltipTarget implements mukioi18n.ITranslateComponent
{
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		OnPointerEnterSignal.dispatch(this);
	}
	public function OnPointerExit(eventData:PointerEventData):Void
	{
		OnPointerExitSignal.dispatch(this);
	}
	public var OnPointerEnterSignal:FlxTypedSignal<TooltipHandler->Void> = new FlxTypedSignal();
	// PORT-NOTE: C# 的 event OnPointerEnter 与接口方法 IPointerEnterHandler.OnPointerEnter 同名，
	// Haxe 中字段与方法不能同名，事件字段改名为 OnPointerEnterSignal / OnPointerExitSignal。
	public var OnPointerExitSignal:FlxTypedSignal<TooltipHandler->Void> = new FlxTypedSignal();

	public var Anchor(get, never):Null<ITooltipAnchor>;
	function get_Anchor():Null<ITooltipAnchor> return anchor;

	public var Key(get, never):Null<String>;
	function get_Key():Null<String> return text;
	public var Context(get, never):Null<String>;
	function get_Context():Null<String> return context;
	public var Keys(get, never):Null<Array<String>>;
	function get_Keys():Null<Array<String>> return null;
	public var Comment(get, never):Null<String>;
	function get_Comment():Null<String> return comment;
	public var Path(get, never):String;
	function get_Path():String
	{
		var sb = new StringBuf();

		var tr = transform;
		while (tr != null)
		{
			sb.add(tr.name);
			sb.add("/");
			tr = tr.parent;
		}
		// PORT-NOTE: C# 用 StringBuilder.Insert(0, ...) 从子到父拼接，这里改为正向拼接后再反转。
		var parts = sb.toString().split("/");
		parts.reverse();
		return parts.join("/");
	}
	public var anchor:Null<TooltipAnchor>;
	public var context:Null<String>;
	public var comment:Null<String>;
	// [TextArea]
	public var text:Null<String>;
}
