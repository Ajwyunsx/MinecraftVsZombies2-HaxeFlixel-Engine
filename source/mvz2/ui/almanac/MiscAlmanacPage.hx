// Ported from: Assets/Scripts/View/Almanac/MiscAlmanacPage.cs
package mvz2.ui.almanac;

import mvz2.ui.almanac.AlmanacEntry;

import mvz2.ui.almanac.AlmanacEntryGroupUI;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.models.IModelBuilder;
import mvz2.ui.ElementList;
import unity.Color;
import unity.GameObject;
import unity.Sprite;
import unity.UnityObject;
import unity.Vector2;
import unity.ui.Button;
import unity.ui.Image;
import mvz2.ui.almanac.AlmanacEntry.AlmanacEntryViewData;
import mvz2.ui.almanac.AlmanacEntryGroupUI.AlmanacEntryGroupViewData;
import flixel.util.FlxSignal;

class MiscAlmanacPage extends BookAlmanacPage
{
	public function SetGroups(groups:Array<AlmanacEntryGroupViewData>):Void
	{
		groupList.updateList(groups.length,
			function(i:Int, obj:GameObject)
			{
				var entry = obj.GetComponent(AlmanacEntryGroupUI);
				entry.UpdateEntry(groups[i]);
			},
			function(obj:GameObject)
			{
				var entry = obj.GetComponent(AlmanacEntryGroupUI);
				entry.OnEntryClick.add(OnGroupEntryClickCallback);
			},
			function(obj:GameObject)
			{
				var entry = obj.GetComponent(AlmanacEntryGroupUI);
				if (UnityObject.exists(entry))
				{
					entry.OnEntryClick.remove(OnGroupEntryClickCallback);
				}
			});
	}
	public function SetEntries(entries:Array<AlmanacEntryViewData>):Void
	{
		entryList.updateList(entries.length,
			function(i:Int, obj:GameObject)
			{
				var entry = obj.GetComponent(AlmanacEntry);
				entry.UpdateEntry(entries[i]);
			},
			function(obj:GameObject)
			{
				var entry = obj.GetComponent(AlmanacEntry);
				entry.OnClick.add(OnEntryClickCallback);
			},
			function(obj:GameObject)
			{
				var entry = obj.GetComponent(AlmanacEntry);
				if (UnityObject.exists(entry))
				{
					entry.OnClick.remove(OnEntryClickCallback);
				}
			});
	}
	public function SetActiveEntry(image:Null<Sprite>, color:Color, name:String, description:String, sized:Bool, zoom:Bool):Void
	{
		// PORT-NOTE: C# 为 `entryImageRegion.gameObject.SetActive(...)`。GameObject.gameObject 是返回自身的
		// 自引用属性，unity shim 的 GameObject 未定义该属性，故直接作用于对象本身（语义等价）。
		entryImageRegion.SetActive(true);
		entryModel.gameObject.SetActive(false);
		if (sized)
		{
			entryImageFull.sprite = null;
			entryImageFull.enabled = false;
			entryImageSized.sprite = image;
			entryImageSized.enabled = image != null;
			entryImageSized.color = color;
			if (UnityObject.exists(image))
			{
				entryImageSized.rectTransform.sizeDelta = image.rect.size;
			}
		}
		else
		{
			entryImageFull.sprite = image;
			entryImageFull.enabled = image != null;
			entryImageFull.color = color;
			entryImageSized.sprite = null;
			entryImageSized.enabled = false;
			entryImageSized.rectTransform.sizeDelta = Vector2.zero;
		}
		iconZoomButtonRoot.SetActive(zoom);
		SetDescription(name, description);
	}
	// PORT-NOTE: C# 的 SetActiveEntry(IModelBuilder, ...) 重载与 SetActiveEntry(Sprite?, ...) 不能同名共存，带模型的版本改名（与 AlmanacController 的调用保持一致）。
	public function SetActiveEntryFromModel(model:IModelBuilder, name:String, description:String):Void
	{
		// PORT-NOTE: 同 SetActiveEntry，C# 的 `entryImageRegion.gameObject` 即对象自身。
		entryImageRegion.SetActive(false);
		entryModel.gameObject.SetActive(true);
		entryModel.ChangeModel(model);
		SetDescription(name, description);
	}
	// protected override
	public override function Awake():Void
	{
		super.Awake();
		iconZoomButton.onClick.AddListener(() -> OnZoomClick.dispatch());
	}
	private function OnGroupEntryClickCallback(group:AlmanacEntryGroupUI, entryIndex:Int):Void
	{
		OnGroupEntryClick.dispatch(groupList.indexOfComponent(group), entryIndex);
	}
	private function OnEntryClickCallback(entry:AlmanacEntry):Void
	{
		OnEntryClick.dispatch(entryList.indexOfComponent(entry));
	}
	public var OnGroupEntryClick:FlxTypedSignal<Int->Int->Void> = new FlxTypedSignal();
	public var OnEntryClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnZoomClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var entryList:ElementList;
	@:serializeField
	private var groupList:ElementList;
	@:serializeField
	private var entryModel:AlmanacModel;
	@:serializeField
	private var entryImageRegion:GameObject;
	@:serializeField
	private var entryImageFull:Image;
	@:serializeField
	private var entryImageSized:Image;
	@:serializeField
	private var iconZoomButtonRoot:GameObject;
	@:serializeField
	private var iconZoomButton:Button;
}
