// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleCatzomwareLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;
using tools.EnumerableExt;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleCatzomware)
class PuzzleCatzomwareLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 5);
        Blueprints = ([
            LogicBlueprintID.FromEntity(VanillaEnemyID.imp),
            LogicBlueprintID.FromEntity(VanillaEnemyID.leatherCappedZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.hacker),
            LogicBlueprintID.FromEntity(VanillaEnemyID.zombieCat),
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        Insert(map, 0, 2, VanillaContraptionID.furnace);
        Insert(map, 1, 2, VanillaContraptionID.furnace);
        Insert(map, 2, 2, VanillaContraptionID.magichest);
        Insert(map, 3, 2, VanillaContraptionID.magichest);
        Insert(map, 4, 2, VanillaContraptionID.teslaCoil);

        var lanes = [0, 1, 3, 4];
        lanes.Shuffle(rng);
        for (i in 0...lanes.length)
        {
            var lane = lanes[i];
            switch (i)
            {
                case 0:
                    Insert(map, 4, lane, VanillaContraptionID.stoneEye);
                    RandomFillAtLane(map, lane, VanillaContraptionID.furnace, 2, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.smallDispenser, 2, rng);
                case 1:
                    RandomFillAtLane(map, lane, VanillaContraptionID.furnace, 1, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.transfenser, 1, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.amethystPylon, 1, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.smallDispenser, 1, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.magichest, 1, rng);
                case 2:
                    RandomFillAtLane(map, lane, VanillaContraptionID.furnace, 2, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.transfenser, 1, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.drivenser, 1, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.smallDispenser, 1, rng);
                case 3:
                    RandomFillAtLane(map, lane, VanillaContraptionID.furnace, 1, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.transfenser, 2, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.amethystPylon, 1, rng);
                    RandomFillAtLane(map, lane, VanillaContraptionID.smallDispenser, 1, rng);
            }
        }
    }
}
