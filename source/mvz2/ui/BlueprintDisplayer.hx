// Ported from: Assets/Scripts/View/Blueprint/BlueprintDisplayer.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2logic.inputs.PointerInteraction;
import unity.eventsystems.PointerEventData;
import mvz2.ui.Blueprint;
import unity.MonoBehaviour;
import mvz2.ui.Blueprint.BlueprintViewData;
import flixel.util.FlxSignal;

// abstract
class BlueprintDisplayer extends unity.MonoBehaviour
{
	// abstract
	public function UpdateItems(viewDatas:Array<ChoosingBlueprintViewData>):Void throw "abstract";
	// abstract
	public function GetItem(index:Int):Null<Blueprint> throw "abstract";
	private function CallBlueprintPointerInteraction(index:Int, eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		OnBlueprintPointerInteraction.dispatch(index, eventData, interaction);
	}
	private function CallBlueprintSelect(index:Int, eventData:PointerEventData):Void
	{
		OnBlueprintSelect.dispatch(index, eventData);
	}
	public var OnBlueprintPointerInteraction:FlxTypedSignal<Int->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	public var OnBlueprintSelect:FlxTypedSignal<Int->PointerEventData->Void> = new FlxTypedSignal();
}

// C# 中为 MVZ2.UI 的 ChoosingBlueprintViewData 结构体。
class ChoosingBlueprintViewData
{
	public var blueprint:BlueprintViewData;
	public var disabled:Bool;
	public var selected:Bool;
	public var recharge:Float;

	public function new() {}

	public static var Empty(get, never):ChoosingBlueprintViewData;
	static function get_Empty():ChoosingBlueprintViewData
	{
		var data = new ChoosingBlueprintViewData();
		data.blueprint = BlueprintViewData.Empty;
		return data;
	}
}
