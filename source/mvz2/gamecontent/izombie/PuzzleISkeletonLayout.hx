// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/Puzzles/PuzzleISkeletonLayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.stages.VanillaIZombieLayoutID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import pvzengine.NamespaceID;
import tools.RandomGenerator;

@:autoIZombieLayoutDefinition(VanillaIZombieLayoutNames.puzzleISkeleton)
class PuzzleISkeletonLayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 4);
        Blueprints = ([
            VanillaEnemyID.skeleton,
            VanillaEnemyID.ghost,
            VanillaEnemyID.necromancer,
            VanillaEnemyID.dullahan
        ] : Array<NamespaceID>);
    }
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        Insert(map, 3, 2, VanillaContraptionID.glowstone);
        RandomFillAtLane(map, 2, VanillaContraptionID.teslaCoil, 1, rng);
        RandomFillAtLane(map, 2, VanillaContraptionID.furnace, 2, rng);

        RandomFillWithCount(map, VanillaContraptionID.soulFurnace, 2, rng);
        RandomFillWithCount(map, VanillaContraptionID.mineTNT, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.dispenser, 4, rng);
        RandomFillWithCount(map, VanillaContraptionID.furnace, 6, rng);
    }
}
