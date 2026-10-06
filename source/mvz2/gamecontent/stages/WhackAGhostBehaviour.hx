// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/WhackAGhostBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.enemies.MinigameEnemySpeedBuff;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import pvzengine.entities.EntityTypes;
import mvz2logic.helditems.HeldItemBuilder;
import mvz2logic.helditems.LogicHeldTypes;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;

class WhackAGhostBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function Start(level:LevelEngine):Void
    {
        SetThunderTimer(level, new FrameTimer(150));
    }
    override public function Update(level:LevelEngine):Void
    {
        if (LogicLevelExt.GetHeldItemType(level) == LogicHeldTypes.none)
        {
            var builder = new HeldItemBuilder(LogicHeldTypes.sword);
            builder.SetCannotCancel(true);
            LogicLevelExt.SetHeldItem(level, builder);
        }
        var timer = GetThunderTimer(level);
        if (timer != null && timer.RunToExpired())
        {
            VanillaLevelExt.Thunder(level);
            timer.Reset();
        }
    }
    override public function PostWave(level:LevelEngine, wave:Int):Void
    {
        super.PostWave(level, wave);
        var timer = GetThunderTimer(level);
        if (timer != null)
        {
            timer.Frame = Mathf.MinInt(timer.Frame, 30);
        }

        var napstablookPoints = (wave - 5) / 3.0;
        if (level.IsHugeWave(wave))
        {
            napstablookPoints *= 2.5;
        }
        var napstablookCount = Mathf.CeilToInt(napstablookPoints);
        for (i in 0...napstablookCount)
        {
            var lane = level.GetRandomEnemySpawnLane();
            var column = level.GetSpawnRNG().Next(0, 5);
            var x = level.GetColumnX(column);
            var z = level.GetEntityLaneZ(lane);
            var y = level.GetGroundY(x, z);
            var spawnParam = new SpawnParams();
            spawnParam.SetProperty(EngineEntityProps.FACTION, level.Option.LeftFaction);
            var spawned = level.Spawn(VanillaEnemyID.napstablook, new Vector3(x, y, z), null, spawnParam);
            if (spawned != null)
            {
                MinigameEnemySpeedBuff.AddSpeedBuff(spawned, 3, 5);
            }
        }
    }
    override public function PostEnemySpawned(entity:Entity):Void
    {
        super.PostEnemySpawned(entity);
        if (entity.IsEntityOf(VanillaEnemyID.ghost))
        {
            var advanceDistance = entity.RNG.Next(0, entity.Level.GetGridWidth() * 3);
            entity.Position += Vector3.left * advanceDistance;
        }
    }
    // #region 关卡属性
    private function SetThunderTimer(level:LevelEngine, timer:FrameTimer):Void level.SetProperty(PROP_THUNDER_TIMER, timer);
    private function GetThunderTimer(level:LevelEngine):Null<FrameTimer> return level.GetProperty(PROP_THUNDER_TIMER);
    // #endregion

    // #region 属性字段
    private static inline var PROP_REGION:String = "whack_a_ghost";
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_THUNDER_TIMER:VanillaLevelPropertyMeta<FrameTimer> = new VanillaLevelPropertyMeta<FrameTimer>("ThunderTimer");
    // #endregion
}
