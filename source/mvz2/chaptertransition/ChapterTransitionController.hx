package mvz2.chaptertransition;

import mvz2.managers.MainManager;
import mvz2.metas.ChapterTransitionMeta;
import pvzengine.NamespaceID;
import unity.Animator;
import unity.MonoBehaviour;
import unity.Task;
import unity.TaskCompletionSource;

// Ported from: Assets/Scripts/MVZ2/ChapterTransition/ChapterTransitionController.cs
class ChapterTransitionController extends MonoBehaviour {
    public function Display(id:NamespaceID, end:Bool):Void {
        gameObject.SetActive(true);
        var meta = Main.ResourceManager.GetChapterTransitionMeta(id);
        if (meta == null)
            return;
        animator.SetInteger("Mode", end ? ChapterTransitionMeta.MODE_END : meta.Mode);
        ui.SetWheelRootRotation(meta.Angle);
        // PORT-NOTE: C# 的 Main.GetFinalSprite(SpriteReference?) 重载在移植层改名为 GetFinalSpriteFromRef
        // （Haxe 不支持重载，见 mvz2.managers.MainManager）。
        ui.SetTitleSprite(Main.GetFinalSpriteFromRef(meta.TextSprite));
    }
    // PORT-NOTE: C# `async Task DisplayAsync` awaited a TaskCompletionSource; Haxe has no
    // async/await, so the Task is returned and callers poll/wait on it.
    public function DisplayAsync(id:NamespaceID, end:Bool):Task {
        tcs = new TaskCompletionSource();
        Display(id, end);
        // TODO-PORT: awaiting tcs.task requires coroutine restructuring at the call site.
        return tcs.task;
    }
    public function Hide():Void {
        gameObject.SetActive(false);
    }
    public function CallEnd():Void {
        if (tcs != null) tcs.SetResult(true);
    }
    private var tcs:TaskCompletionSource;

    private var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    @:serializeField
    private var animator:Animator = null;
    @:serializeField
    private var ui:ChapterTransition = null;
}
