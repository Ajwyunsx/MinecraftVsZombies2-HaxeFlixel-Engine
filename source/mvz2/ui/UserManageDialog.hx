// Ported from: Assets/Scripts/View/Dialogs/UserManageDialog.cs
package mvz2.ui;

import mvz2.ui.UserManageList;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.ui.Button;
import mvz2.ui.UserManageList.UserNameItemViewData;
import flixel.util.FlxSignal;

class UserManageDialog extends Dialog
{
	public function UpdateUsers(names:Array<UserNameItemViewData>):Void
	{
		userList.UpdateUsers(names);
	}
	public function SelectUser(index:Int):Void
	{
		userList.SelectUser(index);
	}
	public function SetCreateNewUserActive(active:Bool):Void
	{
		userList.SetCreateNewUserActive(active);
	}
	public function SetButtonInteractable(type:UserManageButtonType, interactable:Bool):Void
	{
		if (buttonDict.exists(type))
		{
			var button = buttonDict.get(type);
			button.interactable = interactable;
		}
	}
	private function Awake():Void
	{
		buttonDict.set(UserManageButtonType.Rename, renameButton);
		buttonDict.set(UserManageButtonType.Delete, deleteButton);
		buttonDict.set(UserManageButtonType.Switch, switchButton);
		buttonDict.set(UserManageButtonType.Back, backButton);
		buttonDict.set(UserManageButtonType.Import, importButton);
		buttonDict.set(UserManageButtonType.Export, exportButton);

		for (type in buttonDict.keys())
		{
			var capturedType = type;
			buttonDict.get(type).onClick.AddListener(() -> OnButtonClick.dispatch(capturedType));
		}

		userList.OnUserSelect.add(index -> OnUserSelect.dispatch(index));
		userList.OnCreateNewUserButtonClick.add(() -> OnCreateNewUserButtonClick.dispatch());
	}
	public var OnUserSelect:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnCreateNewUserButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnButtonClick:FlxTypedSignal<UserManageButtonType->Void> = new FlxTypedSignal();

	private var buttonDict:Map<UserManageButtonType, Button> = new Map<UserManageButtonType, Button>();

	@:serializeField
	private var userList:UserManageList;
	@:serializeField
	private var renameButton:Button;
	@:serializeField
	private var deleteButton:Button;
	@:serializeField
	private var switchButton:Button;
	@:serializeField
	private var backButton:Button;
	@:serializeField
	private var importButton:Button;
	@:serializeField
	private var exportButton:Button;
}

// PORT-NOTE: C# UserManageDialog.UserManageButtonType -> UserManageButtonType
// (mvz2.ui.OptionsDialogMainPage also declares a top-level ButtonType; Haxe forbids two
//  same-named types in one package, so this one is qualified by its module name)
enum abstract UserManageButtonType(Int)
{
	var Rename = 0;
	var Delete = 1;
	var Switch = 2;
	var Back = 3;
	var Import = 4;
	var Export = 5;
}
