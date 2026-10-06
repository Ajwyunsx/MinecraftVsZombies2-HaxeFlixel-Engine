package unity;

// Minimal UnityEngine.Ray shim.
class Ray {
    public var origin:Vector3 = new Vector3();
    public var direction:Vector3 = new Vector3(0, 0, 1);

    public function new(?origin:Vector3, ?direction:Vector3) {
        if (origin != null) this.origin = origin;
        if (direction != null) this.direction = direction;
    }
    public function GetPoint(distance:Float):Vector3 return origin + direction * distance;
}
