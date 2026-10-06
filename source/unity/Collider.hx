package unity;

// Minimal UnityEngine.Collider shim. Colliders register themselves with unity.Physics so that
// the overlap queries used by the game's collision system can be emulated without a real
// physics engine.
class Collider extends Component {
    public var enabled:Bool = true;
    public var isTrigger:Bool = false;
    public var material:Dynamic;
    public var sharedMaterial:Dynamic;
    public var attachedRigidbody:Rigidbody;
    public var contactOffset:Float = 0.01;
    public var bounds(get, never):Bounds;

    function get_bounds():Bounds {
        var zero = new Vector3();
        return new Bounds(zero, zero);
    }

    public function new() {
        super();
        Physics.register(this);
    }

    // Registers this collider with the shim physics world.
    public function OnEnable():Void {
        Physics.register(this);
    }
    public function OnDisable():Void {
        Physics.unregister(this);
    }

    public function ClosestPoint(position:Vector3):Vector3 return bounds.ClosestPoint(position);
    public function Raycast(ray:Dynamic, outHit:Dynamic, maxDistance:Float):Bool return false;
}
