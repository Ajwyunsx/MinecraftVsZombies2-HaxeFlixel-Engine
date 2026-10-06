// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/FinalClear/SeijaStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.bosses.Seija;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.enemies.SeijaMesmerizerBuff;
import mvz2.gamecontent.buffs.level.BattleRespiteBuff;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.progressbars.VanillaProgressBarID;
import mvz2.gamecontent.talk.VanillaTalkID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.bosses.VanillaBossStates;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.level.VanillaLevelStates;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import unity.Vector3;

class SeijaStageBehaviour extends BossStageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
        stageDef.AddTrigger(VanillaLevelCallbacks.POST_CONTRAPTION_EVOKE, PostGravityPadEvokeCallback, VanillaContraptionID.gravityPad);
    }
    override public function StartAfterFinalWave(level:LevelEngine):Void
    {
        super.StartAfterFinalWave(level);
        if (level.IsRerun)
        {
            StartBattle(level);
        }
        else
        {
            level.AddBuff(BattleRespiteBuff);
            var onEnd = function():Void
            {
                StartBattle(level);
                level.RemoveBuffs(BattleRespiteBuff);
            };
            LogicLevelExt.SimpleStartTalk(level, VanillaTalkID.castle7Boss, 0, 1, null, null, onEnd);
        }
    }
    override public function BossFightWaveUpdate(level:LevelEngine):Void
    {
        super.BossFightWaveUpdate(level);
        // 如果不存在Boss，继续播放音乐，进入到Boss后阶段
        // 如果所有Boss死亡，音乐放缓
        // 如果有Boss存活，不停生成怪物。
        var targetBosses = level.FindEntities(function(e) return e.Type == EntityTypes.BOSS && LogicEntityExt.IsHostileEntity(e) && e.ExistsAndAlive());
        if (targetBosses.length <= 0)
        {
            level.WaveState = VanillaLevelStates.STATE_AFTER_BOSS;
            LogicLevelExt.StopMusic(level);
            LogicLevelExt.SetProgressBarToStage(level);
            var x = level.GetEntityColumnX(level.GetMaxColumnCount() - 2);
            var z = level.GetEntityLaneZ(Std.int(level.GetMaxLaneCount() / 2));
            var y = 800;
            SpawnMesmerizer(level, new Vector3(x, y, z));
        }
        else
        {
            RunBossWave(level);
        }
    }
    override public function AfterBossWaveUpdate(level:LevelEngine):Void
    {
        super.AfterBossWaveUpdate(level);
        VanillaLevelExt.CheckClearUpdate(level);
    }
    private function StartBattle(level:LevelEngine):Void
    {
        level.WaveState = VanillaLevelStates.STATE_BOSS_FIGHT;
        var x = LevelPositions.ENEMY_RIGHT_BORDER;
        var z = level.GetEntityLaneZ(Std.int(level.GetMaxLaneCount() / 2));
        var y = level.GetGroundY(x, z);
        var seija = level.Spawn(VanillaBossID.seija, new Vector3(x, y, z), null);
        if (seija != null)
        {
            Seija.StartState(seija, VanillaBossStates.SEIJA_FRONTFLIP);
        }
        // 音乐。
        LogicLevelExt.PlayMusic(level, VanillaMusicID.seija);
        // 血条。
        LogicLevelExt.SetProgressBarToBoss(level, VanillaProgressBarID.seija);
        // 重置下一波计时器。
        var behaviour:Null<WaveStageBehaviour> = VanillaLevelExt.GetStageBehaviour(level, WaveStageBehaviour);
        if (behaviour != null)
        {
            var timer = WaveStageBehaviour.GetWaveTimer(level);
            if (timer != null)
                timer.ResetTime(200);
        }
    }
    private function SpawnMesmerizer(level:LevelEngine, position:Vector3):Null<Entity>
    {
        if (level.GetProperty(FIELD_MESMERIZER_SPAWNED))
            return null;
        level.SetProperty(FIELD_MESMERIZER_SPAWNED, true);
        var mesmerizer = level.Spawn(VanillaEnemyID.mesmerizer, position, null);
        if (mesmerizer != null)
        {
            mesmerizer.AddBuff(SeijaMesmerizerBuff);
        }
        return mesmerizer;
    }
    private function PostGravityPadEvokeCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var contraption = param.entity;
        var level = contraption.Level;
        if (!LogicLevelExt.HasBehaviour(level, this))
            return;
        if (level.WaveState != VanillaLevelStates.STATE_BOSS_FIGHT)
            return;
        var x = contraption.Position.x;
        var z = contraption.Position.z;
        var y = 800;
        SpawnMesmerizer(level, new Vector3(x, y, z));
    }
    public static inline var PROP_REGION:String = "seija_stage_behaviour";
    @:levelPropertyRegistry(PROP_REGION)
    public static var FIELD_MESMERIZER_SPAWNED:VanillaLevelPropertyMeta<Bool> = new VanillaLevelPropertyMeta<Bool>("MesmerizerSpawned");
}
