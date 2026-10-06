// Ported from: Assets/Scripts/View/Almanac/AlmanacTaggedDescription.cs
package mvz2.ui.almanac;

import mvz2.ui.almanac.AlmanacDescriptionTag;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.Mathf;
import unity.UnityObject;
import unity.Vector2;
import unity.Vector3;
import unity.tmpro.TMP_TextInfo;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;
import mvz2.ui.almanac.AlmanacDescriptionTag.AlmanacDescriptionTagViewData;
import unity.tmpro.TMP_TextInfo.TMP_LinkInfo;
import flixel.util.FlxSignal;

class AlmanacTaggedDescription extends unity.MonoBehaviour
{
	public function UpdateIconStacks(infos:Array<AlmanacDescriptionTagViewData>):Void
	{
		tmpText.ForceMeshUpdate();
		iconStackList.updateList(infos.length,
			function(i:Int, obj:GameObject)
			{
				var container = obj.GetComponent(AlmanacDescriptionTag);
				if (container == null)
					return;
				var viewData = infos[i];
				var linkID = viewData.linkID;
				// 查找占位符位置
				var linkIndex = FindLinkIndexByID(linkID);
				if (linkIndex == -1)
					return;

				var linkInfo:TMP_LinkInfo = tmpText.textInfo.linkInfo[linkIndex];
				var centerPos = CalculateLinkCenter(linkInfo);
				var linkSize = CalculateLinkSize(linkInfo);
				var worldPos = tmpText.transform.TransformPoint(centerPos);
				obj.name = linkID;
				obj.transform.position = worldPos;
				var xScale = linkSize.x / viewData.size.x;
				var yScale = linkSize.y / viewData.size.y;
				var scale = Mathf.Min(xScale, yScale);
				container.UpdateTag(viewData);
				container.SetScale(Vector3.one * scale);
			},
			function(obj:GameObject)
			{
				var container = obj.GetComponent(AlmanacDescriptionTag);
				container.OnPointerEnter.add(OnIconPointerEnterCallback);
				container.OnPointerExit.add(OnIconPointerExitCallback);
				container.OnPointerDown.add(OnIconPointerDownCallback);
			},
			function(obj:GameObject)
			{
				var container = obj.GetComponent(AlmanacDescriptionTag);
				container.OnPointerEnter.remove(OnIconPointerEnterCallback);
				container.OnPointerExit.remove(OnIconPointerExitCallback);
				container.OnPointerDown.remove(OnIconPointerDownCallback);
			});
	}
	public function GetIconContainer(index:Int):Null<AlmanacTagIcon>
	{
		if (index < 0)
			return null;
		var item = iconStackList.getElementAs(index, AlmanacDescriptionTag);
		if (!UnityObject.exists(item))
			return null;
		return item.icon;
	}
	private function FindLinkIndexByID(linkID:String):Int
	{
		var textInfo = tmpText.textInfo;
		if (textInfo == null)
			return -1;
		for (i in 0...textInfo.linkCount)
		{
			if (textInfo.linkInfo[i].GetLinkID() == linkID)
			{
				return i;
			}
		}
		return -1;
	}
	private function CalculateLinkCenter(linkInfo:TMP_LinkInfo):Vector3
	{
		var bottomLeft = tmpText.textInfo.characterInfo[linkInfo.linkTextfirstCharacterIndex].bottomLeft;
		var topRight = tmpText.textInfo.characterInfo[linkInfo.linkTextfirstCharacterIndex + linkInfo.linkTextLength - 1].topRight;

		return new Vector3((bottomLeft.x + topRight.x) / 2, (bottomLeft.y + topRight.y) / 2, 0);
	}
	private function CalculateLinkSize(linkInfo:TMP_LinkInfo):Vector2
	{
		var bottomLeft = tmpText.textInfo.characterInfo[linkInfo.linkTextfirstCharacterIndex].bottomLeft;
		var topRight = tmpText.textInfo.characterInfo[linkInfo.linkTextfirstCharacterIndex + linkInfo.linkTextLength - 1].topRight;

		return new Vector2(Mathf.Abs(topRight.x - bottomLeft.x), Mathf.Abs(topRight.y - bottomLeft.y));
	}
	private function OnIconPointerEnterCallback(linkID:String):Void
	{
		OnIconEnter.dispatch(linkID);
	}
	private function OnIconPointerExitCallback(linkID:String):Void
	{
		OnIconExit.dispatch(linkID);
	}
	private function OnIconPointerDownCallback(linkID:String):Void
	{
		OnIconDown.dispatch(linkID);
	}

	// #region 事件
	public var OnIconEnter:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var OnIconExit:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var OnIconDown:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	// #endregion

	// #region 属性字段
	@:serializeField
	private var iconStackList:ElementList;
	@:serializeField
	private var tmpText:TextMeshProUGUI;
	// #endregion
}
