package unity;

// Minimal UnityEngine.Collider2D shim.
class Collider2D extends Component {
    public var enabled:Bool = true;
    public var isTrigger:Bool = false;
    public var offset:Vector2 = new Vector2();
    public var bounds:Bounds = new Bounds();

    public function new() {
        super();
    }
    public function OverlapPoint(point:Vector2):Bool return false;
}
