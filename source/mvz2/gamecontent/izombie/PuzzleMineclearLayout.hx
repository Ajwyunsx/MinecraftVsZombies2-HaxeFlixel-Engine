// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleMineclearLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleMineclear)
class PuzzleMineclearLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 5);
        Blueprints = ([
            VanillaEnemyID.imp,
            VanillaEnemyID.ghost,
            VanillaEnemyID.emperorZombie,
            VanillaEnemyID.necromancer
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.mineTNT, 9, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.punchton, 5, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 8, rng);
    }
}
