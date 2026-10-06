// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/UFOBehaviourRed.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.entities.WhiteFlashBuff;
import mvz2.gamecontent.buffs.enemies.SummonedByUFOBuff;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import tools.FrameTimer;
using mvz2.vanilla.entities.VanillaEntityExt;
using tools.EnumerableExt;
import mvz2.gamecontent.enemies.UndeadFlyingObject;
import mvz2.gamecontent.enemies.UFOBehaviour;

class UFOBehaviourRed extends UFOBehaviour
{
    public function new()
    {
        super(UndeadFlyingObject.VARIANT_RED);
    }
    public override function CanSpawn(level:LevelEngine, faction:Int):Bool
    {
        return true;
    }
    public override function GetPossibleSpawnGrids(level:LevelEngine, faction:Int, results:Map<LawnGrid, Bool>):Void
    {
        var maxColumn = level.GetMaxColumnCount();
        var maxLane = level.GetMaxLaneCount();
        var friendly = faction == level.Option.LeftFaction;
        var startColumn = friendly ? 0 : maxColumn - 4;
        var endColumn = friendly ? 4 : maxColumn;
        for (x in startColumn...endColumn)
        {
            for (y in 0...maxLane)
            {
                var grid = level.GetGrid(x, y);
                if (grid != null)
                {
                    results.set(grid, true);
                }
            }
        }
    }
    public override function UpdateActionState(entity:Entity, state:Int):Void
    {
        super.UpdateActionState(entity, state);
        switch (state)
        {
            case UFOBehaviour.STATE_STAY:
                UpdateStateStay(entity);
            case UFOBehaviour.STATE_ACT:
                UpdateStateAct(entity);
            case UFOBehaviour.STATE_LEAVE:
                UpdateStateLeave(entity);
        }
    }
    function UpdateStateStay(enemy:Entity):Void
    {
        EnterUpdate(enemy);

        // PORT-NOTE: C# 此处调用的是继承自 UFOBehaviour 的 protected static GetOrInitStateTimer(entity, time)，
        // 不是 LockedChestPickup 的单参数同名方法（Haxe 不继承静态成员，需以基类限定）。
        var timer = UFOBehaviour.GetOrInitStateTimer(enemy, STAY_TIME);
        if (timer.RunToExpiredAndNotNull())
        {
            UndeadFlyingObject.SetUFOState(enemy, UFOBehaviour.STATE_ACT);
            timer.ResetTime(ACT_TIME);
        }
    }
    function UpdateStateAct(enemy:Entity):Void
    {
        EnterUpdate(enemy);

        var timer = UFOBehaviour.GetOrInitStateTimer(enemy, ACT_TIME);
        if (timer == null)
            return;
        timer.Run();
        if (timer.PassedFrameFromMax(RELEASE_ZOMBIE_TIME))
        {
            var enemyID:NamespaceID;
            if (enemy.Level.IsIZombie())
            {
                enemyID = VanillaEnemyID.zombie;
            }
            else
            {
                enemyID = enemyPool.Random(enemy.RNG);
            }
            var param = enemy.GetSpawnParams();
            // C#: param.OnApply += (e) => { ... };
            param.OnApply = function(e:Entity)
            {
                e.AddBuff(SummonedByUFOBuff);
                WhiteFlashBuff.AddToEntity(e, 30);
            };
            enemy.Spawn(enemyID, enemy.Position, param);
        }
        if (timer.Expired)
        {
            UndeadFlyingObject.SetUFOState(enemy, UFOBehaviour.STATE_LEAVE);
        }
    }
    function UpdateStateLeave(enemy:Entity):Void
    {
        LeaveUpdate(enemy);
    }
    public static inline var STAY_TIME:Int = 90;
    public static inline var ACT_TIME:Int = 60;
    public static inline var RELEASE_ZOMBIE_TIME:Int = 30;
    public static var enemyPool:Array<NamespaceID> = [
        VanillaEnemyID.zombie,
        VanillaEnemyID.leatherCappedZombie,
        VanillaEnemyID.ironHelmettedZombie,
    ];
}
