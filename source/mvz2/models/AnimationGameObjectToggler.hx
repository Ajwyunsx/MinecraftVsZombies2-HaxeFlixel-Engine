// Ported from: Assets/Scripts/MVZ2/Models/Components/Animation/AnimationGameObjectToggler.cs
package mvz2.models;

import tools.ObjectExtensions;
import unity.GameObject;

// [ExecuteAlways]
class AnimationGameObjectToggler extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    private function Update():Void {
        UpdateEnable();
    }
    public function UpdateEnable():Void {
        if (gameObjectA.Exists())
            gameObjectA.SetActive(enableB < 0.99);
        if (gameObjectB.Exists())
            gameObjectB.SetActive(enableB >= 0.99);
    }
    private var enableB:Float;
    private var gameObjectA:GameObject;
    private var gameObjectB:GameObject;
}
