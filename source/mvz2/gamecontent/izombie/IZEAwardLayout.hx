// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/Awards/IZEAwardLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.izeAwards)
class IZEAwardLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.mineTNT, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.smallDispenser, 7, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 2, rng);
    }
}
