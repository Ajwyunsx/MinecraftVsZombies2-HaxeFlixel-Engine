// Ported from: Assets/Scripts/View/Mainmenu/AchievementsUI.cs
package mvz2.ui.mainmenu;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.ui.Button;
import mvz2.ui.mainmenu.AchievementEntryUI;
import unity.MonoBehaviour;
import mvz2.ui.mainmenu.AchievementEntryUI.AchievementEntryViewData;
import flixel.util.FlxSignal;

class AchievementsUI extends unity.MonoBehaviour
{
	public function UpdateAchievements(entries:Array<AchievementEntryViewData>):Void
	{
		entryList.updateList(entries.length,
			function(i:Int, obj:GameObject)
			{
				var category = obj.GetComponent(AchievementEntryUI);
				category.UpdateEntry(entries[i]);
			});
	}
	private function Awake():Void
	{
		backButton.onClick.AddListener(() -> OnReturnClick.dispatch());
	}
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var entryList:ElementList;
	@:serializeField
	private var backButton:Button;
}
