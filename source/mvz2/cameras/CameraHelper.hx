package mvz2.cameras;

import unity.Rect;
import unity.Vector2;
import unity.Camera;

// Ported from: Assets/Scripts/MVZ2/Cameras/CameraHelper.cs
// PORT-NOTE: C# extension methods → static methods taking the Camera as first parameter.
class CameraHelper {
    private function new() {}

    public static function GetViewSize(camera:Camera):Vector2 {
        var height = camera.orthographicSize * 2;
        return new Vector2(camera.aspect * height, height);
    }
    public static function GetViewRect(camera:Camera):Rect {
        var size = GetViewSize(camera);
        var pos = camera.transform.position;
        return new Rect(pos.x - size.x * 0.5, pos.y - size.y * 0.5, size.x, size.y);
    }
    public static function GetAspect(resolution:Vector2):Float {
        return resolution.x / resolution.y;
    }
}
