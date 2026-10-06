// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/SeijaStage.cs
package mvz2.gamecontent.stages;

import pvzengine.definitions.StageDefinition;

@:autoStageDefinition(VanillaStageNames.castle7)
class SeijaStage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new SeijaStageBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
    }
}
