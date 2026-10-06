// Ported from: Assets/Scripts/MVZ2/Models/Components/ShaderPropertySetters/HSVOffsetSetter.cs
package mvz2.models;

import mvz2logic.models.SortingLayers.ShaderProperties;
import unity.Vector4;
using pvzengine.models.HasModelExt;  // EXTUSING

// [ExecuteAlways]
class HSVOffsetSetter extends ShaderPropertySetter<Vector4> {
    public function new() {
        super();
    }

    override public function GetCurrentValue():Vector4 return new Vector4(hue, saturation, value, 0);
    override public function GetDefaultValue():Vector4 return Vector4.zero;
    override public function SetProperty(value:Vector4):Void {
        Element.SetVector(ShaderProperties.HSV_OFFSET, value);
        Element.ApplyShaderProperties();
    }
    // [Range(-180, 180)]
    public var hue:Float;
    // [Range(-100, 100)]
    public var saturation:Float;
    // [Range(-100, 100)]
    public var value:Float;
}
