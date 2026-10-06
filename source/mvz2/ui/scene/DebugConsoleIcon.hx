// Ported from: Assets/Scripts/View/Scene/DebugConsoleIcon.cs
package mvz2.ui.scene;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.ui.Selectable;
import unity.eventsystems.IEventSystemHandler.IPointerClickHandler;
import flixel.util.FlxSignal;

class DebugConsoleIcon extends Selectable implements IPointerClickHandler
{
	public function OnPointerClick(eventData:PointerEventData):Void
	{
		if (!eventData.dragging)
		{
			OnClick.dispatch(this);
		}
	}
	public var OnClick:FlxTypedSignal<DebugConsoleIcon->Void> = new FlxTypedSignal();
}
