package mvz2.scenes;

import unity.MonoBehaviour;

// Ported from: Assets/Scripts/MVZ2/Scene/ScenePage.cs
class ScenePage extends MonoBehaviour {
    public function Display():Void {
        gameObject.SetActive(true);
    }
    public function Hide():Void {
        gameObject.SetActive(false);
    }
}
