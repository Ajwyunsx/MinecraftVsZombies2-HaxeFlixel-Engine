// Ported from: Assets/Scripts/View/Almanac/IndexAlmanacPage.cs
package mvz2.ui.almanac;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.GameObject;
import unity.ui.Button;
import flixel.util.FlxSignal;

class IndexAlmanacPage extends AlmanacPage
{
	// protected override
	public override function Awake():Void
	{
		super.Awake();
		viewContraptionButton.onClick.AddListener(() -> OnButtonClick.dispatch(ButtonType.ViewContraption));
		viewEnemyButton.onClick.AddListener(() -> OnButtonClick.dispatch(ButtonType.ViewEnemy));
		viewArtifactButton.onClick.AddListener(() -> OnButtonClick.dispatch(ButtonType.ViewArtifact));
		viewMiscButton.onClick.AddListener(() -> OnButtonClick.dispatch(ButtonType.ViewMisc));
	}
	public function SetArtifactVisible(visible:Bool):Void
	{
		artifactRegion.SetActive(visible);
	}
	public var OnButtonClick:FlxTypedSignal<ButtonType->Void> = new FlxTypedSignal();
	@:serializeField
	private var artifactRegion:GameObject;
	@:serializeField
	private var viewContraptionButton:Button;
	@:serializeField
	private var viewEnemyButton:Button;
	@:serializeField
	private var viewArtifactButton:Button;
	@:serializeField
	private var viewMiscButton:Button;
}

enum abstract ButtonType(Int)
{
	var ViewContraption = 0;
	var ViewEnemy = 1;
	var ViewArtifact = 2;
	var ViewMisc = 3;
}
