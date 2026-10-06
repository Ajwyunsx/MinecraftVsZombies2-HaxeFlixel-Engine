// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/GravityPad.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.detections.GravityPadDetector;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.gravityPad)
class GravityPad extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new GravityAura());
        projectileDetector = new GravityPadDetector(false, AFFECT_HEIGHT);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        var level = entity.Level;
        var minY = entity.Position.y + MIN_HEIGHT;
        detectBuffer = [];
        projectileDetector.DetectEntities(DetectionParams.fromEntity(entity), detectBuffer);
        for (projectile in detectBuffer)
        {
            var pos = projectile.Position;
            pos.y = Mathf.Max(pos.y + PULL_DOWN_SPEED, minY);
            projectile.Position = pos;
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetModelProperty("IsOn", !entity.IsAIFrozen());
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var pos = entity.Position + Vector3.up * 600;
        entity.SpawnUnlockArtifactPickup(VanillaAreaID.castle, VanillaUnlockID.brokenLantern, VanillaArtifactID.brokenLantern, pos + Vector3.up * 100);
        var anvil = entity.SpawnWithParams(VanillaContraptionID.anvil, pos);
    }
    public static inline var AFFECT_HEIGHT:Float = 64;
    public static inline var MIN_HEIGHT:Float = 5;
    public static inline var PULL_DOWN_SPEED:Float = -3.333;
    var projectileDetector:Detector;
    var detectBuffer:Array<Entity> = [];
}

class GravityAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Enemy.gravityPadGravity, 7);
        enemyDetector = new GravityPadDetector(true, GravityPad.AFFECT_HEIGHT);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var source = auraEffect.Source;
        var entity = source.GetEntity();
        if (entity == null)
            return;
        if (entity.IsAIFrozen())
            return;
        detectBuffer = [];
        enemyDetector.DetectEntities(DetectionParams.fromEntity(entity), detectBuffer);
        for (e in detectBuffer)
            results.push(e);
    }
    var enemyDetector:Detector;
    var detectBuffer:Array<Entity> = [];
}
