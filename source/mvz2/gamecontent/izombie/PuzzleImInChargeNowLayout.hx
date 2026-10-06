// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleImInChargeNowLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleImInChargeNow)
class PuzzleImInChargeNowLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 5);
        Blueprints = ([
            LogicBlueprintID.FromEntity(VanillaEnemyID.imp),
            LogicBlueprintID.FromEntity(VanillaEnemyID.zombieCloud),
            LogicBlueprintID.FromEntity(VanillaEnemyID.ironHelmettedZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.cannoneerZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.popCaptain),
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        Insert(map, 4, 2, VanillaContraptionID.elasticCloud);
        RandomFillAtLane(map, 2, VanillaContraptionID.pistenser, 1, rng);
        RandomFillAtLane(map, 2, VanillaContraptionID.repeatenser, 1, rng);
        FillLane(map, 2, VanillaContraptionID.furnace);

        Insert(map, 0, 3, VanillaContraptionID.fireworkDispenser);
        Insert(map, 4, 3, VanillaContraptionID.obsidian);
        FillLane(map, 3, VanillaContraptionID.furnace);

        RandomFillAtLane(map, 4, VanillaContraptionID.furnace, 3, rng);
        RandomFillAtLane(map, 4, VanillaContraptionID.beacon, 2, rng);

        RandomFillWithCount(map, VanillaContraptionID.dispenser, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.repeatenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.triplenser, 2, rng);

        RandomFillWithCount(map, VanillaContraptionID.pistenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.smallDispenser, 3, rng);
    }
}
