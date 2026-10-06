// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE1/IZECompositeLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.izeComposite)
class IZECompositeLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.dispenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.obsidian, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.mineTNT, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.glowstone, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.punchton, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.soulFurnace, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.silvenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.magichest, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.drivenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.gravityPad, 1, rng); // Does not count
        RandomFillWithCount(map, VanillaContraptionID.totenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.dreamCrystal, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.woodenDropper, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.stoneDropper, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.splitenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.hellfire, 1, rng);
    }
}
