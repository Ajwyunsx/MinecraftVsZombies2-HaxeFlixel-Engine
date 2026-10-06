// Ported from: Assets/Scripts/MVZ2/Models/Components/ShaderPropertySetters/FireTimeRunner.cs
package mvz2.models;
using pvzengine.models.HasModelExt;  // EXTUSING

class FireTimeRunner extends ShaderPropertySetter<Float> {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        fireTime += deltaTime;
        super.UpdateFrame(deltaTime);
    }
    override public function SetProperty(value:Float):Void {
        Element.SetFloat("_FireTime", value);
        Element.ApplyShaderProperties();
    }
    override public function GetDefaultValue():Float return 0;
    override public function GetCurrentValue():Float return fireTime;
    private var fireTime:Float = 0;

}
