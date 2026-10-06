// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter6/PetrifyLaser.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.detections.CollisionDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import pvzengine.entities.EntityTypes;
import tools.Ticks;
import unity.Color;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
import mvz2.vanilla.detection.Detector.DetectionParams;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.petrifyLaser)
class PetrifyLaser extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.PlaySound(VanillaSoundID.scifiLaser);
        detectBuffer.resize(0);
        laserDetector.DetectEntities(DetectionParams.fromEntity(entity), detectBuffer);
        var duration = Ticks.FromSeconds(PETRIFY_DURATION_SECONDS);
        var soundPlayed = false;
        for (target in detectBuffer)
        {
            if (!entity.GetProperty(PROP_ULTIMATE))
            {
                if (!target.CanDeactive())
                    continue;
                if (target.Type == EntityTypes.BOSS)
                    continue;
            }
            target.InflictPetrified(duration, new EntitySourceReference(entity));
            var spawnParams = target.GetSpawnParams();
            spawnParams.SetProperty(EngineEntityProps.TINT, Color.gray);
            target.Spawn(VanillaEffectID.smokeCluster, target.GetCenter(), spawnParams);
            if (!soundPlayed)
            {
                target.PlaySound(VanillaSoundID.giantSpike);
                target.PlaySound(VanillaSoundID.petrified);
                soundPlayed = true;
            }
        }
    }
    public static inline var PETRIFY_DURATION_SECONDS:Float = 10;
    public static var laserDetector:Detector = new CollisionDetector(true);
    public static var PROP_ULTIMATE:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("ultimate");
    public var detectBuffer:Array<Entity> = [];
}
