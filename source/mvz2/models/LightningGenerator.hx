// Ported from: Assets/Scripts/MVZ2/Models/Utilities/LightningGenerator.cs
package mvz2.models;

import tools.ObjectExtensions;
import unity.Debug;
import unity.LineRenderer;
import unity.Mathf;
import unity.Quaternion;
import unity.Vector2;
import unity.Vector3;
import pvzengine.RandomGenerator;

// [RequireComponent(typeof(LineRenderer))]
class LightningGenerator extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    public function GenerateLightning(pointCount:Int, sourcePosition:Vector3, targetPosition:Vector3, rng:RandomGenerator):Void {
        var points = GenerateLightningPoints(pointCount, sourcePosition, targetPosition, amplitude, rng);
        LineRenderer.positionCount = pointCount;
        if (points != null) {
            LineRenderer.SetPositions(points);
        }
    }
    // PORT-NOTE: C# 中实例方法与静态方法重名（GenerateLightning）；Haxe 不支持重载，
    // 静态版本改名 GenerateLightningPoints。
    public static function GenerateLightningPoints(pointCount:Int, sourcePosition:Vector3, targetPosition:Vector3, amplitude:Float, rng:RandomGenerator):Array<Vector3> {
        if (pointCount < 2) {
            Debug.LogError("The position count of line renderer is less than 2.");
            return null;
        }

        var array = new Array<Vector3>();
        array.resize(pointCount);
        var offset = Vector2.zero;

        var dis = (targetPosition - sourcePosition).magnitude;
        var dir = (targetPosition - sourcePosition).normalized;

        var rotation = Quaternion.FromToRotation(Vector3.right, dir);

        var currentPos:Vector3;
        for (i in 0...pointCount) {
            if (i == pointCount - 1) {
                currentPos = targetPosition;
            } else if (i > 0) {
                var percent = i / (pointCount - 1);
                var value = Vector2.zero;
                value.x = rng.Next(0, amplitude) - amplitude / 2;
                value.y = rng.Next(0, amplitude) - amplitude / 2;
                if (i > Std.int(pointCount / 2)) {
                    var fraction = Mathf.Pow(percent * 2 - 1, 8);
                    value = value - offset * fraction;
                }

                offset = offset + value;
                currentPos = sourcePosition + rotation * new Vector3(percent * dis, offset.x, offset.y);
            } else {
                currentPos = sourcePosition;
            }
            array[i] = currentPos;
        }
        return array;
    }
    public var LineRenderer(get, never):LineRenderer;
    function get_LineRenderer():LineRenderer {
        if (lineRenderer == null) {
            // PORT-NOTE: 与同名属性冲突，使用模块限定名引用类型。
            lineRenderer = GetComponent(unity.LineRenderer);
        }
        return lineRenderer;
    }
    private var lineRenderer:LineRenderer = null;
    public var amplitude:Float = 0.2;
}
