package unity;

// Minimal UnityEngine.CapsuleCollider shim.
class CapsuleCollider extends Collider {
    public var center:Vector3 = new Vector3();
    public var radius:Float = 0.5;
    public var height:Float = 2;
    public var direction:Int = 1;

    public function new() {
        super();
    }

    override function get_bounds():Bounds {
        var worldCenter = transform != null ? transform.position + center : center;
        return new Bounds(worldCenter, new Vector3(radius * 2, height, radius * 2));
    }
}
