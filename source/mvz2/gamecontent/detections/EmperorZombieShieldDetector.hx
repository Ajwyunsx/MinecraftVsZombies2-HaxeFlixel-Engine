// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/EmperorZombieShieldDetector.cs
package mvz2.gamecontent.detections;

import mvz2.gamecontent.buffs.entities.DivineShieldBuff;
import mvz2.gamecontent.buffs.entities.DivineShieldCooldownBuff;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2logic.entities.LogicEnemyProps;
import pvzengine.buffs.BuffExt;
import pvzengine.collisions.FactionTarget;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import unity.Bounds;
import unity.Vector3;
using mvz2logic.entities.LogicEnemyProps;

class EmperorZombieShieldDetector extends Detector
{
    public function new(radius:Float)
    {
        this.radius = radius;
        factionTarget = FactionTarget.Friendly;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var sizeX = radius * 2;
        var sizeY = radius * 2;
        var sizeZ = radius * 2;
        var center = self.GetCenter();
        return new Bounds(center, new Vector3(sizeX, sizeY, sizeZ));
    }
    public override function ValidateTarget(self:DetectionParams, target:Entity):Bool
    {
        if (!super.ValidateTarget(self, target))
            return false;
        if (target.Type != EntityTypes.PLANT && target.Type != EntityTypes.ENEMY)
            return false;
        if (target.HasBuff(DivineShieldBuff) || target.HasBuff(DivineShieldCooldownBuff))
            return false;
        if (target.IsNotActiveEnemy())
            return false;
        if (target.IsEntityOf(VanillaEnemyID.emperorZombie))
            return false;
        if ((target.GetCenter() - self.entity.GetCenter()).magnitude > radius)
            return false;
        return true;
    }
    private var radius:Float;
}
