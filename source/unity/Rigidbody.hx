package unity;

// Minimal UnityEngine.Rigidbody shim.
class Rigidbody extends Component {
    public var position:Vector3 = new Vector3();
    public var rotation:Quaternion = Quaternion.identity;
    public var velocity:Vector3 = new Vector3();
    public var angularVelocity:Vector3 = new Vector3();
    public var mass:Float = 1;
    public var drag:Float = 0;
    public var angularDrag:Float = 0.05;
    public var useGravity:Bool = true;
    public var isKinematic:Bool = false;
    public var constraints:Int = 0;
    public var freezeRotation:Bool = false;
    public var detectCollisions:Bool = true;
    public var interpolation:Int = 0;
    public var collisionDetectionMode:Int = 0;

    public function new() {
        super();
    }

    public function MovePosition(pos:Vector3):Void {
        position = pos;
    }
    public function MoveRotation(rot:Quaternion):Void {
        rotation = rot;
    }
    public function AddForce(force:Vector3):Void {}
    public function AddForceAtPosition(force:Vector3, position:Vector3):Void {}
    public function AddTorque(torque:Vector3):Void {}
    public function Sleep():Void {}
    public function WakeUp():Void {}
}
