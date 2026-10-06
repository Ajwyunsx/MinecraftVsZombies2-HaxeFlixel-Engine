// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE2/IZE2FireLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.ize2Fire)
class IZE2FireLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.soulFurnace, 5, rng);
        RandomFillWithCount(map, VanillaContraptionID.woodenDropper, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.totenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.hellfire, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.repeatenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.transfenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.fireworkDispenser, 1, rng);
    }
}
