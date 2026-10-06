// Ported from: Assets/Scripts/View/Almanac/AlmanacUI.cs
package mvz2.ui.almanac;

import mvz2.ui.almanac.AlmanacDescriptionTag;

import mvz2.ui.almanac.AlmanacTagIcon;

import mvz2.ui.almanac.AlmanacEntryGroupUI;

import mvz2.ui.almanac.AlmanacEntry;

import mvz2.ui.BlueprintDisplayer;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.models.IModelBuilder;
import unity.Color;
import unity.Sprite;
import unity.UnityObject;
import unity.eventsystems.PointerEventData;
import unity.ui.Button;
import mvz2.ui.almanac.IndexAlmanacPage.ButtonType;
import unity.MonoBehaviour;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;
import mvz2.ui.almanac.AlmanacDescriptionTag.AlmanacDescriptionTagViewData;
import mvz2.ui.almanac.AlmanacEntry.AlmanacEntryViewData;
import mvz2.ui.almanac.AlmanacEntryGroupUI.AlmanacEntryGroupViewData;
import mvz2.ui.almanac.AlmanacTagIcon.AlmanacTagIconViewData;
import flixel.util.FlxSignal;

class AlmanacUI extends unity.MonoBehaviour
{
	public function DisplayPage(page:AlmanacPageType):Void
	{
		indexUI.SetActive(page == AlmanacPageType.Index);
		standaloneContraptions.SetActive(page == AlmanacPageType.ContraptionsStandalone);
		mobileContraptions.SetActive(page == AlmanacPageType.ContraptionsMobile);
		enemies.SetActive(page == AlmanacPageType.Enemies);
		artifacts.SetActive(page == AlmanacPageType.Artifacts);
		miscs.SetActive(page == AlmanacPageType.Miscs);
	}
	public function SetIndexArtifactVisible(visible:Bool):Void
	{
		indexUI.SetArtifactVisible(visible);
	}
	public function GetTagIcon(page:AlmanacPageType, index:Int):Null<AlmanacTagIcon>
	{
		switch (page)
		{
			case AlmanacPageType.ContraptionsStandalone:
				return standaloneContraptions.GetTagIcon(index);
			case AlmanacPageType.ContraptionsMobile:
				return mobileContraptions.GetTagIcon(index);
			case AlmanacPageType.Enemies:
				return enemies.GetTagIcon(index);
			case AlmanacPageType.Artifacts:
				return artifacts.GetTagIcon(index);
			case AlmanacPageType.Miscs:
				return miscs.GetTagIcon(index);
			// PORT-NOTE: C# switch 非穷尽（Index 页无标签图标）；Haxe 要求穷尽，补空 case。
			case AlmanacPageType.Index:
		}
		return null;
	}
	public function GetDescriptionIcon(page:AlmanacPageType, index:Int):Null<AlmanacTagIcon>
	{
		switch (page)
		{
			case AlmanacPageType.ContraptionsStandalone:
				return standaloneContraptions.GetDescriptionIcon(index);
			case AlmanacPageType.ContraptionsMobile:
				return mobileContraptions.GetDescriptionIcon(index);
			case AlmanacPageType.Enemies:
				return enemies.GetDescriptionIcon(index);
			case AlmanacPageType.Artifacts:
				return artifacts.GetDescriptionIcon(index);
			case AlmanacPageType.Miscs:
				return miscs.GetDescriptionIcon(index);
			// PORT-NOTE: C# switch 非穷尽（Index 页无描述图标）；Haxe 要求穷尽，补空 case。
			case AlmanacPageType.Index:
		}
		return null;
	}
	public function SetContraptionEntries(entries:Array<ChoosingBlueprintViewData>, commandBlockVisible:Bool,
		commandBlockViewData:ChoosingBlueprintViewData):Void
	{
		standaloneContraptions.SetEntries(entries, commandBlockVisible, commandBlockViewData);
		mobileContraptions.SetEntries(entries, commandBlockVisible, commandBlockViewData);
	}
	public function SetEnemyEntries(entries:Array<AlmanacEntryViewData>):Void
	{
		enemies.SetEntries(entries);
	}
	public function SetArtifactEntries(entries:Array<AlmanacEntryViewData>):Void
	{
		artifacts.SetEntries(entries);
	}
	public function SetMiscGroups(groups:Array<AlmanacEntryGroupViewData>):Void
	{
		miscs.SetGroups(groups);
	}
	public function SetActiveContraptionEntry(model:IModelBuilder, name:String, description:String, cost:String, recharge:String):Void
	{
		standaloneContraptions.SetActiveEntry(model, name, description, cost, recharge);
		mobileContraptions.SetActiveEntry(model, name, description, cost, recharge);
	}
	public function SetActiveEnemyEntry(model:IModelBuilder, name:String, description:String):Void
	{
		enemies.SetActiveEntryFromModel(model, name, description);
	}
	public function SetActiveArtifactEntry(sprite:Null<Sprite>, color:Color, name:String, description:String):Void
	{
		artifacts.SetActiveEntry(sprite, color, name, description, true, false);
	}
	public function SetActiveMiscEntry(sprite:Null<Sprite>, name:String, description:String, ?sized:Bool = false, ?zoom:Bool = true):Void
	{
		miscs.SetActiveEntry(sprite, Color.white, name, description, sized, zoom);
	}
	// PORT-NOTE: C# 的 SetActiveMiscEntry(IModelBuilder, ...) 重载不能与 SetActiveMiscEntry(Sprite?, ...) 同名共存，改名（与 AlmanacController 的调用保持一致）。
	public function SetActiveMiscEntryFromModel(model:IModelBuilder, name:String, description:String):Void
	{
		miscs.SetActiveEntryFromModel(model, name, description);
	}
	public function UpdateTagIcons(page:AlmanacPageType, viewDatas:Array<AlmanacTagIconViewData>):Void
	{
		switch (page)
		{
			case AlmanacPageType.ContraptionsStandalone:
				standaloneContraptions.UpdateTagIcons(viewDatas);
			case AlmanacPageType.ContraptionsMobile:
				mobileContraptions.UpdateTagIcons(viewDatas);
			case AlmanacPageType.Enemies:
				enemies.UpdateTagIcons(viewDatas);
			case AlmanacPageType.Artifacts:
				artifacts.UpdateTagIcons(viewDatas);
			case AlmanacPageType.Miscs:
				miscs.UpdateTagIcons(viewDatas);
			// PORT-NOTE: C# switch 非穷尽（Index 页无标签图标）；Haxe 要求穷尽，补空 case。
			case AlmanacPageType.Index:
		}
	}
	public function UpdateContraptionDescriptionIcons(viewDatas:Array<AlmanacDescriptionTagViewData>):Void
	{
		standaloneContraptions.UpdateDescriptionIcons(viewDatas);
		mobileContraptions.UpdateDescriptionIcons(viewDatas);
	}
	public function UpdateEnemyDescriptionIcons(viewDatas:Array<AlmanacDescriptionTagViewData>):Void
	{
		enemies.UpdateDescriptionIcons(viewDatas);
	}
	public function UpdateArtifactDescriptionIcons(viewDatas:Array<AlmanacDescriptionTagViewData>):Void
	{
		artifacts.UpdateDescriptionIcons(viewDatas);
	}
	public function UpdateMiscDescriptionIcons(viewDatas:Array<AlmanacDescriptionTagViewData>):Void
	{
		miscs.UpdateDescriptionIcons(viewDatas);
	}

	// #region 缩放
	public function StartZoom():Void
	{
		zoomPage.Display();
	}
	public function StopZoom():Void
	{
		zoomPage.Hide();
	}
	public function SetZoomSprite(sprite:Sprite):Void
	{
		zoomPage.SetSprite(sprite);
	}
	public function SetZoomHintText(text:String):Void
	{
		zoomPage.SetZoomHintText(text);
	}
	public function SetZoomPageButtonsActive(active:Bool):Void
	{
		zoomPage.SetPageButtonActive(active);
	}
	// #endregion
	private function Awake():Void
	{
		almanacPages.set(AlmanacPageType.Index, indexUI);
		almanacPages.set(AlmanacPageType.ContraptionsStandalone, standaloneContraptions);
		almanacPages.set(AlmanacPageType.ContraptionsMobile, mobileContraptions);
		almanacPages.set(AlmanacPageType.Enemies, enemies);
		almanacPages.set(AlmanacPageType.Artifacts, artifacts);
		almanacPages.set(AlmanacPageType.Miscs, miscs);


		for (type in almanacPages.keys())
		{
			var capturedType = type;
			var page = almanacPages.get(type);
			if (Std.isOfType(page, IndexAlmanacPage))
			{
				var index:IndexAlmanacPage = cast page;
				index.OnButtonClick.add(t -> OnIndexButtonClick.dispatch(t));
				page.OnReturnClick.add(() -> OnReturnClick.dispatch(false));
			}
			else
			{
				page.OnReturnClick.add(() -> OnReturnClick.dispatch(true));
			}
			if (Std.isOfType(page, BookAlmanacPage))
			{
				var bookPage:BookAlmanacPage = cast page;
				bookPage.OnDescriptionIconEnter.add(id -> OnDescriptionIconEnter.dispatch(capturedType, id));
				bookPage.OnDescriptionIconExit.add(id -> OnDescriptionIconExit.dispatch(capturedType, id));
				bookPage.OnDescriptionIconDown.add(id -> OnDescriptionIconDown.dispatch(capturedType, id));
				bookPage.OnDescriptionLinkClick.add(id -> OnDescriptionLinkClick.dispatch(capturedType, id));
				bookPage.OnTagIconEnter.add(id -> OnTagIconEnter.dispatch(capturedType, id));
				bookPage.OnTagIconExit.add(id -> OnTagIconExit.dispatch(capturedType, id));
				bookPage.OnTagIconDown.add(id -> OnTagIconDown.dispatch(capturedType, id));
			}

			if (Std.isOfType(page, ContraptionAlmanacPage))
			{
				var contraptionPage:ContraptionAlmanacPage = cast page;
				contraptionPage.OnEntryClick.add((index, data) -> OnContraptionEntryClick.dispatch(index, data));
				contraptionPage.OnCommandBlockClick.add(data -> OnCommandBlockClick.dispatch(data));
			}

			if (Std.isOfType(page, MiscAlmanacPage))
			{
				var miscPage:MiscAlmanacPage = cast page;
				miscPage.OnGroupEntryClick.add((groupIndex, entryIndex) -> OnGroupEntryClick.dispatch(capturedType, groupIndex, entryIndex));
				miscPage.OnZoomClick.add(() -> OnZoomClick.dispatch(capturedType));
				miscPage.OnEntryClick.add(index -> OnMiscEntryClick.dispatch(capturedType, index));
			}
		}
		zoomPage.OnReturnClick.add(() -> OnZoomReturnClick.dispatch());
		zoomPage.OnPageButtonClick.add(v -> OnZoomPageButtonClick.dispatch(v));
	}
	public var OnReturnClick:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();
	public var OnIndexButtonClick:FlxTypedSignal<ButtonType->Void> = new FlxTypedSignal();

	public var OnCommandBlockClick:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnContraptionEntryClick:FlxTypedSignal<Int->PointerEventData->Void> = new FlxTypedSignal();
	public var OnMiscEntryClick:FlxTypedSignal<AlmanacPageType->Int->Void> = new FlxTypedSignal();
	public var OnGroupEntryClick:FlxTypedSignal<AlmanacPageType->Int->Int->Void> = new FlxTypedSignal();
	public var OnZoomClick:FlxTypedSignal<AlmanacPageType->Void> = new FlxTypedSignal();

	public var OnDescriptionIconEnter:FlxTypedSignal<AlmanacPageType->String->Void> = new FlxTypedSignal();
	public var OnDescriptionIconExit:FlxTypedSignal<AlmanacPageType->String->Void> = new FlxTypedSignal();
	public var OnDescriptionIconDown:FlxTypedSignal<AlmanacPageType->String->Void> = new FlxTypedSignal();
	public var OnDescriptionLinkClick:FlxTypedSignal<AlmanacPageType->String->Void> = new FlxTypedSignal();
	public var OnTagIconEnter:FlxTypedSignal<AlmanacPageType->Int->Void> = new FlxTypedSignal();
	public var OnTagIconExit:FlxTypedSignal<AlmanacPageType->Int->Void> = new FlxTypedSignal();
	public var OnTagIconDown:FlxTypedSignal<AlmanacPageType->Int->Void> = new FlxTypedSignal();

	public var OnZoomReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnZoomPageButtonClick:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();

	private var almanacPages:Map<AlmanacPageType, AlmanacPage> = new Map<AlmanacPageType, AlmanacPage>();

	@:serializeField
	private var indexUI:IndexAlmanacPage;
	@:serializeField
	private var standaloneContraptions:ContraptionAlmanacPage;
	@:serializeField
	private var mobileContraptions:ContraptionAlmanacPage;
	@:serializeField
	private var enemies:MiscAlmanacPage;
	@:serializeField
	private var artifacts:MiscAlmanacPage;
	@:serializeField
	private var miscs:MiscAlmanacPage;
	@:serializeField
	private var zoomPage:AlmanacZoomPage;
}

enum abstract AlmanacPageType(Int)
{
	var Index = 0;
	var ContraptionsStandalone = 1;
	var ContraptionsMobile = 2;
	var Enemies = 3;
	var Artifacts = 4;
	var Miscs = 5;
}
