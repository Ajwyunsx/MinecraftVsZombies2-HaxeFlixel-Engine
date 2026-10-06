// Ported from: Assets/Scripts/View/Level/Blueprints/BlueprintArray.cs
package mvz2.ui.level;

import mvz2.ui.ElementArray;
import unity.UnityObject;
import unity.Vector3;

class BlueprintArray extends ClassicBlueprintSet
{
	override public function SetSlotCount(count:Int):Void
	{
		super.SetSlotCount(count);
		blueprints.SetCount(count);
	}
	override public function CreateBlueprint():Blueprint
	{
		return blueprints.CreateItem().GetComponent(Blueprint);
	}
	override public function InsertBlueprint(index:Int, blueprint:Null<Blueprint>):Void
	{
		if (!UnityObject.exists(blueprint))
			return;
		if (index < 0 || index >= blueprints.Count)
			return;
		blueprints.Insert(index, blueprint.gameObject);
		blueprint.OnPointerInteraction.add(OnBlueprintPointerInteractionCallback);
	}
	override public function RemoveBlueprint(blueprint:Blueprint):Bool
	{
		if (blueprint == null)
			return false;
		if (!blueprints.Remove(blueprint.gameObject))
			return false;
		blueprint.OnPointerInteraction.remove(OnBlueprintPointerInteractionCallback);
		return true;
	}
	override public function DestroyBlueprint(blueprint:Blueprint):Bool
	{
		if (blueprint == null)
			return false;
		if (!blueprints.DestroyItem(blueprint.gameObject))
			return false;
		blueprint.OnPointerInteraction.remove(OnBlueprintPointerInteractionCallback);
		return true;
	}
	override public function GetBlueprintAt(index:Int):Null<Blueprint>
	{
		return blueprints.getElementAs(index, Blueprint);
	}
	override public function GetBlueprintIndex(value:Blueprint):Int
	{
		return blueprints.indexOf(value.gameObject);
	}
	public function ForceAlign(index:Int):Void
	{
		var element = GetBlueprintAt(index);
		if (!UnityObject.exists(element))
			return;
		element.transform.localPosition = GetBlueprintLocalPosition(index);
	}
	public function GetBlueprintPosition(index:Int):Vector3
	{
		var local = GetBlueprintLocalPosition(index);
		return blueprints.ListRoot.TransformPoint(local);
	}
	public function AlignRemainBlueprints(removeIndex:Int):Void
	{
		for (i in removeIndex...blueprints.Count)
		{
			if (i >= blueprints.Count - 1)
				continue;
			var nextBlueprint = GetBlueprintAt(i + 1);
			RemoveBlueprintAt(i + 1);
			InsertBlueprint(i, nextBlueprint);
		}
	}
	override public function GetBlueprintCount():Int
	{
		return blueprints.Count;
	}
	@:serializeField
	private var blueprints:ElementArray;
}
