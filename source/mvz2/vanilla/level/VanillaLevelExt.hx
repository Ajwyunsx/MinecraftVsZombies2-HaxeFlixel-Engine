// Ported from: Assets/Scripts/Vanilla/GameContent/Level/VanillaLevelExt.cs
package mvz2.vanilla.level;

import mvz2.gamecontent.buffs.enemies.GhostBuff;
import mvz2.gamecontent.buffs.level.ThunderBuff;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.pickups.ClearPickup;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.carts.VanillaCartStates;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.grids.VanillaGridExt;
import mvz2.vanilla.helditems.VanillaHeldItemExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.Global;
import mvz2logic.level.GameOverTypes;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.level.LogicStageProps;
import pvzengine.NamespaceID;
import pvzengine.collisions.IEntityCollider;
import pvzengine.collisions.OverlapParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.EntitySourceReference;
import pvzengine.definitions.StageBehaviour;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import pvzengine.grids.LawnGrid;
import pvzengine.level.ILevelSourceReference;
import pvzengine.level.LevelEngine;
import tools.EnumerableExt;
import tools.RandomGenerator;
import unity.Mathf;
import unity.Vector3;

// PORT-NOTE: C# 分部类合并为单个 Haxe 类文件（PORTING.md §partial class）。
// PORT-NOTE: C# 扩展方法 → 以 LevelEngine / 接收者为第一参数的静态方法（PORTING.md §扩展方法）。
class VanillaLevelExt
{
    // PORT-NOTE: C# 泛型方法 GetBehaviour<T>() 在 Haxe 中无法书写类型实参，改为传入类对象。
    public static function GetStageBehaviour<T:StageBehaviour>(level:LevelEngine, typeClass:Class<T>):Null<T>
    {
        if (level == null || level.StageDefinition == null)
            return null;
        return level.StageDefinition.GetBehaviour(typeClass);
    }

    // #region 推车
    public static function RefreshCarts(level:LevelEngine):Void
    {
        var cartRef = level.GetCartReference();
        if (cartRef != null)
            SpawnCarts(level, cartRef, LevelPositions.CART_START_X, 20);
    }
    public static function SpawnCarts(level:LevelEngine, cartRef:NamespaceID, x:Float, xInterval:Float):Void
    {
        var carts = level.GetEntities(EntityTypes.CART);
        for (i in 0...level.GetMaxLaneCount())
        {
            if (Lambda.exists(carts, c -> c.GetLane() == i && c.State == VanillaCartStates.IDLE))
                continue;
            level.Spawn(cartRef, new Vector3(x - i * xInterval, 0, level.GetEntityLaneZ(i)), null);
        }
    }
    // #endregion

    // #region 游戏结束检查
    public static function CheckGameOver(level:LevelEngine):Void
    {
        if (level.IsCleared) // 关卡通关后不能再死亡
            return;
        if (LogicLevelProps.IsGodMode(level)) // 上帝模式
            return;
        var gameOverEnemy = level.FindFirstEntity((e:Entity) -> e.Position.x < LevelPositions.GetBorderX(false) && VanillaEntityExt.CanEntityEnterHouse(e));
        if (gameOverEnemy != null)
        {
            level.GameOver(GameOverTypes.ENEMY, gameOverEnemy, null);
        }
    }
    // #endregion

    // #region 通关检查
    public static function CheckClearUpdate(level:LevelEngine):Void
    {
        var lastEnemy = LogicLevelExt.GetFirstAliveEnemy(level);
        if (lastEnemy != null)
        {
            LogicLevelProps.SetLastEnemyPosition(level, lastEnemy.Position);
        }
        else if (LogicLevelExt.HasNoAliveEnemy(level))
        {
            LogicLevelExt.PostWaveFinished(level, level.CurrentWave);
            LogicStageProps.SetNoEnergy(level, true);
            if (!LogicLevelProps.IsAllEnemiesCleared(level))
            {
                LogicLevelProps.SetAllEnemiesCleared(level, true);
                var lastEnemyPosition = LogicLevelProps.GetLastEnemyPosition(level);
                var position:Vector3;
                if (lastEnemyPosition.x <= LevelPositions.GetBorderX(false))
                {
                    var x = level.GetEnemySpawnX();
                    var z = level.GetEntityLaneZ(Mathf.CeilToInt(level.GetMaxLaneCount() * 0.5));
                    var y = level.GetGroundY(x, z);
                    position = new Vector3(x, y, z);
                }
                else
                {
                    position = lastEnemyPosition;
                }
                ClearPickup.Produce(level, position);
            }
        }
    }
    // #endregion

    // #region 范围伤害
    public static function Explode(level:LevelEngine, center:Vector3, radius:Float, faction:Int, amount:Float, effects:DamageEffectList, source:Entity, ?filter:IEntityCollider->Bool):Array<DamageOutput>
    {
        return ExplodeWithSourceRef(level, center, radius, faction, amount, effects, new EntitySourceReference(source), filter);
    }
    // PORT-NOTE: Haxe has no method overloading; renamed overload to ExplodeWithSourceRef.
    public static function ExplodeWithSourceRef(level:LevelEngine, center:Vector3, radius:Float, faction:Int, amount:Float, effects:DamageEffectList, source:Null<ILevelSourceReference>, ?filter:IEntityCollider->Bool):Array<DamageOutput>
    {
        var damageOutputs:Array<DamageOutput> = [];
        var overlapParam = OverlapParams.Hostile(faction, EntityCollisionHelper.MASK_VULNERABLE);
        for (entityCollider in level.OverlapSphere(center, radius, overlapParam))
        {
            if (filter != null && !filter(entityCollider))
                continue;
            var damageOutput = VanillaColliderExt.TakeDamageWithSourceRef(entityCollider, amount, effects, source);
            if (damageOutput != null)
            {
                damageOutputs.push(damageOutput);
            }
        }
        return damageOutputs;
    }
    public static function ExplodeAgainstFriendly(level:LevelEngine, center:Vector3, radius:Float, faction:Int, amount:Float, effects:DamageEffectList, source:Entity):Array<DamageOutput>
    {
        return ExplodeAgainstFriendlyWithSourceRef(level, center, radius, faction, amount, effects, new EntitySourceReference(source));
    }
    // PORT-NOTE: Haxe has no method overloading; renamed overload to ExplodeAgainstFriendlyWithSourceRef.
    public static function ExplodeAgainstFriendlyWithSourceRef(level:LevelEngine, center:Vector3, radius:Float, faction:Int, amount:Float, effects:DamageEffectList, source:ILevelSourceReference):Array<DamageOutput>
    {
        var damageOutputs:Array<DamageOutput> = [];
        var overlapParam = OverlapParams.Friendly(faction, EntityCollisionHelper.MASK_VULNERABLE);
        for (entityCollider in level.OverlapSphere(center, radius, overlapParam))
        {
            var damageOutput = VanillaColliderExt.TakeDamageWithSourceRef(entityCollider, amount, effects, source);
            if (damageOutput != null)
            {
                damageOutputs.push(damageOutput);
            }
        }
        return damageOutputs;
    }

    public static function SplashDamage(level:LevelEngine, excludeCollider:IEntityCollider, center:Vector3, radius:Float, faction:Int, amount:Float, effects:DamageEffectList, source:Entity):Array<DamageOutput>
    {
        return SplashDamageWithSourceRef(level, excludeCollider, center, radius, faction, amount, effects, new EntitySourceReference(source));
    }
    // PORT-NOTE: Haxe has no method overloading; renamed overload to SplashDamageWithSourceRef.
    public static function SplashDamageWithSourceRef(level:LevelEngine, excludeCollider:IEntityCollider, center:Vector3, radius:Float, faction:Int, amount:Float, effects:DamageEffectList, source:ILevelSourceReference):Array<DamageOutput>
    {
        var damageOutputs:Array<DamageOutput> = [];
        var overlapParam = OverlapParams.Hostile(faction, EntityCollisionHelper.MASK_VULNERABLE);
        for (entityCollider in level.OverlapSphere(center, radius, overlapParam))
        {
            if (entityCollider == excludeCollider)
                continue;
            var damageOutput = VanillaColliderExt.TakeDamageWithSourceRef(entityCollider, amount, effects, source);
            if (damageOutput != null)
            {
                damageOutputs.push(damageOutput);
            }
        }
        return damageOutputs;
    }
    // PORT-NOTE: C# `this IEnumerable<DamageOutput>` → Haxe Iterable<DamageOutput>。
    public static function ClearExplosionCorpses(damageOutputs:Iterable<DamageOutput>):Void
    {
        // 清理尸体。
        for (output in damageOutputs)
        {
            var ent = output.Entity;
            if (ent.Type == EntityTypes.ENEMY && ent.IsDead)
            {
                ent.Remove();
            }
        }
    }
    // #endregion

    // #region 生成旗帜僵尸
    public static function SpawnFlagZombie(level:LevelEngine):Null<Entity>
    {
        var lane = level.GetRandomEnemySpawnLane();
        return SpawnFlagZombieInLane(level, lane);
    }
    // PORT-NOTE: Haxe has no method overloading; renamed overload to SpawnFlagZombieInLane.
    public static function SpawnFlagZombieInLane(level:LevelEngine, lane:Int):Null<Entity>
    {
        var x = level.GetEnemySpawnX();
        var z = level.GetEntityLaneZ(lane);
        var y = level.GetGroundY(x, z);
        var pos = new Vector3(x, y, z);
        return level.Spawn(VanillaEnemyID.flagZombie, pos, null);
    }
    // #endregion

    // #region 打雷
    public static function Thunder(level:LevelEngine):Void
    {
        level.AddBuff(ThunderBuff);
        for (ghost in level.GetEntities())
        {
            for (buff in ghost.GetBuffs(GhostBuff))
            {
                GhostBuff.Illuminate(buff);
            }
        }
        var model = LogicLevelExt.GetAreaModelInterface(level);
        if (model != null)
            model.TriggerAnimation("Thunder");
        LogicLevelExt.PlaySound(level, VanillaSoundID.thunder);
    }
    // #endregion

    // #region 下雨
    public static function StartRain(level:LevelEngine):Void
    {
        level.Spawn(VanillaEffectID.rain, new Vector3(LevelPositions.LEVEL_WIDTH * 0.5, 0, 0), null);
    }
    // #endregion

    // #region 一大波
    public static function IsDuringHugeWave(level:LevelEngine):Bool
    {
        var waveState = level.WaveState;
        if (waveState == VanillaLevelStates.STATE_HUGE_WAVE_APPROACHING)
            return true;
        if (level.IsHugeWave(level.CurrentWave))
        {
            if (waveState == VanillaLevelStates.STATE_STARTED)
                return true;
            if (waveState == VanillaLevelStates.STATE_FINAL_WAVE)
                return true;
        }
        return false;
    }
    // #endregion

    // #region 导电
    public static function IsConductiveGrid(level:LevelEngine, column:Int, lane:Int):Bool
    {
        var grid = level.GetGrid(column, lane);
        if (grid == null)
            return false;
        return VanillaGridExt.IsConductive(grid);
    }
    public static function IsConductiveAt(level:LevelEngine, x:Float, z:Float):Bool
    {
        var column = level.GetColumn(x);
        var lane = level.GetLane(z);
        return IsConductiveGrid(level, column, lane);
    }
    public static function GetConnectedConductiveGrids(level:LevelEngine, pos:Vector3, xExpand:Int, yExpand:Int, results:Map<LawnGrid, Bool>):Void
    {
        var column = level.GetColumn(pos.x);
        var lane = level.GetLane(pos.z);
        GetConnectedConductiveGridsAt(level, column, lane, xExpand, yExpand, results);
    }
    // PORT-NOTE: Haxe has no method overloading; renamed overload to GetConnectedConductiveGridsAt.
    public static function GetConnectedConductiveGridsAt(level:LevelEngine, column:Int, lane:Int, xExpand:Int, yExpand:Int, results:Map<LawnGrid, Bool>):Void
    {
        for (xOff in -xExpand...xExpand + 1)
        {
            for (yOff in -yExpand...yExpand + 1)
            {
                var col = column + xOff;
                var lan = lane + yOff;
                var grid = level.GetGrid(col, lan);
                if (grid == null)
                    continue;
                if (VanillaGridExt.IsConductive(grid))
                {
                    results.set(grid, true);
                }
            }
        }
    }
    // #endregion

    // #region 手持物品
    public static function GetHeldSeedEntityID(level:LevelEngine):Null<NamespaceID>
    {
        var data = LogicLevelExt.GetHeldItemData(level);
        if (data == null)
            return null;
        return VanillaHeldItemExt.GetSeedEntityID(data, level);
    }
    // #endregion

    // #region 制品解锁
    public static function SpawnUnlockArtifactPickup(level:LevelEngine, areaID:NamespaceID, unlockID:NamespaceID, artifactID:NamespaceID, position:Vector3, spawner:Null<Entity>):Null<Entity>
    {
        if (level.AreaID == areaID && !Global.Saves.IsUnlocked(unlockID))
        {
            if (!level.EntityExists(e -> e.IsEntityOf(VanillaPickupID.artifactPickup) && VanillaPickupProps.GetPickupContentID(e) == artifactID))
            {
                // PORT-NOTE: C# `?.Let(e => {...})` → 显式判空后设置并返回同一实体。
                var entity = level.Spawn(VanillaPickupID.artifactPickup, position, spawner);
                if (entity != null)
                {
                    VanillaPickupProps.SetPickupContentID(entity, artifactID);
                }
                return entity;
            }
        }
        return null;
    }
    // #endregion

    // #region 随机池器械
    public static function GetRandomContraptionFromPool(level:LevelEngine, rng:RandomGenerator):NamespaceID
    {
        var pool = LogicLevelProps.GetRandomContraptionPool(level);
        if (pool != null)
        {
            // PORT-NOTE: C# Tools 扩展方法 Random(this IEnumerable<T>, RandomGenerator) → EnumerableExt.Random(数组, rng)。
            return EnumerableExt.Random(pool, rng);
        }
        return VanillaContraptionID.dispenser;
    }
    // #endregion
}
