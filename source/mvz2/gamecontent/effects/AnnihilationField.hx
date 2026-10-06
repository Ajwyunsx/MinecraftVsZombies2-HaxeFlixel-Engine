// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter4/AnnihilationField.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.detections.BlackholeDetector;
import mvz2.gamecontent.obstacles.VanillaObstacleID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.collisions.FactionTarget;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
import mvz2.vanilla.detection.Detector.DetectionParams;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.annihilationField)
class AnnihilationField extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        absorbDetector = new BlackholeDetector();
        absorbDetector.factionTarget = cast FactionTarget.Hostile;
        absorbDetector.mask = EntityCollisionHelper.MASK_PLANT | EntityCollisionHelper.MASK_ENEMY | EntityCollisionHelper.MASK_OBSTACLE | EntityCollisionHelper.MASK_PROJECTILE;
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Level.AddLoopSoundEntity(VanillaSoundID.gravitationSurge, entity.ID);
        entity.PlaySound(VanillaSoundID.annihilationField);
    }

    public override function Update(entity:Entity):Void
    {
        super.Update(entity);

        var range = entity.GetRange();
        entity.SetDisplayScale(Vector3.one * (range / 65));
        entity.Level.ShakeScreen(5, 0, 15);

        var active = entity.Timeout > 5;
        entity.SetAnimationBool("Started", active);
        if (!active)
            return;

        // Absorb.
        detectBuffer.resize(0);
        absorbDetector.DetectEntities(DetectionParams.fromEntity(entity), detectBuffer);
        var sqrRange = range * range;
        entity.Level.FindEntitiesNonAlloc(function(e) return e.IsEntityOf(VanillaObstacleID.monsterSpawner) && e.IsHostile(entity) && (e.GetCenter() - entity.GetCenter()).sqrMagnitude <= sqrRange, detectBuffer);
        for (target in detectBuffer)
        {
            target.RemoveDie();
        }
    }
    public override function PostRemove(entity:Entity):Void
    {
        super.PostRemove(entity);
        entity.SpawnUnlockArtifactPickup(VanillaAreaID.dream, VanillaUnlockID.bottledBlackhole, VanillaArtifactID.bottledBlackhole, entity.Position);
    }
    private var detectBuffer:Array<Entity> = [];
    private var absorbDetector:Detector;
}
