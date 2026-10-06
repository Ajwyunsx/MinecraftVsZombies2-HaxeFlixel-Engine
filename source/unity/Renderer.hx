package unity;

// Minimal UnityEngine.Renderer shim.
class Renderer extends Component {
    public var enabled:Bool = true;
    public var material:Material;
    public var sharedMaterial:Material;
    public var materials:Array<Material> = [];
    public var sharedMaterials:Array<Material> = [];
    public var sortingLayerID:Int = 0;
    public var sortingLayerName:String = "Default";
    public var sortingOrder:Int = 0;
    public var bounds:Bounds = new Bounds();
    public var isVisible:Bool = true;

    public function new() {
        super();
    }

    public function GetPropertyBlock(block:MaterialPropertyBlock):Void {}
    public function SetPropertyBlock(block:MaterialPropertyBlock):Void {}
}
