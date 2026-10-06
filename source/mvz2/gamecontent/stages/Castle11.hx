// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Castle11.cs
package mvz2.gamecontent.stages;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.StageDefinition;

@:autoStageDefinition(VanillaStageNames.castle11)
class Castle11 extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new WitherStageBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
        AddBehaviour(new ConveyorStageBehaviour(this));

        mvz2logic.level.LogicStageProps.SetClearSound(this, VanillaSoundID.finalItem);
    }
}
