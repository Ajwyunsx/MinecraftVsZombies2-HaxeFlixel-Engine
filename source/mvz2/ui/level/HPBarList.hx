// Ported from: Assets/Scripts/View/Level/HPBar/HPBarList.cs
package mvz2.ui.level;

import mvz2.ui.ElementList;
import unity.Canvas;
import unity.Camera;
import unity.UnityObject;
import mvz2.ui.level.HPBar;
import unity.MonoBehaviour;
import mvz2.ui.level.HPBar.HPBarViewData;

class HPBarList extends unity.MonoBehaviour
{
	public function SetActive(value:Bool):Void
	{
		gameObject.SetActive(value);
	}
	public function IsActiveSelf():Bool
	{
		return gameObject.activeSelf;
	}
	public function SetCamera(camera:Camera):Void
	{
		canvas.worldCamera = camera;
	}
	public function SetBarCount(count:Int):Void
	{
		barList.updateList(count);
	}
	public function GetBarCount():Int
	{
		return barList.Count;
	}
	public function UpdateBar(index:Int, viewData:HPBarViewData):Void
	{
		var bar = barList.getElementAs(index, HPBar);
		if (UnityObject.exists(bar))
		{
			bar.UpdateBar(viewData);
		}
	}
	@:serializeField
	private var canvas:Canvas;
	@:serializeField
	private var barList:ElementList;
}
