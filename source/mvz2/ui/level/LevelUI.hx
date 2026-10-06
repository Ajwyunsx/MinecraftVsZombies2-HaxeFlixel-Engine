// Ported from: Assets/Scripts/View/Level/LevelUI.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.models.IModelBuilder;
import mvz2.models.Model;
import mvz2.ui.OptionsDialog;
import mvz2.ui.level.LevelUIBlueprints;
import mvz2.ui.level.LevelUIBlueprintChoose;
import mvz2.ui.level.LevelUIPreset;
import unity.Animator;
import unity.Color;
import unity.GameObject;
import unity.RectTransform;
import unity.Sprite;
import unity.UnityObject;
import unity.Vector2;
import unity.ui.Image;
import mvz2.ui.level.LevelLoadedDialog.ButtonType;
import unity.MonoBehaviour;
import mvz2.ui.level.LevelUIBlueprints.ILevelBlueprintRuntimeUI;
import flixel.util.FlxSignal;

interface ILevelUI
{
	function SetReceiveRaycasts(receive:Bool):Void;
	function SetBlueprintsSortingToChoosing(choosing:Bool):Void;
	var Blueprints(get, never):ILevelBlueprintRuntimeUI;
	var BlueprintChoose(get, never):LevelUIBlueprintChoose;
}

class LevelUI extends unity.MonoBehaviour implements ILevelUI
{
	public function SetReceiveRaycasts(value:Bool):Void
	{
		GetUIPreset().SetReceiveRaycasts(value);
	}
	public function SetScreenCover(value:Color):Void
	{
		blackscreenImage.color = value;
	}
	public function SetRaycastDisabled(disabled:Bool):Void
	{
		if (animator.gameObject.activeInHierarchy)
			animator.SetBool("RaycastDisabled", disabled);
	}
	public function SetExitingToNote():Void
	{
		animator.SetTrigger("Exit");
	}
	public function CallExitLevelToNote():Void
	{
		OnExitLevelToNoteCalled.dispatch();
	}
	public function ShowYouDied():Void
	{
		animator.SetTrigger("YouDied");
	}
	public function SetMobile(mobile:Bool):Void
	{
		isMobile = mobile;
		var uiPreset = GetUIPreset();
		standaloneUI.SetActive(standaloneUI == uiPreset);
		mobileUI.SetActive(mobileUI == uiPreset);
	}
	public function GetUIPreset():LevelUIPreset
	{
		return isMobile ? mobileUI : standaloneUI;
	}
	public function SetUIDisabled(disabled:Bool):Void
	{
		var uiPreset = GetUIPreset();
		uiPreset.SetUIDisabled(disabled);
	}

	// #region 蓝图
	public function SetBlueprintsSortingToChoosing(choosing:Bool):Void
	{
		var uiPreset = GetUIPreset();
		uiPreset.SetBlueprintsSortingToChoosing(choosing);
	}
	// #endregion

	// #region 手持物品
	public function SetHeldItemPosition(worldPos:Vector2):Void
	{
		heldItem.transform.position = worldPos;
	}
	public function SetHeldItemModel(builder:IModelBuilder):Void
	{
		heldItem.SetModel(builder);
	}
	public function SetHeldItemTrigger(visible:Bool, trigger:Bool):Void
	{
		heldItem.SetTrigger(visible, trigger);
	}
	public function SetHeldItemImbued(value:Bool):Void
	{
		heldItem.SetImbued(value);
	}
	public function GetHeldItemModel():Null<Model>
	{
		return heldItem.GetModel();
	}
	public function UpdateHeldItemModelFixed():Void
	{
		heldItem.UpdateModelFixed();
	}
	public function UpdateHeldItemModelFrame(deltaTime:Float):Void
	{
		heldItem.UpdateModelFrame(deltaTime);
	}
	public function SetHeldItemModelSimulationSpeed(speed:Float):Void
	{
		heldItem.SetModelSimulationSpeed(speed);
	}
	// #endregion

	// #region 暂停对话框
	public function SetPauseDialogActive(active:Bool):Void
	{
		pauseDialogObj.SetActive(active);
		ResetPauseDialogPosition();
	}
	public function ResetPauseDialogPosition():Void
	{
		var rectTrans:RectTransform = cast pauseDialogObj.transform;
		if (UnityObject.exists(rectTrans))
		{
			rectTrans.anchoredPosition = Vector2.zero;
		}
	}
	public function SetPauseDialogImage(sprite:Sprite):Void
	{
		pauseDialog.SetPausedImage(sprite);
	}
	// #endregion

	// #region 游戏结束对话框
	public function SetGameOverDialogActive(active:Bool):Void
	{
		gameOverDialogObj.SetActive(active);
	}
	public function SetGameOverDialogMessage(text:String):Void
	{
		gameOverDialog.SetMessage(text);
	}
	public function SetGameOverDialogInteractable(interactable:Bool):Void
	{
		gameOverDialog.SetInteractable(interactable);
	}
	// #endregion

	// #region 菜单对话框
	public function SetOptionsDialogActive(visible:Bool):Void
	{
		optionsDialogObj.SetActive(visible);
		ResetOptionsDialogPosition();
	}
	public function ResetOptionsDialogPosition():Void
	{
		var rectTrans:RectTransform = cast optionsDialogObj.transform;
		if (UnityObject.exists(rectTrans))
		{
			rectTrans.anchoredPosition = Vector2.zero;
		}
	}
	// #endregion

	// #region 加载关卡对话框
	public function SetLevelLoadedDialogVisible(visible:Bool):Void
	{
		levelLoadedDialogObj.SetActive(visible);
	}
	public function SetLevelErrorLoadingDialogVisible(visible:Bool):Void
	{
		levelErrorLoadingDialogObj.SetActive(visible);
	}
	public function SetLevelErrorLoadingDialogDesc(text:String):Void
	{
		levelErrorLoadingDialog.SetDescription(text);
	}
	public function SetLevelErrorLoadingDialogInteractable(interactable:Bool):Void
	{
		levelErrorLoadingDialog.SetInteractable(interactable);
	}
	// #endregion



	private function Awake():Void
	{
		pauseDialog.OnResumeClicked.add(() -> OnPauseDialogResumeClicked.dispatch());

		gameOverDialog.OnRetryButtonClicked.add(() -> OnGameOverRetryButtonClicked.dispatch());
		gameOverDialog.OnBackButtonClicked.add(() -> OnGameOverBackButtonClicked.dispatch());

		levelLoadedDialog.OnButtonClicked.add((button) -> OnLevelLoadedDialogButtonClicked.dispatch(button));
		levelErrorLoadingDialog.OnButtonClicked.add((restart) -> OnLevelErrorLoadingDialogButtonClicked.dispatch(restart));

		standaloneUI.OnStartGameCalled.add(() -> OnStartGameCalled.dispatch());
		mobileUI.OnStartGameCalled.add(() -> OnStartGameCalled.dispatch());
	}

	public var OnStartGameCalled:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnExitLevelToNoteCalled:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnPauseDialogResumeClicked:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnGameOverRetryButtonClicked:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnGameOverBackButtonClicked:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnLevelLoadedDialogButtonClicked:FlxTypedSignal<ButtonType->Void> = new FlxTypedSignal();
	public var OnLevelErrorLoadingDialogButtonClicked:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();
	public var OptionsDialog(get, never):OptionsDialog;
	function get_OptionsDialog():OptionsDialog return optionsDialog;


	public var BlueprintChoose(get, never):LevelUIBlueprintChoose;
	function get_BlueprintChoose():LevelUIBlueprintChoose return GetUIPreset().BlueprintChoose;
	public var Blueprints(get, never):ILevelBlueprintRuntimeUI;
	function get_Blueprints():ILevelBlueprintRuntimeUI return GetUIPreset().Blueprints;

	private var isMobile:Bool;
	@:serializeField
	private var animator:Animator;

	@:serializeField
	private var standaloneUI:LevelUIPreset;
	@:serializeField
	private var mobileUI:LevelUIPreset;

	// [Header("Shading")]
	@:serializeField
	private var blackscreenImage:Image;

	// [Header("HeldItem")]
	@:serializeField
	private var heldItem:HeldItem;

	// [Header("Pause Dialog")]
	@:serializeField
	private var pauseDialogObj:GameObject;
	@:serializeField
	private var pauseDialog:PauseDialog;

	// [Header("Game Over Dialog")]
	@:serializeField
	private var gameOverDialogObj:GameObject;
	@:serializeField
	private var gameOverDialog:GameOverDialog;

	// [Header("Options Dialog")]
	@:serializeField
	private var optionsDialogObj:GameObject;
	@:serializeField
	private var optionsDialog:OptionsDialog;

	// [Header("Level Loaded Dialog")]
	@:serializeField
	private var levelLoadedDialogObj:GameObject;
	@:serializeField
	private var levelLoadedDialog:LevelLoadedDialog;

	// [Header("Level Error Loading Dialog")]
	@:serializeField
	private var levelErrorLoadingDialogObj:GameObject;
	@:serializeField
	private var levelErrorLoadingDialog:LevelErrorLoadingDialog;
}
