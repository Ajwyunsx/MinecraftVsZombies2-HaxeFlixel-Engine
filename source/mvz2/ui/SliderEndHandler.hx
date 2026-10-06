// Ported from: Assets/Scripts/View/Widgets/SliderEndHandler.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IPointerUpHandler;
import flixel.util.FlxSignal;

class SliderEndHandler extends unity.MonoBehaviour implements IPointerUpHandler
{
	public function OnPointerUp(eventData:PointerEventData):Void
	{
		OnEnd.dispatch(eventData);
	}
	public var OnEnd:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
}
