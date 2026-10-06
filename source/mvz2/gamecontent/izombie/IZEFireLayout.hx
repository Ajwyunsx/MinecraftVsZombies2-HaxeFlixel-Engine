// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE1/IZEFireLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.izeFire)
class IZEFireLayout extends IZELayout
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.smallDispenser, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.soulFurnace, 5, rng);
        RandomFillWithCount(map, VanillaContraptionID.dispenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.splitenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.totenser, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.hellfire, 3, rng);
    }
}
