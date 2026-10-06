// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/ClassicStage.cs
package mvz2.gamecontent.stages;

import pvzengine.definitions.StageDefinition;

class ClassicStage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new FinalWaveClearBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
    }
}
