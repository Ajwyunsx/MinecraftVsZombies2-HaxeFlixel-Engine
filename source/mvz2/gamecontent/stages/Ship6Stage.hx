// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Ship6Stage.cs
package mvz2.gamecontent.stages;

import pvzengine.definitions.StageDefinition;

@:autoStageDefinition(VanillaStageNames.ship6)
class Ship6Stage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new UFOBlitzStageBehaviour(this));
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new FinalWaveClearBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
        AddBehaviour(new ConveyorStageBehaviour(this));
    }
}
