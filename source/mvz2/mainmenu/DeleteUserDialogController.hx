package mvz2.mainmenu;

import mvz2.managers.MainManager;
import mvz2.saves.UserDataItem;
import mvz2.ui.DeleteUserDialog;
import mvz2.ui.UserManageList;
import mvz2logic.localization.LogicStrings;
import unity.Color;
import unity.MonoBehaviour;
import unity.Task;
import unity.TaskCompletionSource;
import mvz2.localization.LanguageManager;
import mvz2.saves.SaveManager;
import mvz2.ui.UserManageList.UserNameItemViewData;
import unity.scenemanagement.SceneInstance.Scene;

// Ported from: Assets/Scripts/MVZ2/Scene/DeleteUserDialogController.cs
class DeleteUserDialogController extends MonoBehaviour {
    public function Show(users:Array<UserDataItem>):Task {
        ui.ResetPosition();
        gameObject.SetActive(true);
        if (tcs != null)
            return tcs.task;

        var i = 0;
        var userIndexList:Array<Int> = [];
        var viewDatas:Array<UserNameItemViewData> = [];
        for (user in users) {
            if (user != null) {
                userIndexList.push(i);
                var viewData = new UserNameItemViewData({
                    name: user.Username != null ? user.Username : "",
                    color: Color.black
                });
                viewDatas.push(viewData);
            }
            i++;
        }
        managingUserIndexes = Lambda.array(userIndexList);
        selectedUserArrayIndex = 0;
        ui.UpdateUsers(viewDatas);
        ui.SelectUser(selectedUserArrayIndex);

        tcs = new TaskCompletionSource();
        return tcs.task;
    }
    private function Hide():Void {
        gameObject.SetActive(false);
        selectedUserArrayIndex = -1;
        if (tcs == null)
            return;
        tcs.TrySetResult(-1);
        tcs = null;
    }
    private function Awake():Void {
        ui.OnUserSelect.add(OnUserSelectCallback);
        ui.OnDeleteButtonClick.add(OnDeleteButtonClickCallback);
    }
    private function OnUserSelectCallback(index:Int):Void {
        selectedUserArrayIndex = index;
        ui.SetDeleteButtonInteractable(index >= 0);
    }
    // PORT-NOTE: C# `async void` → Void; the awaited dialog result is read without blocking.
    private function OnDeleteButtonClickCallback():Void {
        var userIndex = GetSelectedUserIndex();
        var title = main.LanguageManager._(LogicStrings.WARNING);
        var desc = main.LanguageManager._(LogicStrings.WARNING_DELETE_USER, [main.SaveManager.GetUserName(userIndex)]);
        var result:Bool = main.Scene.ShowDialogSelectAsync(title, desc).awaitResult();
        if (result) {
            main.SaveManager.DeleteUser(userIndex);
            main.SaveManager.SaveUserList();
            if (tcs != null) tcs.SetResult(userIndex);
            Hide();
        }
    }
    private function GetSelectedUserIndex():Int {
        return managingUserIndexes[selectedUserArrayIndex];
    }
    private var main(get, never):MainManager;
    inline function get_main():MainManager return MainManager.Instance;

    @:serializeField
    private var ui:DeleteUserDialog = null;
    private var selectedUserArrayIndex:Int;
    private var managingUserIndexes:Array<Int> = null;
    private var tcs:TaskCompletionSource;
}
