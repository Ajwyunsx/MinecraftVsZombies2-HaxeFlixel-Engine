// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Puzzles/PuzzleIZombieStage.cs
package mvz2.gamecontent.stages;

@:autoStageDefinition(VanillaStageNames.puzzleIZombie)
class PuzzleIZombieStage extends IZombiePuzzleStage
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaIZombieLayoutID.puzzleIZombie);
    }
}
