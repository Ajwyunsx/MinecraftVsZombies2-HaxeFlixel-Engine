// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/SkywardSky.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.ShootParams;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
import tools.Ticks;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.skywardSky)
class SkywardSky extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new SkywardSkyNightAura());
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (entity.IsTimeInterval(3))
        {
            var rng = entity.RNG;
            var level = entity.Level;
            var targetColumn = rng.Next(level.GetMaxColumnCount());
            var targetLane = rng.Next(level.GetMaxLaneCount());
            var targetPos = level.GetEntityGridPosition(targetColumn, targetLane);
            var flyTime = Ticks.FromSeconds(STAR_FLY_SECONDS);

            var velocity = STAR_VELOCITY;
            var sourcePosition = targetPos - velocity * flyTime;
            var param = entity.GetShootParams();
            param.projectileID = VanillaProjectileID.fallingStar;
            param.position = sourcePosition;
            param.velocity = velocity;
            var projectile = entity.ShootProjectile(param);
            if (entity.IsTimeInterval(12))
            {
                if (projectile != null)
                {
                    projectile.PlaySound(VanillaSoundID.star);
                }
            }
        }
    }
    public static inline var STAR_FLY_SECONDS:Float = 1;
    public static var STAR_VELOCITY:Vector3 = new Vector3(20, -20, 0);
}

// PORT-NOTE: C# 的嵌套类 SkywardSky.NightAura 提升为模块级类（Haxe 不支持嵌套类）；
// 因为 SkyBackground 也有同名的 NightAura，为避免同包重名，重命名为 SkywardSkyNightAura。
class SkywardSkyNightAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Level.skywardNight);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        results.push(auraEffect.Level);
    }
}
