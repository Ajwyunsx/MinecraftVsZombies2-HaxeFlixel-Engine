package unity;

// Minimal UnityEngine.PolygonCollider2D shim.
class PolygonCollider2D extends Collider2D {
    public var points:Array<Vector2> = [];
    public var pathCount:Int = 0;

    public function new() {
        super();
    }
    public function GetPath(index:Int):Array<Vector2> return points;
    public function SetPath(index:Int, path:Array<Vector2>):Void points = path;
}
