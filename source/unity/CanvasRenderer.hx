package unity;

// Minimal UnityEngine.CanvasRenderer shim.
class CanvasRenderer extends Component {
    public var hasPopInstruction:Bool = false;
    public var materialCount:Int = 1;
    public var hasMoved:Bool = false;
    public var cull:Bool = false;
    public var absoluteDepth:Int = 0;
    public var hasRectClipping:Bool = false;
    public var relativeDepth:Int = 0;
    public var hasCull:Bool = false;

    public function new() {
        super();
    }

    public function SetColor(color:Color):Void {}
    public function GetColor():Color return new Color(1, 1, 1, 1);
    public function SetAlpha(alpha:Float):Void {}
    public function GetAlpha():Float return 1;
    public function SetMaterial(material:Material, index:Int):Void {}
    public function GetMaterial(?index:Int = 0):Material return null;
    public function SetTexture(texture:Texture):Void {}
    public function Clear():Void {}
}
