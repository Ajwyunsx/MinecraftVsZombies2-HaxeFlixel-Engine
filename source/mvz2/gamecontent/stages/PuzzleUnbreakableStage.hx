// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Puzzles/PuzzleUnbreakableStage.cs
package mvz2.gamecontent.stages;

@:autoStageDefinition(VanillaStageNames.puzzleUnbreakable)
class PuzzleUnbreakableStage extends IZombiePuzzleStage
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaIZombieLayoutID.puzzleUnbreakable);
    }
}
