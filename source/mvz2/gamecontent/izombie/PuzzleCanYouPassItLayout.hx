// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleCanYouPassItLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleCanYouPassIt)
class PuzzleCanYouPassItLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 4);
        Blueprints = ([
            VanillaEnemyID.zombie,
            VanillaEnemyID.ironHelmettedZombie,
            VanillaEnemyID.wickedHermitZombie
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillAtColumn(map, 0, VanillaContraptionID.splitenser, 1, rng);
        RandomFillAtColumn(map, 0, VanillaContraptionID.magichest, 1, rng);
        RandomFillAtColumn(map, 0, VanillaContraptionID.punchton, 1, rng);
        RandomFillAtColumn(map, 0, VanillaContraptionID.totenser, 1, rng);
        RandomFillAtColumn(map, 0, VanillaContraptionID.furnace, 1, rng);

        RandomFillWithCount(map, VanillaContraptionID.splitenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.magichest, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.punchton, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.totenser, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 6, rng);
    }
}
