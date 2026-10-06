package mvz2.chaptertransition;

import unity.MonoBehaviour;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.Transform;
import unity.Vector3;

// Ported from: Assets/Scripts/MVZ2/ChapterTransition/ChapterTransition.cs
class ChapterTransition extends MonoBehaviour {
    public function SetWheelRootRotation(rotation:Float):Void {
        wheelRoot.eulerAngles = new Vector3(0, 0, rotation);
    }
    public function SetTitleSprite(sprite:Sprite):Void {
        titleRenderer.sprite = sprite;
    }

    @:serializeField
    private var wheelRoot:Transform = null;
    @:serializeField
    private var titleRenderer:SpriteRenderer = null;
}
