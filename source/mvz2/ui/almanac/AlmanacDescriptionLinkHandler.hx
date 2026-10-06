// Ported from: Assets/Scripts/View/Almanac/AlmanacDescriptionLinkHandler.cs
package mvz2.ui.almanac;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Input;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.tmpro.TMP_TextInfo;
import unity.tmpro.TMP_Text;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IPointerClickHandler;
import unity.tmpro.TMP_Text.TMP_TextUtilities;
import unity.tmpro.TMP_TextInfo.TMP_LinkInfo;
import flixel.util.FlxSignal;

class AlmanacDescriptionLinkHandler extends unity.MonoBehaviour implements IPointerClickHandler
{
	public function OnPointerClick(eventData:PointerEventData):Void
	{
		// 检查点击的区域是否是文本链接
		// PORT-NOTE: unity.tmpro.TextMeshProUGUI 与 TMP_Text 在兼容层中不是同一继承链，此处用 cast 满足 C# 的 TMP_Text 形参。
		var linkIndex = TMP_TextUtilities.FindIntersectingLink(cast tmpText, Input.mousePosition, eventData.pressEventCamera);
		if (linkIndex != -1)
		{
			var linkInfo:TMP_LinkInfo = tmpText.textInfo.linkInfo[linkIndex];
			var url = linkInfo.GetLinkID();
			OnLinkClick.dispatch(url);
		}
	}

	// #region 事件
	public var OnLinkClick:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	// #endregion

	// #region 属性字段
	@:serializeField
	private var tmpText:TextMeshProUGUI;
	// #endregion
}
