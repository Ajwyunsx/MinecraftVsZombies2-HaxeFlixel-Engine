// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/FinalClear/BossStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.level.LevelEnemiesClearedBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.pickups.ClearPickup;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.level.VanillaLevelStates;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffDefinition;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;
import unity.Vector3;

// abstract
class BossStageBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function Update(level:LevelEngine):Void
    {
        super.Update(level);
        switch (level.WaveState)
        {
            case VanillaLevelStates.STATE_FINAL_WAVE:
                FinalWaveUpdate(level);
            case VanillaLevelStates.STATE_AFTER_FINAL_WAVE:
                AfterFinalWaveUpdate(level);
            case VanillaLevelStates.STATE_BOSS_FIGHT:
                BossFightWaveUpdate(level);
            case VanillaLevelStates.STATE_AFTER_BOSS:
                AfterBossWaveUpdate(level);
        }
    }
    public function FinalWaveUpdate(level:LevelEngine):Void
    {
        if (LogicLevelExt.HasNoAliveEnemy(level))
        {
            StartAfterFinalWave(level);
        }
    }
    public function StartAfterFinalWave(level:LevelEngine):Void
    {
        level.WaveState = VanillaLevelStates.STATE_AFTER_FINAL_WAVE;
        LogicLevelExt.PostWaveFinished(level, level.CurrentWave);
    }
    public function AfterFinalWaveUpdate(level:LevelEngine):Void
    {
    }
    public function BossFightWaveUpdate(level:LevelEngine):Void
    {
    }
    public function AfterBossWaveUpdate(level:LevelEngine):Void
    {
    }
    public function RunBossWave(level:LevelEngine):Void
    {
        var behaviour:Null<WaveStageBehaviour> = VanillaLevelExt.GetStageBehaviour(level, WaveStageBehaviour);
        if (behaviour != null)
        {
            behaviour.RunBossWave(level);
        }
    }
    public function ClearEnemies(level:LevelEngine):Void
    {
        for (entity in level.FindEntities(function(e) return e.Type == EntityTypes.ENEMY && !e.IsDead && LogicEntityExt.IsHostileEntity(e)))
        {
            entity.Die(new DamageEffectList(VanillaDamageEffects.NO_REVIVAL));
        }
    }
    public function EnterLevelEnemiesClearedState(level:LevelEngine):Void
    {
        // 进入战斗暂停状态
        if (!level.HasBuff(LevelEnemiesClearedBuff))
        {
            level.AddBuff(LevelEnemiesClearedBuff);
        }
    }
    public function ExitLevelEnemiesClearedState(level:LevelEngine):Void
    {
        // 退出战斗暂停状态
        level.RemoveBuffs(LevelEnemiesClearedBuff);
    }
    public function GetClearPickupPosition(level:LevelEngine, target:Null<Entity>):Vector3
    {
        var position:Vector3;
        if (target != null)
        {
            position = target.Position;
        }
        else
        {
            var x = level.GetLawnCenterX();
            var z = level.GetLawnCenterZ();
            var y = level.GetGroundY(x, z);
            position = new Vector3(x, y, z);
        }
        return position;
    }
    public function SpawnClearPickup(level:LevelEngine, target:Null<Entity>):Null<Entity>
    {
        var position = GetClearPickupPosition(level, target);
        return ClearPickup.Produce(level, position);
    }
    public function IsHostileBoss(entity:Entity):Bool
    {
        return entity.Type == EntityTypes.BOSS && LogicEntityExt.IsHostileEntity(entity);
    }
    public function IsAliveHostileBoss(entity:Entity):Bool
    {
        return entity != null && entity.ExistsAndAlive() && IsHostileBoss(entity);
    }
    // PORT-NOTE: C# `StartBossTransitionUpdate<T>()` / `StartTransitionUntilBossExists<T>(level, Action)`
    // 使用泛型约束 `where T : BuffDefinition`；Haxe 的类型参数不是运行期值，无法直接传给
    // LevelEngine.AddBuff/HasBuff，因此按工程统一约定改为传递 `Class<T>` 参数（PORTING.md §泛型约束）。
    public function StartBossTransitionUpdate(level:LevelEngine, buffType:Class<BuffDefinition>):Void
    {
        StartTransitionUntilBossExists(level, buffType, function()
        {
            level.WaveState = VanillaLevelStates.STATE_BOSS_FIGHT;
        });
    }
    public function StartTransitionUntilBossExists(level:LevelEngine, buffType:Class<BuffDefinition>, onBossExists:Void->Void):Void
    {
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
        {
            onBossExists();
            return;
        }
        if (!level.HasBuff(buffType))
        {
            level.AddBuff(buffType);
        }
    }
    public function DisableUIAndInput(level:LevelEngine):Void
    {
        LogicLevelExt.ResetHeldItem(level);
        LogicLevelExt.SetUIAndInputDisabled(level, true);
    }
    public function StartAfterBossState(level:LevelEngine, entityID:NamespaceID):Void
    {
        level.WaveState = VanillaLevelStates.STATE_AFTER_BOSS;
        LogicLevelExt.StopMusic(level);
        if (LogicLevelExt.IsFirstAdventure(level))
        {
            // 隐藏UI，关闭输入
            DisableUIAndInput(level);
        }
        else
        {
            var reaper = level.FindFirstEntity(entityID);
            SpawnClearPickup(level, reaper);
        }
    }
    public static function SetBossState(level:LevelEngine, value:Int):Void level.SetProperty(FIELD_BOSS_PHASE, value);
    public static function GetBossState(level:LevelEngine):Int return level.GetProperty(FIELD_BOSS_PHASE);
    private static inline var PROP_REGION:String = "boss_stage";
    @:levelPropertyRegistry(PROP_REGION)
    public static var FIELD_BOSS_PHASE:VanillaLevelPropertyMeta<Int> = new VanillaLevelPropertyMeta<Int>("BossPhase");
}
