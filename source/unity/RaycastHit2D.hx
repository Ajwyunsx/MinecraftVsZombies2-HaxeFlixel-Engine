package unity;

// Minimal UnityEngine.RaycastHit2D shim.
class RaycastHit2D {
    public var point:Vector2 = new Vector2();
    public var normal:Vector2 = new Vector2();
    public var distance:Float = 0;
    // C#: public float fraction { get; } —— Unity 的 RaycastHit2D 同时暴露 distance 与 fraction。
    public var fraction(get, never):Float;
    function get_fraction():Float return distance;
    public var collider:Collider2D;
    public var transform:Transform;

    public function new() {}
}
