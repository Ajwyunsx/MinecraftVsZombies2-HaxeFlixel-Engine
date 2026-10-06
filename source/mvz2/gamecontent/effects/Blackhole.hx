// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter4/Blackhole.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.bosses.TheGiant;
import mvz2.gamecontent.bosses.TheGiantSnakeTail;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.BlackholeDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.collisions.FactionTarget;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
import mvz2.vanilla.detection.Detector.DetectionParams;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.blackhole)
class Blackhole extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        absorbDetector = new BlackholeDetector();
        absorbDetector.mask = EntityCollisionHelper.MASK_VULNERABLE | EntityCollisionHelper.MASK_PROJECTILE;
        absorbDetector.factionTarget = cast FactionTarget.Any;
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Level.AddLoopSoundEntity(VanillaSoundID.gravitationSurge, entity.ID);
    }

    public override function Update(entity:Entity):Void
    {
        super.Update(entity);

        entity.SetDisplayScale(Vector3.one * (entity.GetRange() / 80));

        var active = entity.Timeout > 5;
        entity.SetAnimationBool("Started", active);
        if (!active)
            return;

        // Absorb.
        detectBuffer.resize(0);
        absorbDetector.DetectMultiple(DetectionParams.fromEntity(entity), detectBuffer);
        for (collider in detectBuffer)
        {
            var target = collider.Entity;
            var hostile = target.IsHostile(entity);
            if (collider.IsMainCollider())
            {
                if (target.Type == EntityTypes.BOSS)
                {
                    if (hostile)
                    {
                        if (target.IsEntityOf(VanillaBossID.theGiantSnakeTail) || (target.IsEntityOf(VanillaBossID.theGiant) && TheGiant.CanAttractByBlackhole(target)))
                        {
                            snakeBuffer.resize(0);
                            TheGiantSnakeTail.GetFullSnake(target, snakeBuffer);
                            for (segment in snakeBuffer)
                            {
                                segment.Velocity = Vector3.zero;
                                var newCenter = segment.GetCenter() * 0.9 + entity.GetCenter() * 0.1;
                                segment.SetCenter(newCenter);
                            }
                        }
                    }
                }
                else if (target.Type == EntityTypes.ENEMY)
                {
                    if (hostile)
                    {
                        target.Velocity = Vector3.zero;
                        var newCenter = target.GetCenter() * 0.7 + entity.GetCenter() * 0.3;
                        target.SetCenter(newCenter);
                        target.StopChangingLane();
                    }
                }
                else if (target.Type == EntityTypes.PROJECTILE)
                {
                    var newCenter = target.GetCenter() * 0.7 + entity.GetCenter() * 0.3;
                    target.SetCenter(newCenter);
                }
            }
            if (hostile && target.IsVulnerableEntity())
            {
                collider.TakeDamage(entity.GetDamage(), new DamageEffectList([VanillaDamageEffects.MUTE, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]), entity);
            }
        }
    }
    private var detectBuffer:Array<IEntityCollider> = [];
    private var snakeBuffer:Array<Entity> = [];
    private var absorbDetector:Detector;
}
