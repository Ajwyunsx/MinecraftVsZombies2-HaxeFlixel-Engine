// Ported from: Assets/Scripts/View/Level/StarshardPanelIcon.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Sprite;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.ui.Image;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IPointerDownHandler;
import flixel.util.FlxSignal;

class StarshardPanelIcon extends unity.MonoBehaviour implements IPointerDownHandler
{
	public function SetSprite(sprite:Null<Sprite>):Void
	{
		image.sprite = sprite;
	}
	public function OnPointerDown(eventData:PointerEventData):Void
	{
		OnPointerDownSignal.dispatch(eventData);
	}
	// PORT-NOTE: C# 的事件与接口方法同名，Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnPointerDownSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	@:serializeField
	private var image:Image;
}
