// Ported from: Assets/Scripts/View/Blueprint/BlueprintDisplayerStandalonePage.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2logic.inputs.PointerInteraction;
import unity.RectTransform;
import unity.eventsystems.PointerEventData;
import mvz2.ui.BlueprintDisplayer;
import unity.MonoBehaviour;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;
import flixel.util.FlxSignal;

class BlueprintDisplayerStandalonePage extends unity.MonoBehaviour
{
	public function UpdateItems(viewDatas:Array<ChoosingBlueprintViewData>):Void
	{
		blueprintList.updateList(viewDatas.length,
			function(i:Int, rect:RectTransform)
			{
				var blueprint = rect.GetComponent(Blueprint);
				blueprint.UpdateView(viewDatas[i].blueprint);
				blueprint.SetDisabled(viewDatas[i].disabled);
				blueprint.SetSelected(viewDatas[i].selected);
				blueprint.SetRecharge(viewDatas[i].recharge);
			},
			function(rect:RectTransform)
			{
				var blueprint = rect.GetComponent(Blueprint);
				blueprint.OnPointerInteraction.add(OnBlueprintPointerInteractionCallback);
				blueprint.OnSelect.add(OnBlueprintSelectCallback);
			},
			function(rect:RectTransform)
			{
				var blueprint = rect.GetComponent(Blueprint);
				blueprint.OnPointerInteraction.remove(OnBlueprintPointerInteractionCallback);
				blueprint.OnSelect.remove(OnBlueprintSelectCallback);
			});
	}
	public function GetItem(index:Int):Null<Blueprint>
	{
		return blueprintList.getElementAs(index, Blueprint);
	}
	private function OnBlueprintPointerInteractionCallback(blueprint:Blueprint, eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		OnBlueprintPointerInteraction.dispatch(this, blueprintList.indexOfComponent(blueprint), eventData, interaction);
	}
	private function OnBlueprintSelectCallback(blueprint:Blueprint, eventData:PointerEventData):Void
	{
		OnBlueprintSelect.dispatch(this, blueprintList.indexOfComponent(blueprint), eventData);
	}
	// PORT-NOTE: C# 事件与同名回调方法不冲突；此处事件名保持 C# 一致。
	public var OnBlueprintPointerInteraction:FlxTypedSignal<BlueprintDisplayerStandalonePage->Int->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	public var OnBlueprintSelect:FlxTypedSignal<BlueprintDisplayerStandalonePage->Int->PointerEventData->Void> = new FlxTypedSignal();
	@:serializeField
	private var blueprintList:ElementListUI;
}
