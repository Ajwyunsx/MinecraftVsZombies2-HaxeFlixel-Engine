// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/Gravelpult_Evoke.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.LawnDetector;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.projectiles.VanillaProjectileProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicProjectileProps;
import pvzengine.EngineEntityProps;
import pvzengine.EntityID;
import pvzengine.entities.Entity;
import tools.Ticks;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.gravelpult_Evoke)
class Gravelpult_Evoke extends ContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Evoke(entity:Entity):Void
    {
        super.Evoke(entity);
        var gravity = PROJECTILE_GRAVITY;
        var param = entity.GetShootParams();
        param.damage *= 2;
        param.projectileID = VanillaProjectileID.gravel;
        param.spawnParam.SetProperty(VanillaProjectileProps.IGNORE_SHIELDS, true);
        param.spawnParam.SetProperty(EngineEntityProps.GRAVITY, gravity);

        detectBuffer = [];
        detector.DetectEntities(DetectionParams.fromEntity(entity), detectBuffer);
        for (throwTarget in detectBuffer)
        {
            param.spawnParam.SetProperty(LogicProjectileProps.LOCKED_TARGET_ID, new EntityID(throwTarget));
            var flyTime = Ticks.FromSeconds(PROJECTILE_FLY_TIME_SECONDS);
            var bounds = throwTarget.GetBounds();
            var targetPosition = bounds.center;
            targetPosition.y = bounds.max.y;
            targetPosition += throwTarget.Velocity * flyTime;
            param.velocity = VanillaProjectileExt.GetLobVelocityByTime(param.position, targetPosition, flyTime, gravity);
            entity.ShootProjectile(param);
        }
        entity.PlaySound(VanillaSoundID.launch);
    }
    public static inline var PROJECTILE_GRAVITY:Float = 2;
    public static inline var PROJECTILE_FLY_TIME_SECONDS:Float = 1;
    var detectBuffer:Array<Entity> = [];
    static var detector:Detector = new LawnDetector();
}
