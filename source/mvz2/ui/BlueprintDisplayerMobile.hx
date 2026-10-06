// Ported from: Assets/Scripts/View/Blueprint/BlueprintDisplayerMobile.cs
package mvz2.ui;

import mvz2logic.inputs.PointerInteraction;
import unity.GameObject;
import unity.RectTransform;
import unity.eventsystems.PointerEventData;
import unity.ui.ScrollRect;
import mvz2.ui.BlueprintDisplayer;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;

class BlueprintDisplayerMobile extends BlueprintDisplayer
{
	public override function UpdateItems(viewDatas:Array<ChoosingBlueprintViewData>):Void
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
				var page = rect.GetComponent(Blueprint);
				page.OnPointerInteraction.add(OnPointerInteractionCallback);
				page.OnSelect.add(OnSelectCallback);
			},
			function(rect:RectTransform)
			{
				var page = rect.GetComponent(Blueprint);
				page.OnPointerInteraction.remove(OnPointerInteractionCallback);
				page.OnSelect.remove(OnSelectCallback);
			});
	}
	public override function GetItem(index:Int):Null<Blueprint>
	{
		return blueprintList.getElementAs(index, Blueprint);
	}
	private function OnPointerInteractionCallback(blueprint:Blueprint, eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		switch (interaction)
		{
			case PointerInteraction.BeginDrag:
				scrollRect.OnBeginDrag(eventData);
				return;
			case PointerInteraction.Drag:
				scrollRect.OnDrag(eventData);
				return;
			case PointerInteraction.EndDrag:
				scrollRect.OnEndDrag(eventData);
				return;
			default:
		}
		var index = blueprintList.indexOfComponent(blueprint);
		CallBlueprintPointerInteraction(index, eventData, interaction);
	}
	private function OnSelectCallback(blueprint:Blueprint, eventData:PointerEventData):Void
	{
		var index = blueprintList.indexOfComponent(blueprint);
		CallBlueprintSelect(index, eventData);
	}
	// [Header("Mobile")]
	@:serializeField
	private var scrollRect:ScrollRect;
	@:serializeField
	private var blueprintList:ElementListUI;
}
