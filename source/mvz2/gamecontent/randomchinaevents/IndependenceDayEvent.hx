// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/IndependenceDayEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.enemies.UndeadFlyingObject;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import tools.EnumerableExt;
import tools.RandomGenerator;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.independenceDay)
class IndependenceDayEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;

        var variant = UndeadFlyingObject.VARIANT_RED;

        // PORT-NOTE: C# HashSet<LawnGrid> → Haxe Map<LawnGrid, Bool>，传给 FilterConflictSpawnGrids 前转为数组。
        var possibleGrids:Map<LawnGrid, Bool> = new Map();
        possibleGrids.clear();
        UndeadFlyingObject.FillUFOPossibleSpawnGrids(level, variant, level.Option.RightFaction, possibleGrids);

        var possibleGridList = [for (grid in possibleGrids.keys()) grid];
        var filteredGrids = UndeadFlyingObject.FilterConflictSpawnGrids(level, possibleGridList);

        var grids = EnumerableExt.RandomTake(filteredGrids, SPAWN_COUNT, rng);
        for (grid in grids)
        {
            UndeadFlyingObject.SpawnAtGrid(grid, variant);
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "独立日";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "生成10个红色不死飞行物";
    public static inline var SPAWN_COUNT:Int = 10;
}
