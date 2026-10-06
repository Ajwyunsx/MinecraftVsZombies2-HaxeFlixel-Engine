// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/UFOBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import tools.FrameTimer;

// abstract
class UFOBehaviour
{
    public function new(type:Int)
    {
        Type = type;
    }
    public function CanSpawn(level:LevelEngine, faction:Int):Bool return false;
    public function GetPossibleSpawnGrids(level:LevelEngine, faction:Int, results:Map<LawnGrid, Bool>):Void
    {
        var maxColumn = level.GetMaxColumnCount();
        var maxLane = level.GetMaxLaneCount();
        for (x in 0...maxColumn)
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
    public function UpdateActionState(entity:Entity, state:Int):Void
    {
    }
    public function UpdateLogic(entity:Entity):Void
    {
    }
    public function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
    }
    function EnterUpdate(entity:Entity):Void UndeadFlyingObject.EnterUpdate(entity);
    function LeaveUpdate(entity:Entity):Void UndeadFlyingObject.LeaveUpdate(entity);
    static function GetOrInitStateTimer(entity:Entity, time:Int):Null<FrameTimer>
    {
        var timer = GetStateTimer(entity);
        if (timer == null)
        {
            timer = new FrameTimer(time);
            SetStateTimer(entity, timer);
        }
        return timer;
    }
    static function GetStateTimer(entity:Entity):Null<FrameTimer> return UndeadFlyingObject.GetStateTimer(entity);
    static function SetStateTimer(entity:Entity, value:FrameTimer):Void UndeadFlyingObject.SetStateTimer(entity, value);
    static function GetUFOState(entity:Entity):Int return UndeadFlyingObject.GetUFOState(entity);
    static function SetUFOState(entity:Entity, value:Int):Void UndeadFlyingObject.SetUFOState(entity, value);


    public static inline var STATE_STAY:Int = UndeadFlyingObject.STATE_STAY;
    public static inline var STATE_ACT:Int = UndeadFlyingObject.STATE_ACT;
    public static inline var STATE_LEAVE:Int = UndeadFlyingObject.STATE_LEAVE;
    public var Type(default, null):Int;
}
