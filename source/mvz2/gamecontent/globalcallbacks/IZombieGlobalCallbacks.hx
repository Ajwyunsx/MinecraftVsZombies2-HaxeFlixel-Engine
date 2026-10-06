// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/IZombieGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.buffs.enemies.IZombieAttackBoosterBuff;
import mvz2.gamecontent.buffs.enemies.RandomEnemySpeedBuff;
import mvz2.gamecontent.enemies.EnemyMeleeBehaviour;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.modding.Mod;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.entities.EntityTypes;
import mvz2logic.level.LogicStageProps;

@:modGlobalCallbacks
class IZombieGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_INIT, PostEnemyInitCallback, 0, EntityTypes.ENEMY);
    }
    function PostEnemyInitCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var level = entity.Level;
        if (!LogicStageProps.IsIZombie(level))
            return;
        if (entity.Definition.HasBehaviour(EnemyMeleeBehaviour))
        {
            entity.AddBuff(IZombieAttackBoosterBuff);
        }
        for (buff in entity.GetBuffs(RandomEnemySpeedBuff))
        {
            RandomEnemySpeedBuff.SetSpeed(buff, ZOMBIE_RANDOM_SPEED);
        }
    }
    public static inline var ZOMBIE_RANDOM_SPEED:Float = 1.5;
}
