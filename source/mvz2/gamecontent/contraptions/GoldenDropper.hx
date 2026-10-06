// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/GoldenDropper.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.goldenDropper)
class GoldenDropper extends DispenserFamily
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
            param.velocity = new Vector3(xspeed, yspeed, zspeed);
            entity.ShootProjectile(param);
        }
        entity.PlaySound(VanillaSoundID.launch);
    }
}
