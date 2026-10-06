package unity;

// Minimal UnityEngine.RectTransformUtility shim.
class RectTransformUtility {
    public static function ScreenPointToLocalPointInRectangle(rect:RectTransform, screenPoint:Vector2, cam:Camera, localPoint:Vector2Ref):Bool {
        // PORT-NOTE: 移植层没有完整的 Canvas 坐标系，这里按 1:1 的平移近似。
        if (rect == null) {
            localPoint.value = new Vector2();
            return false;
        }
        localPoint.value = new Vector2(screenPoint.x - rect.position.x, screenPoint.y - rect.position.y);
        return true;
    }
    public static function ScreenPointToWorldPointInRectangle(rect:RectTransform, screenPoint:Vector2, cam:Camera, worldPoint:Vector3Ref):Bool {
        if (rect == null) {
            worldPoint.value = new Vector3();
            return false;
        }
        worldPoint.value = new Vector3(screenPoint.x, screenPoint.y, 0);
        return true;
    }
    public static function RectangleContainsScreenPoint(rect:RectTransform, screenPoint:Vector2, cam:Camera):Bool return false;
    public static function PixelAdjustPoint(point:Vector2, rect:RectTransform):Vector2 return point;
}

typedef Vector2Ref = {value:Vector2};
typedef Vector3Ref = {value:Vector3};
