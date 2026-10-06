package unity;

// Minimal UnityEngine.BoxCollider shim.
class BoxCollider extends Collider {
    public var center:Vector3 = new Vector3();
    public var size:Vector3 = new Vector3(1, 1, 1);

    public function new() {
        super();
    }

    override function get_bounds():Bounds {
        var worldCenter = transform != null ? transform.position + center : center;
        return new Bounds(worldCenter, size);
    }

    override public function ClosestPoint(position:Vector3):Vector3 {
        return bounds.ClosestPoint(position);
    }
}
