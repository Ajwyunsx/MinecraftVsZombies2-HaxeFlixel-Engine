// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Minigames/WithersRevenge.cs
package mvz2.gamecontent.stages;

import pvzengine.level.StageDefinition;

@:autoStageDefinition(VanillaStageNames.withersRevenge)
class WithersRevenge extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new WitherStageBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
    }
}
