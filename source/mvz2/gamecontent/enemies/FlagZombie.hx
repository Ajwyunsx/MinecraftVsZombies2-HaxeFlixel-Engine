// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Prologue/FlagZombie.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.RandomEnemySpeedBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.flagZombie)
class FlagZombie extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.SetModelProperty("HasFlag", true);
        var speedBuff = entity.GetFirstBuff(RandomEnemySpeedBuff);
        if (speedBuff != null)
        {
            RandomEnemySpeedBuff.SetSpeed(speedBuff, 2);
        }
        var level = entity.Level;
        if (level.IsIZombie())
        {
            level.PlaySound(VanillaSoundID.siren);
            for (lane in 0...entity.Level.GetMaxLaneCount())
            {
                LogicLevelExt.SpawnEnemyByID(entity.Level, VanillaSpawnID.zombie, lane);
                LogicLevelExt.SpawnEnemyByID(entity.Level, VanillaSpawnID.leatherCappedZombie, lane);
                LogicLevelExt.SpawnEnemyByID(entity.Level, VanillaSpawnID.ironHelmettedZombie, lane);
            }
        }
    }
}
