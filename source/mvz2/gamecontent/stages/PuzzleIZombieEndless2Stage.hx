// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Puzzles/PuzzleIZombieEndless2Stage.cs
package mvz2.gamecontent.stages;

import pvzengine.level.StageDefinition;

@:autoStageDefinition(VanillaStageNames.puzzleIZombieEndless2)
class PuzzleIZombieEndless2Stage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new IZombieEndless2Behaviour(this));
    }
}
