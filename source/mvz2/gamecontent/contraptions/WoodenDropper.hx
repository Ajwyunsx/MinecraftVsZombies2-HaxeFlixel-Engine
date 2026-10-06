// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter3/WoodenDropper.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.EngineEntityProps;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.woodenDropper)
class WoodenDropper extends DispenserFamily
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
            param.damage *= 4;
            param.velocity = new Vector3(xspeed, yspeed, zspeed);
            var spawnParam = param.spawnParam;
            spawnParam.SetProperty(EngineEntityProps.SCALE, Vector3.one * 2);
            spawnParam.SetProperty(EngineEntityProps.DISPLAY_SCALE, Vector3.one * 2);
            spawnParam.SetProperty(LogicEntityProps.SHADOW_SCALE, Vector3.one * 2);
            var ball = entity.ShootProjectile(param);
        }
        entity.PlaySound(VanillaSoundID.launch);
    }
}
