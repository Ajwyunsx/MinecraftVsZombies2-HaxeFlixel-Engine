package unity;

// Minimal UnityEngine.Rigidbody2D shim.
class Rigidbody2D extends Component {
    public var bodyType:Int = 0;
    public var gravityScale:Float = 1;
    public var velocity:Vector2 = new Vector2();
    public var simulated:Bool = true;

    public function new() {
        super();
    }
}
