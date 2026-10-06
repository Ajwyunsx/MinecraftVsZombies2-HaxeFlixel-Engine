// Ported from: Assets/Scripts/View/Models/ModelBone.cs
package mvz2.models;

import mvz2.models.LightController;  // IMPORTFIX
import unity.Color;
import unity.Vector2;
using mvz2.vanilla.entities.VanillaEntityProps;  // EXTUSING

// @:DisallowMultipleComponent
class ModelBone extends unity.MonoBehaviour
{
	public function SetLightVisible(visible:Bool):Void
	{
		if (lightController != null)
		{
			lightController.gameObject.SetActive(visible);
		}
	}
	public function SetLightColor(color:Color):Void
	{
		if (lightController != null)
		{
			lightController.SetColor(color);
		}
	}
	public function SetLightRange(range:Vector2):Void
	{
		if (lightController != null)
		{
			lightController.SetRange(range);
		}
	}
	// [Header("Light")]
	@:serializeField
	private var lightController:LightController;
}
