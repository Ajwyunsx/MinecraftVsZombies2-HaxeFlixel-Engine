// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/Triplenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.DispenserDetector;
import mvz2.gamecontent.projectiles.HellPlanet;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.triplenser)
class Triplenser extends DispenserFamily
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
    public override function OnShootTick(entity:Entity):Void
    {
        var lane = entity.GetLane();
        var maxLane = entity.Level.GetMaxLaneCount();
        var makeupCount = 0;
        for (i in (lane - 1)...(lane + 2))
        {
            var bullet = Shoot(entity);
            if (bullet == null)
                continue;
            if (i < 0 || i >= maxLane)
            {
                makeupCount++;
                bullet.Velocity *= 1 + (MAKE_UP_VELOCITY_MULTIPLIER_INCREAMENT * makeupCount);
            }
            else if (i != lane)
            {
                bullet.StartChangingLane(i);
            }
        }
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var otherworldParam = entity.GetShootParams();
        otherworldParam.damage = entity.GetDamage() * 50;
        otherworldParam.projectileID = VanillaProjectileID.hellPlanetOtherworld;
        otherworldParam.velocity = otherworldParam.velocity.normalized;
        var otherworld = entity.ShootProjectile(otherworldParam);

        var earthParam = entity.GetShootParams();
        earthParam.damage = entity.GetDamage() * 25;
        earthParam.projectileID = VanillaProjectileID.hellPlanetEarth;
        earthParam.velocity = Vector3.zero;
        var earth = entity.ShootProjectile(earthParam);
        if (earth != null)
        {
            earth.SetParent(otherworld);
            HellPlanet.SetOrbitDistance(earth, 72);
            HellPlanet.SetOrbitSpeed(earth, 3);
        }

        var moonParam = entity.GetShootParams();
        moonParam.damage = entity.GetDamage() * 12.5;
        moonParam.projectileID = VanillaProjectileID.hellPlanetMoon;
        moonParam.velocity = Vector3.zero;
        var moon = entity.ShootProjectile(moonParam);
        if (moon != null)
        {
            moon.SetParent(earth);
            HellPlanet.SetOrbitDistance(moon, 36);
            HellPlanet.SetOrbitSpeed(moon, 9);
        }

        entity.PlaySound(VanillaSoundID.odd);
        entity.PlaySound(VanillaSoundID.boon);
    }
    override function GetDetector():Detector
    {
        var d = new DispenserDetector();
        d.ignoreHighEnemy = true;
        cast(d, DispenserDetector).innerLaneExpansion = 1;
        cast(d, DispenserDetector).outerLaneExpansion = 1;
        return d;
    }
    public static inline var MAKE_UP_VELOCITY_MULTIPLIER_INCREAMENT:Float = 0.2;
}
