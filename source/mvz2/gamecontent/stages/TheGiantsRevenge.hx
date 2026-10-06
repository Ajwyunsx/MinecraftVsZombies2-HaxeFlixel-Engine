// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Minigames/TheGiantsRevenge.cs
package mvz2.gamecontent.stages;

import pvzengine.level.StageDefinition;

@:autoStageDefinition(VanillaStageNames.theGiantsRevenge)
class TheGiantsRevenge extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new GiantStageBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
    }
}
