// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter6/AmethystPylonLaser.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.detections.CollisionDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
import mvz2.vanilla.detection.Detector.DetectionParams;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.amethystPylonLaser)
class AmethystPylonLaser extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.PlaySound(VanillaSoundID.lightbeam);
        detectBuffer.resize(0);
        laserDetector.DetectEntities(DetectionParams.fromEntity(entity), detectBuffer);
        var effectsArray = entity.GetDamageEffects();
        var damageEffects = effectsArray == null ? new DamageEffectList([]) : new DamageEffectList(effectsArray);
        for (target in detectBuffer)
        {
            target.TakeDamage(entity.GetDamage(), damageEffects, entity);
        }
    }
    public static var laserDetector:Detector = new CollisionDetector(true);
    public var detectBuffer:Array<Entity> = [];
}
