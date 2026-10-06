// Ported from: Assets/Scripts/View/Mainmenu/MainmenuUI.cs
package mvz2.ui.mainmenu;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.OptionsDialog;
import mvz2.ui.UserManageDialog;
import mvz2.ui.UserManageList;
import mvz2.ui.mainmenu.AchievementsUI;
import mvz2.ui.mainmenu.StatsUI;
import unity.Color;
import unity.GameObject;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.tmpro.TextMeshPro;
import mvz2.ui.mainmenu.AchievementEntryUI;
import mvz2.gamecontent.artifacts.Almanac;
import mvz2.gamecontent.commands.Help;
import unity.MonoBehaviour;
import mvz2.options.Options;
import mvz2.ui.UserManageDialog.UserManageButtonType;
import mvz2.ui.UserManageList.UserNameItemViewData;
import mvz2.ui.mainmenu.AchievementEntryUI.AchievementEntryViewData;
import mvz2.ui.mainmenu.StatsUI.StatsViewData;
import flixel.util.FlxSignal;
import flixel.system.debug.stats.Stats;

class MainmenuUI extends unity.MonoBehaviour
{
	public function SetVersion(name:String):Void
	{
		versionText.text = name;
	}
	public function SetUserName(name:String):Void
	{
		userNameText.text = name;
		userNameGoldText.text = name;
	}
	public function SetUserNameColor(color:Color):Void
	{
		userNameText.color = color;
	}
	public function SetUserNameGold(gold:Bool):Void
	{
		userNameText.gameObject.SetActive(!gold);
		userNameGoldText.gameObject.SetActive(gold);
	}
	public function SetOptionsDialogVisible(visible:Bool):Void
	{
		optionsDialog.gameObject.SetActive(visible);
		optionsDialog.ResetPosition();
	}
	public function SetUserManageDialogVisible(visible:Bool):Void
	{
		userManageDialog.gameObject.SetActive(visible);
	}
	public function UpdateUserManageDialog(names:Array<UserNameItemViewData>, selectedIndex:Int):Void
	{
		userManageDialog.UpdateUsers(names);
		userManageDialog.ResetPosition();
		userManageDialog.SelectUser(selectedIndex);
	}
	public function SetUserManageButtonInteractable(type:UserManageButtonType, interactable:Bool):Void
	{
		userManageDialog.SetButtonInteractable(type, interactable);
	}
	public function SetUserManageCreateNewUserActive(active:Bool):Void
	{
		userManageDialog.SetCreateNewUserActive(active);
	}
	public function SetWindowViewSprite(sprite:Null<Sprite>):Void
	{
		windowViewSpriteRenderer.sprite = sprite;
	}
	public function SetBackgroundDark(dark:Bool):Void
	{
		// PORT-NOTE: C# 为 `backgroundLight.gameObject.SetActive(...)`。GameObject.gameObject 是返回自身的
		// 自引用属性，unity shim 的 GameObject 未定义该属性，故直接作用于对象本身（语义等价）。
		backgroundLight.SetActive(!dark);
		backgroundDark.SetActive(dark);
	}
	public function SetButtonActive(type:MainmenuButtonType, active:Bool):Void
	{
		if (mainmenuButtonDict.exists(type))
		{
			var button = mainmenuButtonDict.get(type);
			button.gameObject.SetActive(active);
		}
	}
	public function SetRayblockerActive(active:Bool):Void
	{
		rayblocker.SetActive(active);
	}
	public function UpdateStats(viewData:StatsViewData):Void
	{
		stats.UpdateStats(viewData);
	}
	public function UpdateAchievements(viewDatas:Array<AchievementEntryViewData>):Void
	{
		achievements.UpdateAchievements(viewDatas);
	}
	public function GetAllButtons():Iterable<MainmenuButton>
	{
		var result:Array<MainmenuButton> = [];
		for (button in mainmenuButtonDict)
		{
			result.push(button);
		}
		return result;
	}
	private function Awake():Void
	{
		mainmenuButtonDict.set(MainmenuButtonType.Adventure, adventureButton);
		mainmenuButtonDict.set(MainmenuButtonType.Options, optionsButton);
		mainmenuButtonDict.set(MainmenuButtonType.Help, helpButton);
		mainmenuButtonDict.set(MainmenuButtonType.UserManage, userManageButton);
		mainmenuButtonDict.set(MainmenuButtonType.Quit, quitButton);
		mainmenuButtonDict.set(MainmenuButtonType.Almanac, almanacButton);
		mainmenuButtonDict.set(MainmenuButtonType.Store, storeButton);
		mainmenuButtonDict.set(MainmenuButtonType.MoreMenu, moreMenuButton);
		mainmenuButtonDict.set(MainmenuButtonType.BackToMenu, backToMenuButton);
		mainmenuButtonDict.set(MainmenuButtonType.Archive, archiveButton);
		mainmenuButtonDict.set(MainmenuButtonType.Addons, addonsButton);
		mainmenuButtonDict.set(MainmenuButtonType.Stats, statsButton);
		mainmenuButtonDict.set(MainmenuButtonType.Achievement, achievementButton);
		mainmenuButtonDict.set(MainmenuButtonType.MusicRoom, musicRoomButton);
		mainmenuButtonDict.set(MainmenuButtonType.Arcade, arcadeButton);

		for (type in mainmenuButtonDict.keys())
		{
			var capturedType = type;
			var button = mainmenuButtonDict.get(type);
			button.OnUpdateSprite.add(b -> OnMainmenuButtonUpdateSprite.dispatch(capturedType, b));
			button.OnClick.add(() -> OnMainmenuButtonClick.dispatch(capturedType));
		}

		userManageDialog.OnCreateNewUserButtonClick.add(() -> OnUserManageDialogCreateNewUserButtonClick.dispatch());
		userManageDialog.OnButtonClick.add(type -> OnUserManageDialogButtonClick.dispatch(type));
		userManageDialog.OnUserSelect.add(index -> OnUserManageDialogUserSelect.dispatch(index));

		stats.OnReturnClick.add(() -> OnStatsReturnButtonClick.dispatch());
		achievements.OnReturnClick.add(() -> OnAchievementsReturnButtonClick.dispatch());
	}
	public var OnMainmenuButtonClick:FlxTypedSignal<MainmenuButtonType->Void> = new FlxTypedSignal();
	public var OnMainmenuButtonUpdateSprite:FlxTypedSignal<MainmenuButtonType->MainmenuButton->Void> = new FlxTypedSignal();
	public var OnUserManageDialogCreateNewUserButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnUserManageDialogButtonClick:FlxTypedSignal<UserManageButtonType->Void> = new FlxTypedSignal();
	public var OnUserManageDialogUserSelect:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnStatsReturnButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnAchievementsReturnButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();


	public var OptionsDialog(get, never):OptionsDialog;
	function get_OptionsDialog():OptionsDialog return optionsDialog;
	private var mainmenuButtonDict:Map<MainmenuButtonType, MainmenuButton> = new Map<MainmenuButtonType, MainmenuButton>();

	@:serializeField
	private var rayblocker:GameObject;
	@:serializeField
	private var stats:StatsUI;
	@:serializeField
	private var achievements:AchievementsUI;

	// [Header("Backgrounds")]
	@:serializeField
	private var backgroundLight:GameObject;
	@:serializeField
	private var backgroundDark:GameObject;
	@:serializeField
	private var userNameText:TextMeshPro;
	@:serializeField
	private var userNameGoldText:TextMeshPro;
	@:serializeField
	private var versionText:TextMeshPro;
	@:serializeField
	private var windowViewSpriteRenderer:SpriteRenderer;

	// [Header("Dialogs")]
	@:serializeField
	private var optionsDialog:OptionsDialog;
	@:serializeField
	private var userManageDialog:UserManageDialog;

	// [Header("Buttons")]
	@:serializeField
	private var adventureButton:MainmenuButton;
	@:serializeField
	private var optionsButton:MainmenuButton;
	@:serializeField
	private var helpButton:MainmenuButton;
	@:serializeField
	private var userManageButton:MainmenuButton;
	@:serializeField
	private var quitButton:MainmenuButton;
	@:serializeField
	private var almanacButton:MainmenuButton;
	@:serializeField
	private var storeButton:MainmenuButton;
	@:serializeField
	private var moreMenuButton:MainmenuButton;
	@:serializeField
	private var backToMenuButton:MainmenuButton;
	@:serializeField
	private var archiveButton:MainmenuButton;
	@:serializeField
	private var addonsButton:MainmenuButton;
	@:serializeField
	private var statsButton:MainmenuButton;
	@:serializeField
	private var achievementButton:MainmenuButton;
	@:serializeField
	private var musicRoomButton:MainmenuButton;
	@:serializeField
	private var arcadeButton:MainmenuButton;
}

enum abstract MainmenuButtonType(Int)
{
	var Adventure = 0;
	var Options = 1;
	var Help = 2;
	var UserManage = 3;
	var Quit = 4;
	var Almanac = 5;
	var Store = 6;
	var MoreMenu = 7;
	var BackToMenu = 8;
	var Archive = 9;
	var Stats = 10;
	var Achievement = 11;
	var Addons = 12;
	var MusicRoom = 13;
	var Arcade = 14;
}
