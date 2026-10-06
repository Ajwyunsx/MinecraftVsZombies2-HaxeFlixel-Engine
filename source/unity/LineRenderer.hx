package unity;

// Minimal UnityEngine.LineRenderer shim.
class LineRenderer extends Component {
    public var positionCount:Int = 0;
    public var useWorldSpace:Bool = true;
    public var widthMultiplier:Float = 1;
    public var startWidth:Float = 1;
    public var endWidth:Float = 1;
    public var startColor:Color = new Color(1, 1, 1, 1);
    public var endColor:Color = new Color(1, 1, 1, 1);
    public var material:Material;
    public var enabled:Bool = true;

    // PORT-NOTE: 线段顶点数据保存在该数组中，渲染由 Flixel 渲染层后续接管。
    public var positions:Array<Vector3> = [];

    public function new() {
        super();
    }

    public function SetPositions(values:Array<Vector3>):Void {
        positions = values.copy();
        positionCount = positions.length;
    }
    public function GetPositions(result:Array<Vector3>):Void {
        for (i in 0...result.length) {
            result[i] = i < positions.length ? positions[i] : new Vector3();
        }
    }
    public function SetPosition(index:Int, position:Vector3):Void {
        while (positions.length <= index) positions.push(new Vector3());
        positions[index] = position;
        if (positionCount <= index) positionCount = index + 1;
    }
    public function GetPosition(index:Int):Vector3 {
        return index >= 0 && index < positions.length ? positions[index] : new Vector3();
    }
}
