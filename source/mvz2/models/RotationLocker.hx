// Ported from: Assets/Scripts/MVZ2/Models/Utilities/RotationLocker.cs
package mvz2.models;

import unity.Vector3;

// [ExecuteAlways]
class RotationLocker extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    private function LateUpdate():Void {
        if (localSpace) {
            transform.localEulerAngles = rotation;
        } else {
            transform.eulerAngles = rotation;
        }
    }
    private var localSpace:Bool = false;
    private var rotation:Vector3 = Vector3.zero;
}
