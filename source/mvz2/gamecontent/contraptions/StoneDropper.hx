// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter3/StoneDropper.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.DispenserDetector;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.stoneDropper)
class StoneDropper extends DispenserFamily
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
        if (entity.RNG.Next(4) == 0)
        {
            var param = entity.GetShootParams();
            param.projectileID = VanillaProjectileID.boulder;
            param.damage = entity.GetDamage() * BOULDER_DAMAGE_MULTIPLIER;
            return entity.ShootProjectile(param);
        }
        return super.Shoot(entity);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var rng = entity.RNG;
        for (i in 0...30)
        {
            var xspeed = entity.GetFacingX() * rng.Next(10, 18);
            var yspeed = rng.Next(30);
            var zspeed = rng.Next(-1.5, 1.5);
            var param = entity.GetShootParams();
            param.projectileID = VanillaProjectileID.boulder;
            param.damage = entity.GetDamage() * BOULDER_DAMAGE_MULTIPLIER;
            param.velocity = new Vector3(xspeed, yspeed, zspeed);
            entity.ShootProjectile(param);
        }
        entity.PlaySound(VanillaSoundID.launch);
    }
    override function GetDetector():Detector
    {
        var d = new DispenserDetector();
        d.ignoreHighEnemy = true;
        d.projectileID = VanillaProjectileID.boulder;
        return d;
    }
    public static inline var BOULDER_DAMAGE_MULTIPLIER:Float = 2;
}
