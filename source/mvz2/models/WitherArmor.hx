// Ported from: Assets/Scripts/MVZ2/Models/Components/ShaderPropertySetters/WitherArmor.cs
package mvz2.models;

import mvz2logic.models.SortingLayers.ShaderProperties;
import unity.Vector2;
import unity.Vector4;
using pvzengine.models.HasModelExt;  // EXTUSING

// [ExecuteAlways]
class WitherArmor extends ShaderPropertySetter<Vector4> {
    public function new() {
        super();
    }

    override public function SetProperty(value:Vector4):Void {
        Element.SetVector(ShaderProperties.MAIN_TEX_ST, value);
        Element.ApplyShaderProperties();
    }
    override public function GetDefaultValue():Vector4 return new Vector4(1, 1, 0, 0);
    override public function GetCurrentValue():Vector4 {
        var offset:Vector2 = Model.GetProperty("Offset");
        return new Vector4(1, 1, offset.x, offset.y);
    }
}
