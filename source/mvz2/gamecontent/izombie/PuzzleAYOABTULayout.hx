// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleAYOABTULayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleAllYourObservesAreBelongToUs)
class PuzzleAYOABTULayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 6);
        Blueprints = ([
            LogicBlueprintID.FromEntity(VanillaEnemyID.imp),
            LogicBlueprintID.FromEntity(VanillaEnemyID.leatherCappedZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.ghost),
            LogicBlueprintID.FromEntity(VanillaEnemyID.reflectiveBarrierZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.ironHelmettedZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.skeletonWarrior),
            LogicBlueprintID.FromEntity(VanillaEnemyID.wickedHermitZombie),
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillAtLane(map, 0, VanillaContraptionID.mineTNT, 4, rng);

        Insert(map, 0, 1, VanillaContraptionID.noteBlock);
        Insert(map, 5, 1, VanillaContraptionID.dreamCrystal);
        RandomFillAtLane(map, 1, VanillaContraptionID.stoneDropper, 1, rng);
        RandomFillAtLane(map, 1, VanillaContraptionID.woodenDropper, 1, rng);

        RandomFillAtLane(map, 2, VanillaContraptionID.punchton, 1, rng);
        RandomFillAtLane(map, 2, VanillaContraptionID.magichest, 3, rng);

        Insert(map, 5, 3, VanillaContraptionID.hellfire);
        RandomFillAtLane(map, 3, VanillaContraptionID.dispenser, 3, rng);

        RandomFillAtLane(map, 4, VanillaContraptionID.splitenser, 1, rng);
        RandomFillAtLane(map, 4, VanillaContraptionID.totenser, 1, rng);
        RandomFillAtLane(map, 4, VanillaContraptionID.smallDispenser, 1, rng);
        RandomFillAtLane(map, 4, VanillaContraptionID.soulFurnace, 1, rng);
        RandomFillAtLane(map, 4, VanillaContraptionID.silvenser, 1, rng);


        RandomFillWithCount(map, VanillaContraptionID.furnace, 9, rng);
    }
}
