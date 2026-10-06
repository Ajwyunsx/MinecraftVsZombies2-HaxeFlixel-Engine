// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/BoxDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class BoxDetector extends Detector
{
    // PORT-NOTE: C# 有两个构造函数重载：
    //   BoxDetector(Vector3 size, Vector3 offset, bool canDetectInvisible = false)
    //   BoxDetector(Vector3 size, Vector3 offset, Vector3 pivot, bool canDetectInvisible = false)
    // Haxe 不支持重载，第三个参数用 Dynamic 承接，按运行期类型判断它是 pivot 还是 canDetectInvisible。
    public function new(size:Vector3, offset:Vector3, ?pivotOrCanDetectInvisible:Dynamic, ?canDetectInvisible:Bool = false)
    {
        this.size = size;
        this.offset = offset;
        if (Std.isOfType(pivotOrCanDetectInvisible, Bool))
        {
            this.pivot = new Vector3(0.5, 0, 0.5);
            this.canDetectInvisible = pivotOrCanDetectInvisible;
        }
        else
        {
            var pivot:Vector3 = pivotOrCanDetectInvisible != null ? (pivotOrCanDetectInvisible : Vector3) : null;
            this.pivot = pivot != null ? pivot : new Vector3(0.5, 0, 0.5);
            this.canDetectInvisible = canDetectInvisible;
        }
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var center = self.Position;
        center -= Vector3.Scale(pivot - Vector3.one * 0.5, size);
        center += offset;
        return new Bounds(center, size);
    }
    public var size:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var offset:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var pivot:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
