// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE2/IZE2SpectralLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.ize2Spectral)
class IZE2SpectralLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.soulFurnace, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.gravityPad, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.transfenser, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.beacon, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.amethystPylon, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.cursedCandle, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.gunpowderBarrel, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.glowstone, 2, rng);
    }
}
