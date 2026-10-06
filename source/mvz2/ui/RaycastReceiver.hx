// Ported from: Assets/Scripts/View/RaycastReceiver.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IPointerDownHandler;
import flixel.util.FlxSignal;

class RaycastReceiver extends unity.MonoBehaviour implements IPointerDownHandler
{
	public function OnPointerDown(eventData:PointerEventData):Void
	{
		OnPointerDownSignal.dispatch(eventData);
	}
	// PORT-NOTE: C# 的 event OnPointerDown 与接口方法同名，Haxe 中字段与方法不能同名，故改名。
	public var OnPointerDownSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
}
