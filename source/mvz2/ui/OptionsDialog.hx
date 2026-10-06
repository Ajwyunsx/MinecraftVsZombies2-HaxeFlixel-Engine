// Ported from: Assets/Scripts/View/Dialogs/Options/OptionsDialog.cs
package mvz2.ui;

import mvz2.ui.OptionsDialogMainPage;
import mvz2.ui.OptionsDialogMoreOptionsPage;
import unity.Camera;
import unity.RectTransform;
import unity.UnityObject;
import Main;

class OptionsDialog extends Dialog
{
	public function GetCamera():Null<Camera>
	{
		return canvasCamera;
	}
	public function SetPage(page:Page):Void
	{
		mainPage.gameObject.SetActive(page == Page.Main);
		morePage.gameObject.SetActive(page == Page.More);
	}

	// #region 生命周期
	private function Awake():Void
	{
		var rectTrans:RectTransform = cast transform;
		if (UnityObject.exists(rectTrans))
		{
			// PORT-NOTE: C# 扩展方法 RectTransform.GetRootCanvas() 在 Haxe 中改为静态调用 UIHelper.GetRootCanvas。
			var rootCanvas = UIHelper.GetRootCanvas(rectTrans);
			if (UnityObject.exists(rootCanvas))
			{
				canvasCamera = rootCanvas.worldCamera;
			}
		}
	}
	// #endregion

	public var Main(get, never):OptionsDialogMainPage;
	function get_Main():OptionsDialogMainPage return mainPage;
	public var MoreOptions(get, never):OptionsDialogMoreOptionsPage;
	function get_MoreOptions():OptionsDialogMoreOptionsPage return morePage;
	private var canvasCamera:Null<Camera>;

	// [Header("Pages")]
	@:serializeField
	private var mainPage:OptionsDialogMainPage;
	@:serializeField
	private var morePage:OptionsDialogMoreOptionsPage;
}

enum abstract Page(Int)
{
	var Main = 0;
	var More = 1;
}
