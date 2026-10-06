// Ported from: Assets/Scripts/View/Dialogs/DeleteUserDialog.cs
package mvz2.ui;

import mvz2.ui.UserManageList;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.ui.Button;
import mvz2.ui.UserManageList.UserNameItemViewData;
import flixel.util.FlxSignal;

class DeleteUserDialog extends Dialog
{
	public function UpdateUsers(names:Array<UserNameItemViewData>):Void
	{
		userList.UpdateUsers(names);
	}
	public function SelectUser(index:Int):Void
	{
		userList.SelectUser(index);
	}
	public function SetDeleteButtonInteractable(interactable:Bool):Void
	{
		deleteButton.interactable = interactable;
	}
	private function Awake():Void
	{
		deleteButton.onClick.AddListener(() -> OnDeleteButtonClick.dispatch());
		userList.OnUserSelect.add(index -> OnUserSelect.dispatch(index));
		userList.SetCreateNewUserActive(false);
	}
	public var OnUserSelect:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnDeleteButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();

	@:serializeField
	private var userList:UserManageList;
	@:serializeField
	private var deleteButton:Button;
}
