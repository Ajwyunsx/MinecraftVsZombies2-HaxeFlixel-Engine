// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE2/IZE2ImpaleLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.ize2Impale)
class IZE2ImpaleLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.gravityPad, 5, rng);

        RandomFillWithCount(map, VanillaContraptionID.silvenser, 10, rng);
        RandomFillWithCount(map, VanillaContraptionID.pistenser, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.stoneEye, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.totenser, 2, rng);
    }
}
