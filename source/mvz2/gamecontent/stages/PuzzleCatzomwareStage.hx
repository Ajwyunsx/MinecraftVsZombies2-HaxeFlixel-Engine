// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Puzzles/PuzzleCatzomwareStage.cs
package mvz2.gamecontent.stages;

@:autoStageDefinition(VanillaStageNames.puzzleCatzomware)
class PuzzleCatzomwareStage extends IZombiePuzzleStage
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaIZombieLayoutID.puzzleCatzomware);
    }
}
