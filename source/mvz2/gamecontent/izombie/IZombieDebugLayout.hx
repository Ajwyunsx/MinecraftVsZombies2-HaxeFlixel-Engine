// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/IZombieDebugLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.iZombieDebug)
class IZombieDebugLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 4);
        Blueprints = ([
            VanillaEnemyID.imp,
            VanillaContraptionID.spikeBlock,
            VanillaContraptionID.smallDispenser
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        for (lane in 0...map.Lanes)
        {
            Insert(map, 2, lane, VanillaContraptionID.spikeBlock);
            Insert(map, 3, lane, VanillaContraptionID.smallDispenser);
        }
    }
}
