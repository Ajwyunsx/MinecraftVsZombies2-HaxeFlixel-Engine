package unity;

// Minimal UnityEngine.BoxCollider2D shim.
class BoxCollider2D extends Collider2D {
    public var size:Vector2 = new Vector2(1, 1);

    public function new() {
        super();
    }
}
