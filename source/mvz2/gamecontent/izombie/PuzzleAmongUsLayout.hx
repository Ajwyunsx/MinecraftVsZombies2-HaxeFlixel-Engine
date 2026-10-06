// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleAmongUsLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.seeds.VanillaBlueprintID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleAmongUs)
class PuzzleAmongUsLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 5);
        Blueprints = ([
            LogicBlueprintID.FromEntity(VanillaEnemyID.imp),
            LogicBlueprintID.FromEntity(VanillaEnemyID.leatherCappedZombie),
            VanillaBlueprintID.ufoRed,
            LogicBlueprintID.FromEntity(VanillaEnemyID.ironHelmettedZombie)
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        FillColumn(map, 4, VanillaContraptionID.splitenser);
        FillColumn(map, 0, VanillaContraptionID.gravityPad);

        Insert(map, 0, 0, VanillaContraptionID.furnace);
        Insert(map, 0, 1, VanillaContraptionID.soulFurnace);
        Insert(map, 0, 2, VanillaContraptionID.repeatenser);
        Insert(map, 0, 3, VanillaContraptionID.furnace);
        Insert(map, 0, 4, VanillaContraptionID.furnace);

        Insert(map, 1, 4, VanillaContraptionID.noteBlock);
        Insert(map, 2, 4, VanillaContraptionID.gunpowderBarrel);
        Insert(map, 3, 4, VanillaContraptionID.furnace);
        Insert(map, 1, 3, VanillaContraptionID.repeatenser);
        Insert(map, 2, 3, VanillaContraptionID.furnace);
        Insert(map, 3, 3, VanillaContraptionID.triplenser);

        Insert(map, 1, 1, VanillaContraptionID.gunpowderBarrel);
        Insert(map, 1, 1, VanillaContraptionID.stoneShield);
        Insert(map, 2, 1, VanillaContraptionID.furnace);
        Insert(map, 3, 1, VanillaContraptionID.repeatenser);

        RandomFillWithCount(map, VanillaContraptionID.repeatenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.triplenser, 3, rng);
        // RandomFill(map, VanillaContraptionID.splitenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 2, rng);
    }
}
