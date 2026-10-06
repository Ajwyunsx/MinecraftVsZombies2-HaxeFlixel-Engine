// Ported from: Assets/Scripts/View/Blueprint/BlueprintDisplayerStandalone.cs
package mvz2.ui;

import mvz2logic.inputs.PointerInteraction;
import unity.GameObject;
import unity.Mathf;
import unity.RectTransform;
import unity.UnityObject;
import unity.eventsystems.PointerEventData;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import mvz2.ui.BlueprintDisplayer;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;

class BlueprintDisplayerStandalone extends BlueprintDisplayer
{
	public function SetCurrentPage(index:Int):Void
	{
		currentPage = index;
		pageText.text = '${index + 1}/${maxPages}';
		for (i in 0...pageList.count)
		{
			var element = pageList.getElement(i);
			if (UnityObject.exists(element))
			{
				element.gameObject.SetActive(i == index);
			}
		}
		SetPageButtonInteractable(false, index > 0);
		SetPageButtonInteractable(true, index < maxPages - 1);
	}
	public function SetPageButtonInteractable(isNextPage:Bool, interactable:Bool):Void
	{
		var button = isNextPage ? nextPageButton : previousPageButton;
		button.interactable = interactable;
	}
	public override function UpdateItems(viewDatas:Array<ChoosingBlueprintViewData>):Void
	{
		var pageCount = Mathf.CeilToInt(viewDatas.length / maxCountPerPage);
		pageList.updateList(pageCount,
			function(i:Int, rect:RectTransform)
			{
				var page = rect.GetComponent(BlueprintDisplayerStandalonePage);
				page.UpdateItems(viewDatas.slice(i * maxCountPerPage, i * maxCountPerPage + maxCountPerPage));
			},
			function(rect:RectTransform)
			{
				var page = rect.GetComponent(BlueprintDisplayerStandalonePage);
				page.OnBlueprintPointerInteraction.add(OnBlueprintPointerInteractionCallback);
				page.OnBlueprintSelect.add(OnBlueprintSelectCallback);
			},
			function(rect:RectTransform)
			{
				var page = rect.GetComponent(BlueprintDisplayerStandalonePage);
				page.OnBlueprintPointerInteraction.remove(OnBlueprintPointerInteractionCallback);
				page.OnBlueprintSelect.remove(OnBlueprintSelectCallback);
			});
		maxPages = pageCount;
		SetCurrentPage(0);
		pageRoot.SetActive(pageCount > 1);
	}
	public override function GetItem(index:Int):Null<Blueprint>
	{
		var pageNum = Mathf.FloorToInt(index / maxCountPerPage);
		var page = pageList.getElementAs(pageNum, BlueprintDisplayerStandalonePage);
		if (page == null)
			return null;
		return page.GetItem(index % maxCountPerPage);
	}
	private function Awake():Void
	{
		previousPageButton.onClick.AddListener(() -> SetCurrentPage(currentPage - 1));
		nextPageButton.onClick.AddListener(() -> SetCurrentPage(currentPage + 1));
	}
	private function OnBlueprintPointerInteractionCallback(page:BlueprintDisplayerStandalonePage, indexInPage:Int, eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		var index = pageList.indexOfComponent(page) * maxCountPerPage + indexInPage;
		CallBlueprintPointerInteraction(index, eventData, interaction);
	}
	private function OnBlueprintSelectCallback(page:BlueprintDisplayerStandalonePage, indexInPage:Int, eventData:PointerEventData):Void
	{
		var index = pageList.indexOfComponent(page) * maxCountPerPage + indexInPage;
		CallBlueprintSelect(index, eventData);
	}
	// [Header("Standalone")]
	@:serializeField
	private var pageRoot:GameObject;
	@:serializeField
	private var pageText:TextMeshProUGUI;
	@:serializeField
	private var pageList:ElementListUI;
	@:serializeField
	private var previousPageButton:Button;
	@:serializeField
	private var nextPageButton:Button;
	@:serializeField
	private var maxCountPerPage:Int = 40;
	private var currentPage:Int;
	private var maxPages:Int;
}
