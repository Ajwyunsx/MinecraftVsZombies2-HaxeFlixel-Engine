// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/HackerDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

class HackerDetector extends Detector
{
    // PORT-NOTE: C# 中 Detector 派生类使用隐式无参构造函数；Haxe 不会为缺少构造函数的类合成构造函数，
    //   故此处显式声明无参构造，保证 `new HackerDetector()` 可用（与 C# 行为一致）。
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var source = self.Position;

        var sizeX = self.GetRange();
        var centerX = source.x + sizeX * 0.5 * self.GetFacingX();

        var sizeY:Float = 1000;
        var centerY = source.y;

        var sizeZ = self.Level.GetGridHeight();
        var centerZ = source.z;

        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    public override function ValidateTarget(self:DetectionParams, target:Entity):Bool
    {
        if (target.Type != EntityTypes.PLANT)
            return false;
        if (!target.CanDeactive() || target.IsAIFrozen())
            return false;
        return super.ValidateTarget(self, target);
    }
}
