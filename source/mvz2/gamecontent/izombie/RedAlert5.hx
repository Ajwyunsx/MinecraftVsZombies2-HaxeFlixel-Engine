// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/RedAlert5.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.redAlert5)
class RedAlert5 extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 5);
        Blueprints = ([
            VanillaEnemyID.zombie,
            VanillaEnemyID.leatherCappedZombie,
            VanillaEnemyID.mesmerizer,
            VanillaEnemyID.berserker,
            VanillaEnemyID.dullahan,
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        for (i in 0...map.Lanes)
        {
            Insert(map, 4, i, VanillaContraptionID.obsidian);
        }
        Insert(map, 3, 0, VanillaContraptionID.glowstone);
        Insert(map, 3, 4, VanillaContraptionID.glowstone);
        Insert(map, 2, 1, VanillaContraptionID.teslaCoil);
        Insert(map, 2, 3, VanillaContraptionID.teslaCoil);

        RandomFillWithCount(map, VanillaContraptionID.furnace, 8, rng);
        RandomFillWithCount(map, VanillaContraptionID.mineTNT, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.spikeBlock, 4, rng);
    }
}
