// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleUnbreakableLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;
using tools.EnumerableExt;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleUnbreakable)
class PuzzleUnbreakableLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 5);
        Blueprints = ([
            VanillaEnemyID.zombie,
            VanillaEnemyID.gargoyle,
            VanillaEnemyID.dullahan,
            VanillaEnemyID.hellChariot
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        var oddLanes:Array<Int> = [0, 0, 0];
        for (i in 0...oddLanes.length)
        {
            oddLanes[i] = i;
        }
        var shuffledOddLanes = oddLanes.Randomize(rng);
        for (lane in 0...map.Lanes)
        {
            var odd = lane % 2 == 0;
            for (column in 0...Columns)
            {
                var id:NamespaceID;
                if (odd)
                {
                    id = column <= 1 ? VanillaContraptionID.furnace : VanillaContraptionID.stoneShield;
                }
                else
                {
                    id = column >= 3 ? VanillaContraptionID.furnace : VanillaContraptionID.stoneShield;
                }
                Insert(map, column, lane, id);
            }
            if (odd)
            {
                // PORT-NOTE: C# 的 LINQ ElementAtOrDefault 由显式索引检查等价实现。
                var contraptionLaneIndex = Std.int(lane / 2);
                var contraptionLane = contraptionLaneIndex < shuffledOddLanes.length ? shuffledOddLanes[contraptionLaneIndex] : 0;
                switch (contraptionLane)
                {
                    case LANE_TOTENSERS:
                        RandomFillAtLane(map, lane, VanillaContraptionID.totenser, 3, rng);
                    case LANE_SILVENSERS:
                        RandomFillAtLane(map, lane, VanillaContraptionID.silvenser, 3, rng);
                    case LANE_DRIVENSERS:
                        RandomFillAtLane(map, lane, VanillaContraptionID.drivenser, 3, rng);
                }
            }
            else
            {
                RandomFillAtLane(map, lane, VanillaContraptionID.punchton, 1, rng);
                RandomFillAtLane(map, lane, VanillaContraptionID.spikeBlock, 1, rng);
                RandomFillAtLane(map, lane, VanillaContraptionID.mineTNT, 1, rng);
            }
        }
    }
    public static inline var LANE_TOTENSERS:Int = 0;
    public static inline var LANE_SILVENSERS:Int = 1;
    public static inline var LANE_DRIVENSERS:Int = 2;
}
