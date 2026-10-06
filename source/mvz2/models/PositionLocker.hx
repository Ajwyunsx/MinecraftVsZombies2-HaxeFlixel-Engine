// Ported from: Assets/Scripts/MVZ2/Models/Utilities/PositionLocker.cs
package mvz2.models;

import unity.Vector3;

// [ExecuteAlways]
class PositionLocker extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    private function LateUpdate():Void {
        if (localSpace) {
            transform.localPosition = position;
        } else {
            transform.position = position;
        }
    }
    private var localSpace:Bool = false;
    private var position:Vector3 = Vector3.zero;
}
