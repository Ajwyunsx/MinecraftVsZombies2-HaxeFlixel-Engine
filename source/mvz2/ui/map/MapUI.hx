// Ported from: Assets/Scripts/View/Map/MapUI.cs
package mvz2.ui.map;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.OptionsDialog;
import unity.Camera;
import unity.GameObject;
import unity.RectTransform;
import unity.Vector2;
import unity.Vector3;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import mvz2.gamecontent.artifacts.Almanac;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class MapUI extends unity.MonoBehaviour
{
	public function SetButtonActive(button:ButtonType, active:Bool):Void
	{
		if (buttonDict.exists(button))
		{
			var btn = buttonDict.get(button);
			btn.gameObject.SetActive(active);
		}
	}
	public function SetHintText(text:String):Void
	{
		hintText.text = text;
	}
	public function SetDragRootVisible(visible:Bool):Void
	{
		dragRoot.SetActive(visible);
	}
	public function SetOptionsDialogActive(active:Bool):Void
	{
		optionsDialog.gameObject.SetActive(active);
	}
	public function SetRaycastBlockerActive(active:Bool):Void
	{
		raycastBlocker.SetActive(active);
	}
	public function SetDragRootPosition(screenPos:Vector2):Void
	{
		dragRootTrans.position = mapCamera.ScreenToWorldPoint(screenPos);
		var localPos = dragRootTrans.localPosition;
		localPos.z = 0;
		dragRootTrans.localPosition = localPos;
	}
	public function SetDragArrowTargetPosition(screenPos:Vector2):Void
	{
		var worldPos = mapCamera.ScreenToWorldPoint(screenPos);
		worldPos.z = 0;
		var toArrow = worldPos - dragArrowRoot.position;
		var angle = Vector2.SignedAngle(Vector2.up, new Vector2(toArrow.x, toArrow.y));
		dragArrowRoot.eulerAngles = Vector3.forward * angle;

		var worldInParent = dragArrowRoot.parent.InverseTransformPoint(worldPos);
		var localPos = new Vector2(worldInParent.x, worldInParent.y);
		dragArrowRoot.sizeDelta = new Vector2(0, localPos.magnitude);
	}
	public function SetStoreArrowVisible(visible:Bool):Void
	{
		storeButtonArrow.SetActive(visible);
	}
	public function SetMapArrowVisible(visible:Bool):Void
	{
		mapButtonArrow.SetActive(visible);
	}
	private function Awake():Void
	{
		buttonDict.set(ButtonType.Back, backButton);
		buttonDict.set(ButtonType.Almanac, almanacButton);
		buttonDict.set(ButtonType.Store, storeButton);
		buttonDict.set(ButtonType.Map, mapButton);
		buttonDict.set(ButtonType.Setting, settingButton);

		for (button in buttonDict.keys())
		{
			var capturedButton = button;
			var target = buttonDict.get(button);
			target.onClick.AddListener(() -> OnButtonClick.dispatch(capturedButton));
		}
	}
	public var OnButtonClick:FlxTypedSignal<ButtonType->Void> = new FlxTypedSignal();

	private var buttonDict:Map<ButtonType, Button> = new Map<ButtonType, Button>();

	public var OptionsDialog(get, never):OptionsDialog;
	function get_OptionsDialog():OptionsDialog return optionsDialog;

	// [Header("General")]
	@:serializeField
	private var backButton:Button;
	@:serializeField
	private var almanacButton:Button;
	@:serializeField
	private var storeButton:Button;
	@:serializeField
	private var mapButton:Button;
	@:serializeField
	private var settingButton:Button;
	@:serializeField
	private var storeButtonArrow:GameObject;
	@:serializeField
	private var mapButtonArrow:GameObject;
	@:serializeField
	private var hintText:TextMeshProUGUI;
	@:serializeField
	private var optionsDialog:OptionsDialog;
	@:serializeField
	private var raycastBlocker:GameObject;

	// [Header("Drag")]
	@:serializeField
	private var mapCamera:Camera;
	@:serializeField
	private var dragRoot:GameObject;
	@:serializeField
	private var dragRootTrans:RectTransform;
	@:serializeField
	private var dragArrowRoot:RectTransform;
}

enum abstract ButtonType(Int)
{
	var Back = 0;
	var Almanac = 1;
	var Store = 2;
	var Map = 3;
	var Setting = 4;
}
