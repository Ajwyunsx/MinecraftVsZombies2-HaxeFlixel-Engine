// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/DispenserPuntchtonLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.dispenserPunchton4)
class DispenserPuntchtonLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 4);
        Blueprints = ([
            VanillaEnemyID.zombie,
            VanillaEnemyID.gargoyle,
            VanillaEnemyID.ironHelmettedZombie
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        RandomFillWithCount(map, VanillaContraptionID.dispenser, 5, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 8, rng);
        RandomFillWithCount(map, VanillaContraptionID.silvenser, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.punchton, 3, rng);
    }
}
