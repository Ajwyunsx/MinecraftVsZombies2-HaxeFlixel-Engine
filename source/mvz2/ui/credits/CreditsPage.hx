// Ported from: Assets/Scripts/View/Credits/CreditsPage.cs
package mvz2.ui.credits;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import mvz2.ui.credits.CreditsCategory;
import unity.ui.Button;
import unity.GameObject;
import unity.MonoBehaviour;
import mvz2.ui.credits.CreditsCategory.CreditsCategoryViewData;
import flixel.util.FlxSignal;

class CreditsPage extends unity.MonoBehaviour
{
	public function UpdateCredits(viewData:Array<CreditsCategoryViewData>):Void
	{
		categories.updateList(viewData.length,
			function(i:Int, obj:unity.GameObject)
			{
				var data = viewData[i];
				var category = obj.GetComponent(CreditsCategory);
				category.UpdateCategory(data);
			});
	}
	private function Awake():Void
	{
		backButton.onClick.AddListener(() -> OnBackButtonClick.dispatch());
	}
	public var OnBackButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();


	@:serializeField
	private var categories:ElementList;
	@:serializeField
	private var backButton:Button;
}
