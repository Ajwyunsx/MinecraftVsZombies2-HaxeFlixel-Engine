// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Dream11.cs
package mvz2.gamecontent.stages;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.StageDefinition;

@:autoStageDefinition(VanillaStageNames.dream11)
class Dream11 extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new NightmareStageBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
        AddBehaviour(new ConveyorStageBehaviour(this));

        mvz2logic.level.LogicStageProps.SetClearSound(this, VanillaSoundID.finalItem);
    }
}
