// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE2/IZE2ControlLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.ize2Control)
class IZE2ControlLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.hellfire, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.gravityPad, 2, rng); // Does not count.

        RandomFillWithCount(map, VanillaContraptionID.drivenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.triplenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.repeatenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.transfenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.woodenDropper, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.pistenser, 1, rng);

        RandomFillWithCount(map, VanillaContraptionID.stoneDropper, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.gravelpult, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.fireworkDispenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.stoneEye, 2, rng);
    }
}
