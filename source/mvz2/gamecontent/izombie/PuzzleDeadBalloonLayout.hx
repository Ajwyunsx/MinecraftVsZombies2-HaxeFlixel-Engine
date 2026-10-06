// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleDeadBalloonLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleDeadBalloon)
class PuzzleDeadBalloonLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 4);
        Blueprints = ([
            VanillaEnemyID.zombie,
            VanillaEnemyID.leatherCappedZombie,
            VanillaEnemyID.ghast
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        Insert(map, 0, 2, VanillaContraptionID.totenser);
        Insert(map, 1, 2, VanillaContraptionID.furnace);
        Insert(map, 2, 2, VanillaContraptionID.furnace);
        Insert(map, 3, 2, VanillaContraptionID.teslaCoil);

        var lane1 = 0;
        var lane2 = 0;
        while (lane1 == lane2 || lane1 == 2 || lane2 == 2)
        {
            lane1 = rng.Next(0, 5);
            lane2 = rng.Next(0, 5);
        }
        var column1 = rng.Next(0, 2);
        var column2 = rng.Next(0, 2);
        Insert(map, column1, lane1, VanillaContraptionID.soulFurnace);
        Insert(map, column2, lane2, VanillaContraptionID.soulFurnace);
        Insert(map, column1 + 1, lane1, VanillaContraptionID.pistenser);
        Insert(map, column2 + 1, lane2, VanillaContraptionID.pistenser);

        RandomFillAtColumn(map, 3, VanillaContraptionID.pistenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.magichest, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.soulFurnace, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 6, rng);
    }
}
