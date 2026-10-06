// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE1/IZEDispensersLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.izeDispensers)
class IZEDispensersLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.dispenser, 6, rng);
        RandomFillWithCount(map, VanillaContraptionID.drivenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.splitenser, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.silvenser, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.totenser, 1, rng);
    }
}
