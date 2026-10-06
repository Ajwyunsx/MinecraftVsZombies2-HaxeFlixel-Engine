package mvz2.scenes;

import unity.Animator;
import unity.tmpro.TextMeshProUGUI;

// Ported from: Assets/Scripts/MVZ2/Scene/PopupController.cs
class PopupController extends ScenePage {
    public function ShowPopup(text:String):Void {
        animator.SetTrigger("Show");
        popupText.text = text;
    }
    @:serializeField
    private var animator:Animator = null;
    @:serializeField
    private var popupText:TextMeshProUGUI = null;
}
