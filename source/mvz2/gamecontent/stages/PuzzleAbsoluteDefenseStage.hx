// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Puzzles/PuzzleAbsoluteDefenseStage.cs
package mvz2.gamecontent.stages;

@:autoStageDefinition(VanillaStageNames.puzzleAbsoluteDefense)
class PuzzleAbsoluteDefenseStage extends IZombiePuzzleStage
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaIZombieLayoutID.puzzleAbsoluteDefense);
    }
}
