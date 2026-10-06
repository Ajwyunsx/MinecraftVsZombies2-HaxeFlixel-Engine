// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/WispFly.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.wispFly)
class WispFly extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 20);

        entity.Level.AddLoopSoundEntity(VanillaSoundID.flySwarm, entity.ID);
    }

    public override function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);
        if (entity.WillRemoveOnDeath(deathInfo))
            return;
        entity.Spawn(VanillaEffectID.cursedFireburn, entity.GetCenter());
        entity.Remove();
    }
}
