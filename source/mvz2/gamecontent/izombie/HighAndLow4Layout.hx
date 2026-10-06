// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/HighAndLow4Layout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.highAndLow4)
class HighAndLow4Layout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 4);
        Blueprints = ([
            VanillaEnemyID.zombie,
            VanillaEnemyID.leatherCappedZombie,
            VanillaEnemyID.ghast,
            VanillaEnemyID.caveSpider
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.furnace, 8, rng);
        RandomFillWithCount(map, VanillaContraptionID.pistenser, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.dispenser, 7, rng);
        RandomFillWithCount(map, VanillaContraptionID.gravityPad, 4, rng);
    }
}
