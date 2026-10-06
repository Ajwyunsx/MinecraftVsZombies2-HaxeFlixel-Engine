// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter6/MegaGlowingLaser.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.CollisionDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import tools.Ticks;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
import mvz2.vanilla.detection.Detector.DetectionParams;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.megaGlowingLaser)
class MegaGlowingLaser extends EntityBehaviourDefinition
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
        var duration = Ticks.FromSeconds(GLOWING_DURATION_SECONDS);
        var damage = entity.GetDamage();
        for (target in detectBuffer)
        {
            target.InflictGlowing(duration, new EntitySourceReference(entity));
            if (damage > 0)
            {
                target.TakeDamage(damage, new DamageEffectList([VanillaDamageEffects.LIGHT, VanillaDamageEffects.MUTE, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]), entity);
            }
        }

    }
    public static inline var GLOWING_DURATION_SECONDS:Float = 30;
    public static var laserDetector:Detector = new CollisionDetector(true);
    public var detectBuffer:Array<Entity> = [];
}
