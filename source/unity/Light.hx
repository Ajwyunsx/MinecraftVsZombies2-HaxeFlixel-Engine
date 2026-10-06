package unity;

// Minimal UnityEngine.Light shim (2D 用途下仅保留颜色/强度/范围)。
class Light extends Component {
    public var color:Color = new Color(1, 1, 1, 1);
    public var intensity:Float = 1;
    public var range:Float = 10;
    public var spotAngle:Float = 30;
    public var type:LightType = LightType.Point;
    public var shadowsHard:Int = 0;
    public var enabled:Bool = true;

    public function new() {
        super();
    }
}

// Minimal UnityEngine.LightType shim.
enum abstract LightType(Int) {
    var Spot = 0;
    var Directional = 1;
    var Point = 2;
    var Area = 3;
}
