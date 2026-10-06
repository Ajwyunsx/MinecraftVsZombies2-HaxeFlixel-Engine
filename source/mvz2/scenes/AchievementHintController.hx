package mvz2.scenes;

import mvz2.managers.MainManager;
import mvz2.ui.scene.AchievementHint;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;
import unity.MonoBehaviour;
import unity.Sprite;
import unity.Time;
import mvz2.localization.LanguageManager;
import mvz2.managers.ResourceManager;

// Ported from: Assets/Scripts/MVZ2/Scene/AchievementHintController.cs
class AchievementHintController extends MonoBehaviour {
    public function Show(achievements:Array<NamespaceID>):Void {
        for (achievement in achievements) {
            achievementEarnQueue.push(achievement);
        }
    }
    private function Awake():Void {
        if (ui != null)
            ui.OnClick.add(() -> showTimeout = 0);
    }
    private function Update():Void {
        if (showBlend <= 0.001 && achievementEarnQueue.length > 0) {
            var achievement = achievementEarnQueue.shift();
            var meta = main.ResourceManager.GetAchievementMeta(achievement);
            var icon:Sprite = null;
            var name = "???";
            if (meta != null) {
                name = main.LanguageManager._p(LogicStrings.CONTEXT_ACHIEVEMENT, meta.Name != null ? meta.Name : "");
                // PORT-NOTE: C# 重载 GetFinalSprite(SpriteReference?) 在移植层名为 GetFinalSpriteFromRef。
                icon = main.GetFinalSpriteFromRef(meta.Icon);
            }
            if (ui != null)
                ui.UpdateAchievement(icon, name);
            showTimeout = maxShowTimeout;
        }
        if (showTimeout > 0) {
            showTimeout -= Time.deltaTime;
            showBlend = showBlend * (1 - showSpeed) + 1 * showSpeed;
        } else {
            showBlend = showBlend * (1 - showSpeed);
        }
        if (ui != null) {
            ui.SetShowValue(showBlend);
            ui.SetVisible(showBlend > 0.01);
        }
    }
    private var main(get, never):MainManager;
    inline function get_main():MainManager return MainManager.Instance;

    @:serializeField
    private var ui:AchievementHint;
    @:serializeField
    private var maxShowTimeout:Float = 5;
    @:serializeField
    private var showSpeed:Float = 0.25;
    private var showTimeout:Float = 0;
    // PORT-NOTE: C# `Queue<NamespaceID>` → Array (push/shift).
    private var achievementEarnQueue:Array<NamespaceID> = [];
    private var showBlend:Float = 0;
}
