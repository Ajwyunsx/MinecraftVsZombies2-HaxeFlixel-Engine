// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/StoneEyeDetector.cs
package mvz2.gamecontent.detections;

import mvz2.gamecontent.contraptions.StoneEye;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;

class StoneEyeDetector extends Detector
{
    public function new(shootOffset:Vector3)
    {
        this.shootOffset = shootOffset;
        mask = EntityCollisionHelper.MASK_PLANT | EntityCollisionHelper.MASK_ENEMY | EntityCollisionHelper.MASK_OBSTACLE;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        // PORT-NOTE: C# 的 Vector3 为值类型，`var offset = shootOffset;` 是副本；
        // Haxe 的 unity.Vector3 底层为引用对象，需显式复制才能保持同样的局部变量语义。
        var offset = new Vector3(shootOffset.x, shootOffset.y, shootOffset.z);
        offset.x *= self.GetFacingX();
        var source = self.Position + shootOffset;

        var sizeX = StoneEye.GetRealRange(self);
        var sizeY:Float = 48;
        var sizeZ:Float = 48;
        var centerX = source.x + (sizeX * 0.5 * self.GetFacingX());
        var centerY = source.y;
        var centerZ = source.z;

        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!collider.IsForMain())
            return false;
        return super.ValidateCollider(param, collider);
    }
    public override function ValidateTarget(self:DetectionParams, target:Entity):Bool
    {
        if (target.ImmuneSlowing())
            return false;
        return super.ValidateTarget(self, target);
    }
    public var shootOffset:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
