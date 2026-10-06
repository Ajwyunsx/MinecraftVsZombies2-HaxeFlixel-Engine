// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/SpeedUpStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.enemies.MinigameEnemySpeedBuff;
import pvzengine.entities.Entity;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;

class SpeedUpStageBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition, minSpeed:Float = 1, maxSpeed:Float = 1)
    {
        super(stageDef);
        MinSpeed = minSpeed;
        MaxSpeed = maxSpeed;
    }
    override public function PostEnemySpawned(entity:Entity):Void
    {
        super.PostEnemySpawned(entity);
        MinigameEnemySpeedBuff.AddSpeedBuff(entity, MinSpeed, MaxSpeed);
    }
    public var MinSpeed:Float = 1;
    public var MaxSpeed:Float = 1;
}
