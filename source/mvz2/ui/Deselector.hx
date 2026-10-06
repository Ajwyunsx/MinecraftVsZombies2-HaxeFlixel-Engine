// Ported from: Assets/Scripts/View/Widgets/Deselector.cs
package mvz2.ui;

import unity.eventsystems.EventSystem;
import unity.MonoBehaviour;

class Deselector extends unity.MonoBehaviour
{
	public function Deselect():Void
	{
		EventSystem.current.SetSelectedGameObject(null);
	}
}
