// Ported from: Assets/Scripts/View/Dialogs/UserManageList.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementListUI;
import unity.Color;
import unity.GameObject;
import unity.RectTransform;
import unity.ui.Button;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class UserManageList extends unity.MonoBehaviour
{
	public function UpdateUsers(names:Array<UserNameItemViewData>):Void
	{
		userList.updateList(names.length,
			function(i:Int, rect:RectTransform)
			{
				var item = rect.GetComponent(UserManageItem);
				var viewData = names[i];
				item.SetName(viewData.name);
				item.SetColor(viewData.color);
			},
			function(rect:RectTransform)
			{
				var item = rect.GetComponent(UserManageItem);
				item.OnValueChanged.add(OnItemValueChangedCallback);
			},
			function(rect:RectTransform)
			{
				var item = rect.GetComponent(UserManageItem);
				item.OnValueChanged.remove(OnItemValueChangedCallback);
			});
	}
	public function SelectUser(index:Int):Void
	{
		for (user in userList.getElementsAs(UserManageItem))
		{
			var i = userList.indexOfComponent(user);
			user.SetIsOn(i == index);
		}
	}
	public function SetCreateNewUserActive(active:Bool):Void
	{
		createNewUserButton.gameObject.SetActive(active);
	}
	private function Awake():Void
	{
		createNewUserButton.onClick.AddListener(() -> OnCreateNewUserButtonClick.dispatch());
	}
	private function OnItemValueChangedCallback(item:UserManageItem, value:Bool):Void
	{
		if (value)
			OnUserSelect.dispatch(userList.indexOfComponent(item));
	}
	public var OnUserSelect:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnCreateNewUserButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();

	@:serializeField
	private var userList:ElementListUI;
	@:serializeField
	private var createNewUserButton:Button;
}

// C# 中为 MVZ2.UI 的 UserNameItemViewData 结构体。
class UserNameItemViewData
{
	public var name:String;
	public var color:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用

	// PORT-NOTE: C# 结构体初始化器 `new UserNameItemViewData { field = value }` 在 Haxe 中写作 `new UserNameItemViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new UserNameItemViewData()`。
	public function new(?data:{?name:String, ?color:Color})
	{
		if (data == null)
			return;
		if (data.name != null) name = data.name;
		if (data.color != null) color = data.color;
	}
}
