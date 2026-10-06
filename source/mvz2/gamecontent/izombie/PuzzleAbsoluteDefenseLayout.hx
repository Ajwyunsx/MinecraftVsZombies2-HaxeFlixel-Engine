// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleAbsoluteDefenseLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleAbsoluteDefense)
class PuzzleAbsoluteDefenseLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 4);
        Blueprints = ([
            VanillaEnemyID.zombie,
            VanillaEnemyID.mummy,
            VanillaEnemyID.ironHelmettedZombie,
            VanillaEnemyID.caveSpider
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        for (lane in 0...map.Lanes)
        {
            Insert(map, 3, lane, VanillaContraptionID.obsidian);
        }
        Insert(map, 0, 2, VanillaContraptionID.drivenser);
        Insert(map, 1, 2, VanillaContraptionID.drivenser);
        Insert(map, 2, 2, VanillaContraptionID.drivenser);
        Insert(map, 3, 2, VanillaContraptionID.gravityPad);

        RandomFillAtColumn(map, 0, VanillaContraptionID.totenser, 1, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 6, rng);
        RandomFillWithCount(map, VanillaContraptionID.dispenser, 3, rng);
        RandomFillWithCount(map, VanillaContraptionID.silvenser, 2, rng);
    }
}
