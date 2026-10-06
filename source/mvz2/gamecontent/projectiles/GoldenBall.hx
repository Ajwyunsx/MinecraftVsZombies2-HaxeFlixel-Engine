// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter3/GoldenBall.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.callbacks.VanillaCallbackPriorities;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector2;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.pickups.VanillaPickupExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.goldenBall)
class GoldenBall extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_HIT, PostHitEntityCallback, VanillaCallbackPriorities.LATE);
    }
    function PostHitEntityCallback(param:PostProjectileHitParams, result:CallbackResult):Void
    {
        var hitResult = param.hit;
        var projectile = hitResult.Projectile;
        if (!projectile.Definition.HasBehaviour(this))
            return;
        if (projectile.RNG.Next(100) < 25)
        {
            projectile.Produce(VanillaPickupID.emerald);
        }

        var dmg = projectile.GetDamage();
        dmg *= 0.5;
        projectile.SetDamage(dmg);

        var hitCount = GetHitCount(projectile);
        hitCount++;
        SetHitCount(projectile, hitCount);
        if (hitCount >= MAX_HIT_COUNT)
        {
            hitResult.Pierce = false;
            return;
        }

        var vel = projectile.Velocity;
        var vel2D = new Vector2(vel.x, vel.z);
        var speed = vel2D.magnitude;
        vel.x = Mathf.Sign(vel.x) * speed * 0.5;

        var lane = projectile.GetLane();
        var zSpeed = speed / 2 * Mathf.Sqrt(3);
        var zDir:Int;
        if (lane <= 0)
        {
            zDir = -1;
        }
        else if (lane >= projectile.Level.GetMaxLaneCount() - 1)
        {
            zDir = 1;
        }
        else
        {
            zDir = Std.int(projectile.RNG.Next(2) * 2 - 1);
        }
        vel.z = zDir * zSpeed;
        projectile.Velocity = vel;
    }
    public static function GetHitCount(entity:Entity):Int return entity.GetBehaviourField(PROP_HIT_COUNT);
    public static function SetHitCount(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_HIT_COUNT, value);
    public static var PROP_HIT_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("HitCount");
    public static inline var MAX_HIT_COUNT:Int = 5;
}
