// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE1/IZEInstakillLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.izeInstakill)
class IZEInstakillLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.magichest, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.mineTNT, 6, rng);
        RandomFillWithCount(map, VanillaContraptionID.punchton, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.totenser, 2, rng);
    }
}
