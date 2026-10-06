// Ported from: Assets/Scripts/MVZ2/Models/Components/ShaderPropertySetters/LocalSpriteRectSetter.cs
package mvz2.models;

import mvz2logic.models.SortingLayers.ShaderProperties;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.Vector4;
using pvzengine.models.HasModelExt;  // EXTUSING

// [ExecuteAlways]
class LocalSpriteRectSetter extends ShaderPropertySetter<Vector4> {
    public function new() {
        super();
    }

    override public function GetCurrentValue():Vector4 {
        if (!Std.isOfType(Element.Renderer, SpriteRenderer))
            return defaultValue;
        var sprRenderer:SpriteRenderer = cast Element.Renderer;
        var sprite = sprRenderer.sprite;
        if (sprite == null)
            return defaultValue;
        if (lastSprite != sprite) {
            lastSprite = sprite;
            // PORT-NOTE: unity.Sprite shim 以 rect 表示 textureRect（贴图内的像素区域）。
            var textureRect = sprite.rect;
            var texture = sprite.texture;
            currentValue = new Vector4(
                textureRect.xMin / texture.width,
                textureRect.yMin / texture.height,
                textureRect.xMax / texture.width,
                textureRect.yMax / texture.height);
        }
        return currentValue;
    }
    override public function GetDefaultValue():Vector4 return defaultValue;
    override public function SetProperty(value:Vector4):Void {
        Element.SetVector(ShaderProperties.LOCAL_RECT, value);
        Element.ApplyShaderProperties();
    }
    private var lastSprite:Sprite;
    private var currentValue:Vector4 = new Vector4(0, 0, 0, 0); // PORT-NOTE: C# Vector4 为 struct，默认 (0,0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var defaultValue:Vector4 = new Vector4(0, 0, 1, 1);
}
