package unity;

// Minimal UnityEngine.SphereCollider shim.
class SphereCollider extends Collider {
    public var center:Vector3 = new Vector3();
    public var radius:Float = 0.5;

    public function new() {
        super();
    }

    override function get_bounds():Bounds {
        var r = new Vector3(radius * 2, radius * 2, radius * 2);
        var worldCenter = transform != null ? transform.position + center : center;
        return new Bounds(worldCenter, r);
    }
}
