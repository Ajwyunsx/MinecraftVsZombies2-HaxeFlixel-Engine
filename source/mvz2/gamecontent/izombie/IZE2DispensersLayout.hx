// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE2/IZE2DispensersLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.ize2Dispensers)
class IZE2DispensersLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.gravityPad, 3, rng);

        RandomFillWithCount(map, VanillaContraptionID.dispenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.drivenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.silvenser, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.pistenser, 5, rng);
        RandomFillWithCount(map, VanillaContraptionID.totenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.triplenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.repeatenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.transfenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.gunpowderBarrel, 1, rng);
    }
}
