// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE2/IZE2CompositeLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.ize2Composite)
class IZE2CompositeLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.pistenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.punchton, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.silvenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.magichest, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.gravityPad, 1, rng); // Does not count
        RandomFillWithCount(map, VanillaContraptionID.totenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.woodenDropper, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.hellfire, 1, rng);

        // Chapter 5
        RandomFillWithCount(map, VanillaContraptionID.triplenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.fireworkDispenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.repeatenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.beacon, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.elasticCloud, 1, rng);

        // Chapter 6
        RandomFillWithCount(map, VanillaContraptionID.transfenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.gravelpult, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.cursedCandle, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.stoneEye, 1, rng);
    }
}
