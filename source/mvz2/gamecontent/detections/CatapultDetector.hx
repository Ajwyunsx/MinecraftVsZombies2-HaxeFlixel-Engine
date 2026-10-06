// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/CatapultDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2logic.level.LevelPositions;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;

class CatapultDetector extends Detector
{
    // PORT-NOTE: C# 中 Detector 派生类使用隐式无参构造函数；Haxe 不会为缺少构造函数的类合成构造函数，
    //   故此处显式声明无参构造，保证 `new CatapultDetector()` 可用（与 C# 行为一致）。
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var shootOffset = self.GetShotOffset();
        shootOffset = self.ModifyShotOffset(shootOffset);
        var source = self.Position + shootOffset;
        var projectileSize = GetProjectileSize(self, Vector3.one * 32);
        var range = self.GetRange();

        var sizeX = range < 0 ? 800 : range;
        if (self.GetFacingX() > 0)
        {
            var limitedRange = LevelPositions.GetAttackBorderX(true) - source.x;
            sizeX = Mathf.Min(sizeX, limitedRange);
        }
        var sizeY:Float = 1000;
        var sizeZ = projectileSize.z;
        var centerX = source.x + sizeX * 0.5 * self.GetFacingX();
        var centerY = source.y;
        var centerZ = source.z;


        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
}
