package mvz2.chaptertransition;

import unity.MaterialPropertyBlock;
import unity.MonoBehaviour;
import unity.SpriteRenderer;

// Ported from: Assets/Scripts/MVZ2/ChapterTransition/ChapterTransitionBlurer.cs
@:executeAlways
class ChapterTransitionBlurer extends MonoBehaviour {
    private function Update():Void {
        SetTitleBlur(titleBlur);
    }
    public function SetTitleBlur(blur:Float):Void {
        propertyBlock.Clear();
        titleRenderer.GetPropertyBlock(propertyBlock);
        propertyBlock.SetFloat("_Blur", blur);
        titleRenderer.SetPropertyBlock(propertyBlock);
    }
    private var propertyBlock(get, never):MaterialPropertyBlock;
    function get_propertyBlock():MaterialPropertyBlock {
        if (_propertyBlock == null)
            _propertyBlock = new MaterialPropertyBlock();
        return _propertyBlock;
    }
    private var _propertyBlock:MaterialPropertyBlock;

    @:serializeField
    private var titleRenderer:SpriteRenderer = null;
    @:serializeField
    @:range(0, 1)
    private var titleBlur:Float;
}
