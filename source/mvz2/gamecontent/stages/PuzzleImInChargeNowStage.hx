// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Puzzles/PuzzleImInChargeNowStage.cs
package mvz2.gamecontent.stages;

@:autoStageDefinition(VanillaStageNames.puzzleImInChargeNow)
class PuzzleImInChargeNowStage extends IZombiePuzzleStage
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaIZombieLayoutID.puzzleImInChargeNow);
    }
}
