// Ported from: Assets/Scripts/View/Map/MapElementButton.cs
package mvz2.ui.map;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.ui.Selectable;
import unity.eventsystems.IEventSystemHandler.IPointerClickHandler;
import flixel.util.FlxSignal;

class MapElementButton extends Selectable implements IPointerClickHandler
{
	public function OnPointerClick(eventData:PointerEventData):Void
	{
		if (!IsInteractable())
			return;
		// Not left mouse nor first touch.
		if (eventData.pointerId != -1 && eventData.pointerId != 0)
			return;
		OnClick.dispatch(this);
	}
	public var OnClick:FlxTypedSignal<MapElementButton->Void> = new FlxTypedSignal();
}
