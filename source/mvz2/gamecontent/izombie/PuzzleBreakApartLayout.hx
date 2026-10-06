// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleBreakApartLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleBreakApart)
class PuzzleBreakApartLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 5);
        Blueprints = ([
            LogicBlueprintID.FromEntity(VanillaEnemyID.imp),
            LogicBlueprintID.FromEntity(VanillaEnemyID.leatherCappedZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.skeletonStatue),
            LogicBlueprintID.FromEntity(VanillaEnemyID.shadowCell),
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        Insert(map, 0, 0, VanillaContraptionID.smallDispenser);
        Insert(map, 1, 0, VanillaContraptionID.punchton);
        Insert(map, 4, 0, VanillaContraptionID.stoneDropper);
        Insert(map, rng.Next(2, 4), 0, VanillaContraptionID.furnace);
        RandomFillAtLane(map, 0, VanillaContraptionID.spikeBlock, 1, rng);

        Insert(map, 0, 3, VanillaContraptionID.drivenser);
        Insert(map, 1, 3, VanillaContraptionID.drivenser);
        Insert(map, 2, 3, VanillaContraptionID.splitenser);
        Insert(map, 2, 3, VanillaContraptionID.gravityPad);
        Insert(map, 3, 3, VanillaContraptionID.furnace);
        Insert(map, 4, 3, VanillaContraptionID.furnace);

        Insert(map, 0, 4, VanillaContraptionID.furnace);
        Insert(map, 1, 4, VanillaContraptionID.furnace);
        Insert(map, 2, 4, VanillaContraptionID.transfenser);
        Insert(map, 3, 4, VanillaContraptionID.cursedCandle);
        Insert(map, 4, 4, VanillaContraptionID.smallDispenser);

        Insert(map, 0, 1, VanillaContraptionID.furnace);
        Insert(map, 0, 2, VanillaContraptionID.furnace);
        Insert(map, 1, 2, VanillaContraptionID.furnace);
        Insert(map, 0, 2, VanillaContraptionID.gravityPad);

        RandomFillWithCount(map, VanillaContraptionID.transfenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.gravelpult, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.splitenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.smallDispenser, 2, rng);
    }
}
