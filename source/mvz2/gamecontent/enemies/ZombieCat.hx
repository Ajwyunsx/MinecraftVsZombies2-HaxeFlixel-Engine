// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/ZombieCat.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.zombieCat)
class ZombieCat extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);
        if (!entity.ShouldTriggerDeathEffects(deathInfo))
            return;
        if (entity.Level.IsIZombie() || entity.RNG.Next(2) == 0)
        {
            entity.SpawnWithParams(VanillaEnemyID.wispFly, entity.GetCenter());
        }
    }
}
