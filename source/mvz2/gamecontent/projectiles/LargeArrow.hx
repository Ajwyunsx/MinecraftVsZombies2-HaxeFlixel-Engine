// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter2/LargeArrow.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageResult;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Quaternion;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.largeArrow)
class LargeArrow extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_HIT, PostHitEntityCallback);
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        projectile.Velocity += projectile.Velocity.normalized * 0.3;

        var rotation = projectile.RenderRotation;
        var quaternion = Quaternion.Euler(rotation.x, rotation.y, rotation.z);
        var axis = quaternion * Vector3.right;
        var rotate = Quaternion.AngleAxis(projectile.Velocity.magnitude * 15, axis);
        var newRotation = rotation + rotate.eulerAngles;
        newRotation.x %= 360;
        newRotation.y %= 360;
        newRotation.z %= 360;
        projectile.RenderRotation = newRotation;
    }
    function PostHitEntityCallback(param:PostProjectileHitParams, result:CallbackResult):Void
    {
        var hitResult = param.hit;
        var projectile = hitResult.Projectile;
        if (!projectile.Definition.HasBehaviour(this))
            return;
        var damage = param.damage;
        if (damage == null)
            return;
        var fatal = true;
        var spentDamage = 0.0;
        // C#: void CheckDamageResult(DamageResult? result)（局部函数）
        var checkDamageResult = function(result:Null<DamageResult>):Void
        {
            if (result != null)
            {
                if (result.Fatal)
                {
                    spentDamage += result.SpendAmount;
                }
                else
                {
                    fatal = false;
                }
            }
        };
        checkDamageResult(damage.ShieldResult);
        checkDamageResult(damage.ArmorResult);
        checkDamageResult(damage.BodyResult);

        if (!fatal)
        {
            projectile.Remove();
        }

        var dmg = projectile.GetDamage();
        dmg -= spentDamage;
        projectile.SetDamage(dmg);

        if (dmg <= 0)
        {
            projectile.Remove();
        }
    }
}
