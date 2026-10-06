// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/CrushingWalls/CrushingWallsModelPlatform.cs
package mvz2.models;

import unity.Camera;
import unity.Transform;
import unity.Vector3;

class CrushingWallsModelPlatform extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    public function SetLeftPosition(camera:Camera, value:Float, shake:Vector3):Void {
        SetWallPosition(camera, value, shake, leftWall, leftStart, leftEnd);
    }
    public function SetRightPosition(camera:Camera, value:Float, shake:Vector3):Void {
        SetWallPosition(camera, value, shake, rightWall, rightStart, rightEnd);
    }
    public function SetWallPosition(camera:Camera, value:Float, shake:Vector3, wall:Transform, start:Vector3, end:Vector3):Void {
        var worldPosition = camera.ViewportToWorldPoint(Vector3.Lerp(start, end, value));
        var localPosition = wall.parent.InverseTransformPoint(worldPosition) + shake;
        localPosition.z = 0;
        wall.localPosition = localPosition;
        wall.localRotation = camera.transform.rotation;
    }
    private var leftStart:Vector3 = new Vector3(0, 0.5, 0);
    private var leftEnd:Vector3 = new Vector3(0.5, 0.5, 0);
    private var rightStart:Vector3 = new Vector3(1, 0.5, 0);
    private var rightEnd:Vector3 = new Vector3(0.5, 0.5, 0);
    private var leftWall:Transform = null;
    private var rightWall:Transform = null;
}
