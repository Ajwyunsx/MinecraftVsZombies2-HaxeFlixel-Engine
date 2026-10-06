// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE1/IZESpikesLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.izeSpikes)
class IZESpikesLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.woodenDropper, 8, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 9, rng);
    }
}
