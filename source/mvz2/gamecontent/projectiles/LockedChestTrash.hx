// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter6/LockedChestTrash.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.effects.Explosion;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.lockedChestTrash)
class LockedChestTrash extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);
        if (entity.WillRemoveOnDeath(deathInfo))
            return;
        entity.Level.ShakeScreen(1, 0, 1);
        entity.PlaySound(VanillaSoundID.smallExplosion);
        Explosion.Spawn(entity, entity.Position, 0);
    }
    public static function RandomVariant(rng:RandomGenerator):Int
    {
        return rng.Next(MAX_VARIANT);
    }
    public static inline var MAX_VARIANT:Int = 20;
}
