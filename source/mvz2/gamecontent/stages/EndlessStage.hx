// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/EndlessStage.cs
package mvz2.gamecontent.stages;

import pvzengine.definitions.StageDefinition;

class EndlessStage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        // C#: new WaveStageBehaviour(this) { HasFinalWave = false }
        var waveStageBehaviour = new WaveStageBehaviour(this);
        waveStageBehaviour.HasFinalWave = false;
        AddBehaviour(waveStageBehaviour);
        AddBehaviour(new EndlessStageBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
    }
}
