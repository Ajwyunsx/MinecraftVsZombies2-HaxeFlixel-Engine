// Ported from: Assets/Scripts/View/Level/Blueprints/BlueprintSet.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2logic.inputs.PointerInteraction;
import unity.UnityObject;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

// abstract
class BlueprintSet extends unity.MonoBehaviour
{
	// abstract
	public function CreateBlueprint():Blueprint throw "abstract";
	// abstract
	public function InsertBlueprint(index:Int, blueprint:Blueprint):Void throw "abstract";
	// abstract
	public function RemoveBlueprint(blueprint:Blueprint):Bool throw "abstract";
	// abstract
	public function DestroyBlueprint(blueprint:Blueprint):Bool throw "abstract";
	public function RemoveBlueprintAt(index:Int):Void
	{
		var blueprint = GetBlueprintAt(index);
		if (!UnityObject.exists(blueprint))
			return;
		RemoveBlueprint(blueprint);
	}
	public function DestroyBlueprintAt(index:Int):Void
	{
		var blueprint = GetBlueprintAt(index);
		if (!UnityObject.exists(blueprint))
			return;
		DestroyBlueprint(blueprint);
	}
	// abstract
	public function GetBlueprintAt(index:Int):Null<Blueprint> throw "abstract";
	// abstract
	public function GetBlueprintIndex(value:Blueprint):Int throw "abstract";
	function OnBlueprintPointerInteractionCallback(blueprint:Blueprint, data:PointerEventData, interaction:PointerInteraction):Void
	{
		OnBlueprintPointerInteraction.dispatch(GetBlueprintIndex(blueprint), data, interaction);
	}
	public var OnBlueprintPointerInteraction:FlxTypedSignal<Int->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	@:serializeField
	private var horizontal:Bool;
}
