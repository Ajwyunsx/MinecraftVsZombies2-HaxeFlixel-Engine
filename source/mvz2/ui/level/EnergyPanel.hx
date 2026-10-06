// Ported from: Assets/Scripts/View/Level/EnergyPanel.cs
package mvz2.ui.level;

import unity.Animator;
import unity.tmpro.TextMeshProUGUI;

class EnergyPanel extends LevelUIUnit
{
	public function FlickerEnergy():Void
	{
		textAnimator.SetTrigger("Flicker");
	}
	public function SetEnergy(energy:String):Void
	{
		energyText.text = energy;
	}
	@:serializeField
	private var textAnimator:Animator;
	@:serializeField
	private var energyText:TextMeshProUGUI;
}
