// Ported from: Assets/Scripts/View/Scene/AchievementHint.cs
package mvz2.ui.scene;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Animator;
import unity.GameObject;
import unity.Sprite;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class AchievementHint extends unity.MonoBehaviour
{
	public function SetVisible(value:Bool):Void
	{
		if (rootObj.activeSelf != value)
			rootObj.SetActive(value);
	}
	public function UpdateAchievement(icon:Null<Sprite>, name:String):Void
	{
		iconImage.sprite = icon;
		nameText.text = name;
	}
	public function SetShowValue(value:Float):Void
	{
		animator.SetFloat("Blend", value);
	}
	private function Awake():Void
	{
		button.onClick.AddListener(() -> OnClick.dispatch());
	}
	public var OnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var rootObj:GameObject;
	@:serializeField
	private var animator:Animator;
	@:serializeField
	private var iconImage:Image;
	@:serializeField
	private var button:Button;
	@:serializeField
	private var nameText:TextMeshProUGUI;
}
