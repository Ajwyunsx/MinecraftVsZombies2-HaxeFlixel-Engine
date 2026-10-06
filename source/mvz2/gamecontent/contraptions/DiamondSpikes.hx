// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/DiamondSpikes.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using tools.VectorExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.diamondSpikes)
class DiamondSpikes extends SpikesBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var param = entity.GetShootParams();
        var ySpeed = 10;
        var caltropCount = entity.Level.GetEntityCount(VanillaProjectileID.diamondCaltrop);
        var count = Mathf.MinInt(30, MAX_CALTROPS - caltropCount);
        for (i in 0...count)
        {
            var layer = Std.int(i / 10);
            var index = i % 10;
            var angle = index * 36;
            var speed = 3 + layer * 2;
            var velocity2D = Vector2.right.RotateClockwise(angle) * speed;
            param.position = entity.Position + Vector3.up * 16;
            param.pivot = VanillaEntityProps.SHOT_PIVOT_BOTTOM;
            param.projectileID = VanillaProjectileID.diamondCaltrop;
            param.velocity = new Vector3(velocity2D.x, ySpeed, velocity2D.y);
            param.damage = entity.GetDamage() * 5;
            entity.ShootProjectile(param);
        }
        entity.PlaySound(VanillaSoundID.fling);
    }
    public static inline var MAX_CALTROPS:Int = 100;
    override function get_SpikeParticleID():NamespaceID return VanillaEffectID.diamondSpikeParticles;
    override function get_AttackCooldown():Int return 15;
    override function get_EvocationAttackCooldown():Int return 2;
}
