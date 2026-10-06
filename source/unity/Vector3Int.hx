package unity;

// Minimal UnityEngine.Vector3Int shim.
class Vector3Int {
    public var x:Int;
    public var y:Int;
    public var z:Int;

    public static var zero(get, never):Vector3Int;
    public static var one(get, never):Vector3Int;

    public function new(x:Int = 0, y:Int = 0, z:Int = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    static inline function get_zero():Vector3Int return new Vector3Int(0, 0, 0);
    static inline function get_one():Vector3Int return new Vector3Int(1, 1, 1);

    public function toString():String return '($x, $y, $z)';
}
