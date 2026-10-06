// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/UndeadFlyingObjectRainbow.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import unity.Color;

// PORT-NOTE: C# 扩展方法在 Haxe 侧以静态方法 + `using` 提供（PORTING.md §扩展方法）。
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityProps;
using pvzengine.entities.EngineEntityExt;
using pvzengine.entities.EngineEntityProps;
using tools.EnumerableExt;

class UFOBehaviourRainbow extends UFOBehaviour
{
    public function new()
    {
        super(UndeadFlyingObject.VARIANT_RAINBOW);
    }
    public override function UpdateActionState(entity:Entity, state:Int):Void
    {
        super.UpdateActionState(entity, state);
        // PORT-NOTE: Haxe 不继承静态成员，C# 中直接引用的基类静态成员需以 UFOBehaviour. 限定。
        switch (state)
        {
            case UFOBehaviour.STATE_STAY:
                UpdateStateStay(entity);
        }
    }
    function UpdateStateStay(enemy:Entity):Void
    {
        EnterUpdate(enemy);
        var timer = UFOBehaviour.GetOrInitStateTimer(enemy, STAY_TIME);
        if (timer.RunToExpiredAndNotNull())
        {
            SpawnRandomUFOs(enemy, 2);
            // C#: enemy.Spawn(...)?.Let(e => { e.SetTint(...); })
            var e = enemy.Spawn(VanillaEffectID.smokeCluster, enemy.GetCenter());
            if (e != null)
            {
                e.SetTint(new Color(1, 0.8, 1, 1));
            }
            enemy.Remove();
        }
    }
    public static function SpawnRandomUFOs(rainbow:Entity, count:Int):Void
    {
        var level:LevelEngine = rainbow.Level;
        var rng = rainbow.RNG;

        var possibleGrids:Map<LawnGrid, Bool> = new Map();

        // 获取可以随机生成的UFO类型。
        var typePool:Array<Int> = [];
        UndeadFlyingObject.FillUFOVariantRandomPool(level, rainbow.GetFaction(), typePool);

        for (i in 0...count)
        {
            // 获取一个随机的UFO类型。
            var type = typePool.Random(rng);

            // 获取可以生成该UFO的网格。
            possibleGrids.clear();
            UndeadFlyingObject.FillUFOPossibleSpawnGrids(level, type, rainbow.GetFaction(), possibleGrids);

            // 如果没有可用的网格，则跳过。
            if (Lambda.count(possibleGrids) <= 0)
                continue;

            // 检查冲突网格，确保不会与其他UFO冲突。
            // PORT-NOTE: C# 里 FillUFOPossibleSpawnGrids 收 HashSet<LawnGrid>（Haxe 用 Map<LawnGrid,Bool> 代替，
            // 见 UndeadFlyingObject.hx 的同名方法），而 FilterConflictSpawnGrids 收 IEnumerable<LawnGrid>
            // （Haxe 用 Array<LawnGrid>）。这里取 Map 的键转成数组以对应 C# 的集合语义。
            var gridArray = [for (k in possibleGrids.keys()) k];
            var resultGrids = UndeadFlyingObject.FilterConflictSpawnGrids(level, gridArray);
            var targetGrid = resultGrids.Random(rng);
            SpawnRandomUFO(type, rainbow, targetGrid.Column, targetGrid.Lane);
        }
    }
    public static function SpawnRandomUFO(type:Int, rainbow:Entity, column:Int, lane:Int):Null<Entity>
    {
        var param = rainbow.GetSpawnParams();
        // C#: rainbow.Spawn(...)?.Let(e => { ... })
        var e = rainbow.Spawn(VanillaEnemyID.ufo, rainbow.Position, param);
        if (e != null)
        {
            e.Position = rainbow.Position;
            e.SetVariant(type);
            UndeadFlyingObject.SetTargetGridX(e, column);
            UndeadFlyingObject.SetTargetGridY(e, lane);
        }
        return e;
    }

    public static inline var STAY_TIME:Int = 150;
    public static inline var ACT_TIME:Int = 30;
}
