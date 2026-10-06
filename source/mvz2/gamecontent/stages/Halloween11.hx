// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Halloween11.cs
package mvz2.gamecontent.stages;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.StageDefinition;

@:autoStageDefinition(VanillaStageNames.halloween11)
class Halloween11 extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new FrankensteinStageBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
        AddBehaviour(new ConveyorStageBehaviour(this));

        mvz2logic.level.LogicStageProps.SetClearSound(this, VanillaSoundID.finalItem);
    }
}
