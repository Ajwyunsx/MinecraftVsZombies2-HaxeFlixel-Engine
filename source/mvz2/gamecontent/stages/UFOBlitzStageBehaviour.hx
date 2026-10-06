// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/UFOBlitzStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.level.UFOSpawnBuff;
import mvz2.gamecontent.enemies.VanillaSpawnID;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;
using mvz2logic.spawns.LogicSpawnProps;

class UFOBlitzStageBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function Start(level:LevelEngine):Void
    {
        var spawnDefinition = level.Content.GetSpawnDefinition(VanillaSpawnID.undeadFlyingObjectBlitz);
        if (spawnDefinition != null)
        {
            UFOSpawnBuff.Prepare(level, spawnDefinition.GetSpawnEntityVariant(), spawnDefinition.GetSpawnLevel());
        }
    }
}
