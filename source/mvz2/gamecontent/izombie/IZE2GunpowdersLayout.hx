// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/Awards/IZE2GunpowdersLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.ize2Gunpowder)
class IZE2GunpowdersLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.gunpowderBarrel, 15, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 2, rng);
    }
}
