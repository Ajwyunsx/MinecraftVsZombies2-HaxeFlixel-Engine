// Ported from: Assets/Scripts/View/Level/BlueprintChoose/MovingBlueprintList.cs
package mvz2.ui.level;

import unity.Transform;
import unity.UnityObject;
import unity.MonoBehaviour;

class MovingBlueprintList extends unity.MonoBehaviour
{
	function Awake():Void
	{
		movingBlueprintTemplate.gameObject.SetActive(false);
	}
	public function CreateMovingBlueprint():MovingBlueprint
	{
		var item = UnityObject.Instantiate(movingBlueprintTemplate.gameObject, null, null, movingBlueprintRoot);
		item.SetActive(true);
		return item.GetComponent(MovingBlueprint);
	}
	public function RemoveMovingBlueprint(blueprint:MovingBlueprint):Void
	{
		if (blueprint == null)
			return;
		UnityObject.destroy(blueprint.gameObject);
	}
	@:serializeField
	private var movingBlueprintTemplate:MovingBlueprint;
	@:serializeField
	private var movingBlueprintRoot:Transform;
}
