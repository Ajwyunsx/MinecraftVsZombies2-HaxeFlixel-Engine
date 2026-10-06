// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/FireworkDispenser/ContraptionShooterBehaviour_FireworkDispenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.FireworkDispenserDetector;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.gamecontent.projectiles.ProjectileExplodeBehaviour_Firework;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import tools.Ticks;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.contraptionShooterFireworkDispenser)
class ContraptionShooterBehaviour_FireworkDispenser extends ContraptionShooterBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Shoot(entity:Entity):Null<Entity>
    {
        var projectile = super.Shoot(entity);
        if (projectile != null)
        {
            projectile.SetRange(entity.GetRange());
        }
        return projectile;
    }
    override function GetTimerTime(entity:Entity):Int
    {
        return Ticks.FromSeconds(TIMER_SECONDS);
    }
    override function GetDetector():Detector
    {
        var d = new FireworkDispenserDetector();
        cast(d, FireworkDispenserDetector).colliderFilter = ColliderFilter;
        return d;
    }
    function ColliderFilter(self:DetectionParams, collider:IEntityCollider):Bool
    {
        return ProjectileExplodeBehaviour_Firework.CanHitCollider(collider);
    }
    public static inline var TIMER_SECONDS:Float = 3;
}
