package mvz2.scenes;

import mvz2.managers.MainManager;
import unity.scenemanagement.SceneInstance.Scene;

// Ported from: Assets/Scripts/MVZ2/Scene/SplashController.cs
class SplashController extends ScenePage {
    public function EnterTitleScreen():Void {
        MainManager.Instance.Scene.DisplayTitlescreen();
    }
}
