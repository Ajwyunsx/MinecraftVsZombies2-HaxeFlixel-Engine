// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Puzzles/PuzzleIZombieEndlessStage.cs
package mvz2.gamecontent.stages;

import pvzengine.level.StageDefinition;

@:autoStageDefinition(VanillaStageNames.puzzleIZombieEndless)
class PuzzleIZombieEndlessStage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new IZombieEndlessBehaviour(this));
    }
}
