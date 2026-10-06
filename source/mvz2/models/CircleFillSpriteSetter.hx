// Ported from: Assets/Scripts/MVZ2/Models/Components/ShaderPropertySetters/CircleFillSpriteSetter.cs
package mvz2.models;
using pvzengine.models.HasModelExt;  // EXTUSING

// [ExecuteAlways]
class CircleFillSpriteSetter extends ShaderPropertySetter<Float> {
    public function new() {
        super();
    }

    override public function GetCurrentValue():Float return fill;
    override public function GetDefaultValue():Float return 0;
    override public function SetProperty(value:Float):Void {
        Element.SetFloat("_CircleFill", value);
        Element.ApplyShaderProperties();
    }
    // [Range(0, 1)]
    public var fill:Float;
}
