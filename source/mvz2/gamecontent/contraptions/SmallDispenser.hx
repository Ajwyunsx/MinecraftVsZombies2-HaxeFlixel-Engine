// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter1/SmallDispenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.smallDispenser)
class SmallDispenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            ShootTick(entity);
            return;
        }
    }
    public override function Shoot(entity:Entity):Null<Entity>
    {
        var projectile = super.Shoot(entity);
        if (projectile != null)
        {
            projectile.Timeout = Mathf.CeilToInt(entity.GetRange() / entity.GetShotVelocity().magnitude);
        }
        return projectile;
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var velocity = Vector3.right * 3;
        velocity.x *= entity.GetFacingX();

        var shootParams = entity.GetShootParams();
        shootParams.projectileID = VanillaProjectileID.largeSnowball;
        shootParams.velocity = velocity;
        entity.ShootProjectile(shootParams);
        entity.PlaySound(VanillaSoundID.odd);
    }
}
