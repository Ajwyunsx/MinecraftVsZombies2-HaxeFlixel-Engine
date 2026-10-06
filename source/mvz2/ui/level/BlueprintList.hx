// Ported from: Assets/Scripts/View/Level/Blueprints/BlueprintList.cs
package mvz2.ui.level;

import mvz2.ui.ElementList;
import unity.Vector3;

class BlueprintList extends ClassicBlueprintSet
{
	override public function CreateBlueprint():Blueprint
	{
		return blueprints.CreateItem().GetComponent(Blueprint);
	}
	override public function InsertBlueprint(index:Int, blueprint:Blueprint):Void
	{
		if (blueprint == null)
			return;
		blueprints.Insert(index, blueprint.gameObject);
		blueprint.OnPointerInteraction.add(OnBlueprintPointerInteractionCallback);
	}
	override public function RemoveBlueprint(blueprint:Blueprint):Bool
	{
		if (blueprint == null)
			return false;
		if (blueprints.Remove(blueprint.gameObject))
		{
			blueprint.OnPointerInteraction.remove(OnBlueprintPointerInteractionCallback);
			return true;
		}
		return false;
	}
	override public function DestroyBlueprint(blueprint:Blueprint):Bool
	{
		if (blueprint == null)
			return false;
		if (blueprints.DestroyItem(blueprint.gameObject))
		{
			blueprint.OnPointerInteraction.remove(OnBlueprintPointerInteractionCallback);
			return true;
		}
		return false;
	}
	override public function GetBlueprintAt(index:Int):Null<Blueprint>
	{
		return blueprints.getElementAs(index, Blueprint);
	}
	override public function GetBlueprintIndex(value:Blueprint):Int
	{
		return blueprints.indexOf(value.gameObject);
	}
	public function GetBlueprintPosition(index:Int):Vector3
	{
		var local = GetBlueprintLocalPosition(index);
		return blueprints.ListRoot.TransformPoint(new Vector3(local.x, local.y, 0));
	}
	override public function GetBlueprintCount():Int
	{
		return blueprints.Count;
	}
	@:serializeField
	private var blueprints:ElementList;
}
