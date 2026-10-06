// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/FireworkDispenserDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityProps;

class FireworkDispenserDetector extends Detector
{
    // PORT-NOTE: C# 中 Detector 派生类使用隐式无参构造函数；Haxe 不会为缺少构造函数的类合成构造函数，
    //   故此处显式声明无参构造，保证 `new FireworkDispenserDetector()` 可用（与 C# 行为一致）。
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var center = GetExplosionCenter(self);
        var range = self.GetRange();
        var size = Vector3.one * (range * 2);
        return new Bounds(center, size);
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!ValidateTarget(param, collider.Entity))
            return false;
        var center = GetExplosionCenter(param.entity);
        var range = param.entity.GetRange();
        if (!collider.CheckSphere(center, range))
            return false;
        if (colliderFilter != null && !colliderFilter(param, collider))
            return false;
        return true;
    }
    private function GetExplosionCenter(self:Entity):Vector3
    {
        var bulletLifetime = 10;
        var explodePointOffset = self.GetShotOffset() + self.GetShotVelocity() * bulletLifetime;
        return self.Position + explodePointOffset;
    }
    public var colliderFilter:DetectionParams->IEntityCollider->Bool = null;
}
