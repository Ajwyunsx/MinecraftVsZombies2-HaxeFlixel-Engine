// Ported from: Assets/Scripts/View/UI/MoneyPanel.cs
package mvz2.ui;

import unity.CanvasGroup;
import unity.Mathf;
import unity.Time;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;

class MoneyPanel extends unity.MonoBehaviour
{
	public function SetMoney(money:String):Void
	{
		moneyText.text = money;
	}
	public function SetFade(fade:Bool):Void
	{
		willFade = fade;
	}
	public function Hide():Void
	{
		fadeTimeout = 0;
	}
	public function ResetTimeout():Void
	{
		fadeTimeout = maxFadeTimeout;
	}
	function Update():Void
	{
		if (willFade)
		{
			fadeTimeout -= unity.Time.deltaTime;
			if (fadeTimeout <= 0)
			{
				fadeTimeout = 0;
			}
		}
		else
		{
			fadeTimeout = maxFadeTimeout;
		}
		canvasGroup.alpha = Mathf.Clamp01(fadeTimeout / 0.5);
	}
	@:serializeField
	private var canvasGroup:CanvasGroup;
	@:serializeField
	private var moneyText:TextMeshProUGUI;
	@:serializeField
	private var willFade:Bool;
	@:serializeField
	private var maxFadeTimeout:Float;
	private var fadeTimeout:Float;
}
