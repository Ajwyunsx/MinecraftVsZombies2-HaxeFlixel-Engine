// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleFireInTheHoleLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleFireInTheHole)
class PuzzleFireInTheHoleLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 5);
        Blueprints = ([
            VanillaEnemyID.imp,
            VanillaEnemyID.leatherCappedZombie,
            VanillaEnemyID.reflectiveBarrierZombie,
            VanillaEnemyID.wickedHermitZombie
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillAtColumn(map, 4, VanillaContraptionID.hellfire, 3, rng);

        RandomFillWithCount(map, VanillaContraptionID.magichest, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.splitenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.drivenser, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.dispenser, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 9, rng);
    }
}
