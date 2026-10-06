// Ported from: Assets/Scripts/MVZ2/Models/Components/ShaderPropertySetters/ColorOffsetSetter.cs
package mvz2.models;

import mvz2logic.models.SortingLayers.ShaderProperties;
import unity.Color;
using pvzengine.models.HasModelExt;  // EXTUSING

// [ExecuteAlways]
class ColorOffsetSetter extends ShaderPropertySetter<Color> {
    public function new() {
        super();
    }

    override public function GetCurrentValue():Color return color;
    override public function GetDefaultValue():Color return Color.clear;
    override public function SetProperty(value:Color):Void {
        Element.SetColor(ShaderProperties.COLOR_OFFSET, value);
        Element.ApplyShaderProperties();
    }
    public var color:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用
}
