// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/SeijaCursedDoll.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.SphereDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using tools.VectorExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.seijaCursedDoll)
class SeijaCursedDoll extends EnemyBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        absorbDetector = new SphereDetector(ABSORB_RADIUS);
        cast(absorbDetector, SphereDetector).canDetectInvisible = true;
        cast(absorbDetector, SphereDetector).mask = EntityCollisionHelper.MASK_PROJECTILE;
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        if (!entity.Parent.ExistsAndAlive())
        {
            entity.Die(new DamageEffectList([VanillaDamageEffects.NO_NEUTRALIZE]), entity);
            return;
        }

        // Orbit.
        var angle = GetOrbitAngle(entity);
        angle += ORBIT_ANGLE_SPEED;
        SetOrbitAngle(entity, angle);

        var orbitOffset = Vector2.right.RotateClockwise(angle) * ORBIT_DISTANCE;
        var targetPosition = entity.Parent.GetCenter() + new Vector3(orbitOffset.x, 0, orbitOffset.y);
        targetPosition.y = Mathf.Max(targetPosition.y, entity.Level.GetGroundY(targetPosition));
        entity.SetCenter(targetPosition);

        // Absorb.
        detectBuffer = [];
        absorbDetector.DetectEntities(DetectionParams.fromEntity(entity), detectBuffer);
        for (target in detectBuffer)
        {
            var vel = target.Velocity;
            var speed = Mathf.Min(vel.magnitude + ABSORB_SPEED, ABSORB_MAX_SPEED);
            vel += (entity.Position - target.Position).normalized * ABSORB_SPEED;
            vel = vel.normalized * speed;
            target.Velocity = vel;
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (entity.WillRemoveOnDeath(info))
            return;
        var param = entity.GetSpawnParams();
        param.SetProperty(EngineEntityProps.SIZE, entity.GetSize());
        var smoke = entity.Spawn(VanillaEffectID.smoke, entity.GetCenter(), param);
        entity.Remove();
    }
    public static function GetOrbitAngle(entity:Entity):Float return entity.GetBehaviourField(PROP_ORBIT_ANGLE);
    public static function SetOrbitAngle(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_ORBIT_ANGLE, value);

    static var PROP_ORBIT_ANGLE:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("OrbitAngle");
    var detectBuffer:Array<Entity> = [];
    var absorbDetector:Detector;
    public static inline var ORBIT_DISTANCE:Float = 120;
    public static inline var ORBIT_ANGLE_SPEED:Float = 2;
    public static inline var ABSORB_RADIUS:Float = 120;
    public static inline var ABSORB_SPEED:Float = 5;
    public static inline var ABSORB_MAX_SPEED:Float = 10;
}
