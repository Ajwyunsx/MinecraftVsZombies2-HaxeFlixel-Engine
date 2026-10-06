// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE1/IZEControlLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.izeControl)
class IZEControlLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.hellfire, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.drivenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.stoneDropper, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.splitenser, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.woodenDropper, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.glowstone, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.soulFurnace, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.dreamCrystal, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.gravityPad, 2, rng);
    }
}
