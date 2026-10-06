// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/SoulFurnaceEvocationDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;

class SoulFurnaceEvocationDetector extends Detector
{
    // PORT-NOTE: C# 中 Detector 派生类使用隐式无参构造函数；Haxe 不会为缺少构造函数的类合成构造函数，
    //   故此处显式声明无参构造，保证 `new SoulFurnaceEvocationDetector()` 可用（与 C# 行为一致）。
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var sizeX:Float = 800;
        var sizeY = self.GetScaledSize().y;
        var sizeZ:Float = 800;
        var source = self.Position;
        var centerX = source.x + sizeX * 0.5 * self.GetFacingX();
        var centerY = source.y + sizeY * 0.5;
        var centerZ = source.z;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
}
