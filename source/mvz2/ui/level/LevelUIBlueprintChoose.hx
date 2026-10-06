// Ported from: Assets/Scripts/View/Level/BlueprintChoose/LevelUIBlueprintChoose.cs
package mvz2.ui.level;

import mvz2.ui.level.ArtifactSlot;

import mvz2.ui.level.ArtifactSelectItem;

import mvz2.ui.BlueprintDisplayer;

import mvz2.ui.level.BlueprintChoosePanel;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.Blueprint;
import mvz2.ui.ElementListUI;
import mvz2logic.inputs.PointerInteraction;
import unity.Animator;
import unity.GameObject;
import unity.RectTransform;
import unity.UnityObject;
import unity.Vector3;
import unity.eventsystems.PointerEventData;
import unity.ui.Button;
import unity.MonoBehaviour;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;
import mvz2.ui.level.ArtifactSelectItem.ArtifactSelectItemViewData;
import mvz2.ui.level.ArtifactSlot.ArtifactViewData;
import mvz2.ui.level.BlueprintChoosePanel.BlueprintChoosePanelViewData;
import flixel.util.FlxSignal;

class LevelUIBlueprintChoose extends unity.MonoBehaviour
{
	// #region 移动蓝图
	public function CreateMovingBlueprint():MovingBlueprint
	{
		return movingBlueprints.CreateMovingBlueprint();
	}
	public function RemoveMovingBlueprint(blueprint:MovingBlueprint):Void
	{
		movingBlueprints.RemoveMovingBlueprint(blueprint);
	}
	// #endregion

	// #region 选择蓝图
	public function SetChosenBlueprintsVisible(visible:Bool):Void
	{
		choosingBlueprintRoot.SetActive(visible);
		runtimeBlueprintRoot.SetActive(!visible);
	}
	public function SetChosenBlueprintsSlotCount(count:Int):Void
	{
		chosenBlueprints.SetSlotCount(count);
	}
	public function SetViewLawnReturnBlockerActive(active:Bool):Void
	{
		viewLawnReturnBlocker.SetActive(active);
	}
	public function SetSideUIDisplaying(displaying:Bool):Void
	{
		sideUIDisplaying = displaying;
	}
	public function SetBlueprintChooseDisplaying(displaying:Bool):Void
	{
		blueprintChooseDisplaying = displaying;
	}
	public function SetSideUIBlend(blend:Float):Void
	{
		sideUIBlend = blend;
		if (animator.gameObject.activeInHierarchy)
			animator.SetFloat("SideUIBlend", sideUIBlend);
	}
	public function SetBlueprintChooseBlend(blend:Float):Void
	{
		blueprintChooseBlend = blend;
		if (animator.gameObject.activeInHierarchy)
			animator.SetFloat("BlueprintChooseBlend", blend);
	}
	public function SetBlueprintChooseViewAlmanacButtonActive(active:Bool):Void
	{
		choosingViewAlmanacButton.gameObject.SetActive(active);
	}
	public function SetBlueprintChooseViewStoreButtonActive(active:Bool):Void
	{
		choosingViewStoreButton.gameObject.SetActive(active);
	}
	public function UpdateBlueprintChooseElements(viewData:BlueprintChoosePanelViewData):Void
	{
		blueprintChoosePanel.UpdateElements(viewData);
	}
	public function UpdateBlueprintChooseItems(viewDatas:Array<ChoosingBlueprintViewData>):Void
	{
		blueprintChoosePanel.UpdateItems(viewDatas);
	}
	public function UpdateCommandBlockItem(viewData:ChoosingBlueprintViewData):Void
	{
		blueprintChoosePanel.UpdateCommandBlockItem(viewData);
	}
	public function ShowCommandBlockPanel():Void
	{
		commandBlockChoosePanel.gameObject.SetActive(true);
	}
	public function HideCommandBlockPanel():Void
	{
		commandBlockChoosePanel.gameObject.SetActive(false);
	}
	public function UpdateCommandBlockChooseItems(viewDatas:Array<ChoosingBlueprintViewData>):Void
	{
		commandBlockChoosePanel.UpdateItems(viewDatas);
	}
	public function GetBlueprintChooseItem(index:Int):Null<Blueprint>
	{
		return blueprintChoosePanel.GetItem(index);
	}
	public function GetCommandBlockChooseItem(index:Int):Null<Blueprint>
	{
		return commandBlockChoosePanel.GetItem(index);
	}
	// #endregion

	// #region 已选蓝图
	public function CreateChosenBlueprint():Blueprint
	{
		return chosenBlueprints.CreateBlueprint();
	}
	public function InsertChosenBlueprint(index:Int, blueprint:Blueprint):Void
	{
		chosenBlueprints.InsertBlueprint(index, blueprint);
	}
	public function RemoveChosenBlueprint(blueprint:Blueprint):Bool
	{
		return chosenBlueprints.RemoveBlueprint(blueprint);
	}
	public function RemoveChosenBlueprintAt(index:Int):Void
	{
		chosenBlueprints.RemoveBlueprintAt(index);
	}
	public function DestroyChosenBlueprint(blueprint:Blueprint):Bool
	{
		return chosenBlueprints.DestroyBlueprint(blueprint);
	}
	public function DestroyChosenBlueprintAt(index:Int):Void
	{
		chosenBlueprints.DestroyBlueprintAt(index);
	}
	public function GetChosenBlueprintAt(index:Int):Null<Blueprint>
	{
		return chosenBlueprints.GetBlueprintAt(index);
	}
	public function GetChosenBlueprintIndex(blueprint:Blueprint):Int
	{
		return chosenBlueprints.GetBlueprintIndex(blueprint);
	}
	public function GetChosenBlueprintPosition(index:Int):Vector3
	{
		return chosenBlueprints.GetBlueprintPosition(index);
	}
	public function GetChosenBlueprintCount():Int
	{
		return chosenBlueprints.GetBlueprintCount();
	}
	// #endregion

	// #region 选择制品
	public function SetArtifactSlotsActive(visible:Bool):Void
	{
		artifactSlotsRoot.SetActive(visible);
	}
	public function SetArtifactRepickButtonActive(visible:Bool):Void
	{
		artifactRepickButton.gameObject.SetActive(visible);
	}
	public function GetArtifactSlotAt(index:Int):Null<ArtifactSlot>
	{
		return artifactSlotList.getElementAs(index, ArtifactSlot);
	}
	public function ShowArtifactChoosePanel(viewDatas:Array<ArtifactSelectItemViewData>):Void
	{
		artifactChoosingDialogObj.SetActive(true);
		artifactChoosingDialog.UpdateArtifacts(viewDatas);
	}
	public function HideArtifactChoosePanel():Void
	{
		artifactChoosingDialogObj.SetActive(false);
	}
	public function GetArtifactSelectItem(index:Int):Null<ArtifactSelectItem>
	{
		return artifactChoosingDialog.GetArtifactSelectItem(index);
	}
	public function ResetArtifactSlotCount(count:Int):Void
	{
		artifactSlotList.updateList(count,
			function(i:Int, rect:RectTransform)
			{
				var artifactIcon = rect.GetComponent(ArtifactSlot);
				artifactIcon.ResetView();
			},
			function(rect:RectTransform)
			{
				var artifactIcon = rect.GetComponent(ArtifactSlot);
				artifactIcon.OnClick.add(OnBlueprintChooseArtifactSlotClickCallback);
				artifactIcon.OnPointerEnterSignal.add(OnBlueprintChooseArtifactSlotPointerEnterCallback);
				artifactIcon.OnPointerExitSignal.add(OnBlueprintChooseArtifactSlotPointerExitCallback);
			},
			function(rect:RectTransform)
			{
				var artifactIcon = rect.GetComponent(ArtifactSlot);
				artifactIcon.OnClick.remove(OnBlueprintChooseArtifactSlotClickCallback);
				artifactIcon.OnPointerEnterSignal.remove(OnBlueprintChooseArtifactSlotPointerEnterCallback);
				artifactIcon.OnPointerExitSignal.remove(OnBlueprintChooseArtifactSlotPointerExitCallback);
			});
	}
	public function UpdateArtifactSlotAt(index:Int, viewData:ArtifactViewData):Void
	{
		var element = artifactSlotList.getElementAs(index, ArtifactSlot);
		if (!UnityObject.exists(element))
			return;
		element.UpdateView(viewData);
	}
	// #endregion

	public function GetCommandBlockSlotBlueprint():Null<Blueprint>
	{
		return blueprintChoosePanel.GetCommandBlockBlueprintItem();
	}

	private function Awake():Void
	{
		viewLawnReturnButton.onClick.AddListener(() -> OnViewLawnReturnClick.dispatch());

		artifactRepickButton.onClick.AddListener(() -> OnArtifactRepickButtonClick.dispatch());

		artifactChoosingDialog.OnItemClicked.add(index -> OnArtifactChoosingItemClicked.dispatch(index));
		artifactChoosingDialog.OnItemPointerEnter.add(index -> OnArtifactChoosingItemEnter.dispatch(index));
		artifactChoosingDialog.OnItemPointerExit.add(index -> OnArtifactChoosingItemExit.dispatch(index));
		artifactChoosingDialog.OnBackButtonClicked.add(() -> OnArtifactChoosingBackClicked.dispatch());

		blueprintChoosePanel.OnStartButtonClick.add(() -> OnStartClick.dispatch());
		blueprintChoosePanel.OnViewLawnButtonClick.add(() -> OnViewLawnClick.dispatch());
		blueprintChoosePanel.OnRepickButtonClick.add(() -> OnRepickClick.dispatch());
		blueprintChoosePanel.OnCancelButtonClick.add(() -> OnCancelChooseClick.dispatch());
		blueprintChoosePanel.OnCommandBlockBlueprintPointerInteraction.add((e, i) -> OnCommandBlockPointerInteraction.dispatch(e, i));
		blueprintChoosePanel.OnCommandBlockBlueprintSelect.add(e -> OnCommandBlockSlotSelect.dispatch(e));
		blueprintChoosePanel.OnBlueprintPointerInteraction.add((index, data, i) -> OnBlueprintItemPointerInteraction.dispatch(index, data, i, false));
		blueprintChoosePanel.OnBlueprintSelect.add((index, data) -> OnBlueprintItemSelect.dispatch(index, data, false));

		commandBlockChoosePanel.OnCancelButtonClick.add(() -> OnCommandBlockPanelCancelClick.dispatch());
		commandBlockChoosePanel.OnBlueprintPointerInteraction.add((index, data, i) -> OnBlueprintItemPointerInteraction.dispatch(index, data, i, true));
		commandBlockChoosePanel.OnBlueprintSelect.add((index, data) -> OnBlueprintItemSelect.dispatch(index, data, true));

		choosingViewAlmanacButton.onClick.AddListener(() -> OnViewAlmanacClick.dispatch());
		choosingViewStoreButton.onClick.AddListener(() -> OnViewStoreClick.dispatch());
	}
	public function UpdateFrame(deltaTime:Float):Void
	{
		var targetSideUIBlend = sideUIDisplaying ? 1 : 0;
		var targetBlueprintChooseBlend = blueprintChooseDisplaying ? 1 : 0;
		var blendSpeed = 10; // const
		var sideUIBlendAddition = (targetSideUIBlend - sideUIBlend) * blendSpeed * deltaTime;
		var blueprintChooseAddition = (targetBlueprintChooseBlend - blueprintChooseBlend) * blendSpeed * deltaTime;
		SetSideUIBlend(sideUIBlend + sideUIBlendAddition);
		SetBlueprintChooseBlend(blueprintChooseBlend + blueprintChooseAddition);
	}

	// #region 事件回调
	private function OnBlueprintChooseArtifactSlotClickCallback(icon:ArtifactSlot):Void
	{
		OnArtifactSlotClick.dispatch(artifactSlotList.indexOfComponent(icon));
	}
	private function OnBlueprintChooseArtifactSlotPointerEnterCallback(icon:ArtifactSlot):Void
	{
		OnArtifactSlotPointerEnter.dispatch(artifactSlotList.indexOfComponent(icon));
	}
	private function OnBlueprintChooseArtifactSlotPointerExitCallback(icon:ArtifactSlot):Void
	{
		OnArtifactSlotPointerExit.dispatch(artifactSlotList.indexOfComponent(icon));
	}
	// #endregion

	// #region 事件
	public var OnStartClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnViewLawnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnRepickClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnCancelChooseClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnCommandBlockPointerInteraction:FlxTypedSignal<PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	public var OnCommandBlockSlotSelect:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnCommandBlockPanelCancelClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnArtifactSlotClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnArtifactSlotPointerEnter:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnArtifactSlotPointerExit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnBlueprintItemPointerInteraction:FlxTypedSignal<Int->PointerEventData->PointerInteraction->Bool->Void> = new FlxTypedSignal();
	public var OnBlueprintItemSelect:FlxTypedSignal<Int->PointerEventData->Bool->Void> = new FlxTypedSignal();

	public var OnViewAlmanacClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnViewStoreClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnViewLawnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();

	public var OnArtifactChoosingItemClicked:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnArtifactChoosingItemEnter:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnArtifactChoosingItemExit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnArtifactChoosingBackClicked:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnArtifactRepickButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	// #endregion

	private var sideUIBlend:Float = 1;
	private var blueprintChooseBlend:Float;
	@:serializeField
	private var animator:Animator;
	// [Header("Blueprint Choose")]
	@:serializeField
	private var choosingBlueprintRoot:GameObject;
	@:serializeField
	private var runtimeBlueprintRoot:GameObject;
	@:serializeField
	private var chosenBlueprints:BlueprintList;
	@:serializeField
	private var viewLawnReturnButton:Button;
	@:serializeField
	private var viewLawnReturnBlocker:GameObject;
	@:serializeField
	private var artifactChoosingDialogObj:GameObject;
	@:serializeField
	private var artifactChoosingDialog:ArtifactChoosingDialog;
	@:serializeField
	private var movingBlueprints:MovingBlueprintList;
	@:serializeField
	private var blueprintChoosePanel:BlueprintChoosePanel;
	@:serializeField
	private var commandBlockChoosePanel:CommandBlockChoosePanel;
	@:serializeField
	private var choosingViewAlmanacButton:Button;
	@:serializeField
	private var choosingViewStoreButton:Button;
	@:serializeField
	private var sideUIDisplaying:Bool = true;
	@:serializeField
	private var blueprintChooseDisplaying:Bool;
	@:serializeField
	private var artifactSlotsRoot:GameObject;
	@:serializeField
	private var artifactSlotList:ElementListUI;
	@:serializeField
	private var artifactRepickButton:Button;
}
