// Ported from: Assets/Scripts/View/MusicRoom/MusicBar.cs
package mvz2.ui.musicroom;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IPointerUpHandler;
import flixel.util.FlxSignal;

class MusicBar extends unity.MonoBehaviour implements IPointerUpHandler
{
	public function OnPointerUp(eventData:PointerEventData):Void
	{
		OnPointerUpSignal.dispatch();
	}
	// PORT-NOTE: C# 的事件与接口方法同名，Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnPointerUpSignal:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
}
