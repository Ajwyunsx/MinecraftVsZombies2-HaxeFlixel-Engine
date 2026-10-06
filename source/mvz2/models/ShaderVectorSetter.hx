// Ported from: Assets/Scripts/MVZ2/Models/Components/ShaderPropertySetters/ShaderVectorSetter.cs
package mvz2.models;

import unity.Vector4;
using pvzengine.models.HasModelExt;  // EXTUSING

// [ExecuteAlways]
class ShaderVectorSetter extends ShaderPropertySetter<Vector4> {
    public function new() {
        super();
    }

    override public function GetCurrentValue():Vector4 return value;
    override public function GetDefaultValue():Vector4 return Vector4.zero;
    override public function SetProperty(value:Vector4):Void {
        if (propertyName == null || propertyName.length == 0)
            return;
        Element.SetVector(propertyName, value);
        Element.ApplyShaderProperties();
    }
    public var propertyName:String;
    public var value:Vector4 = new Vector4(0, 0, 0, 0); // PORT-NOTE: C# Vector4 为 struct，默认 (0,0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
