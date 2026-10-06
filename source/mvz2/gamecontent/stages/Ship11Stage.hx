// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Ship11Stage.cs
package mvz2.gamecontent.stages;

import pvzengine.definitions.StageDefinition;

@:autoStageDefinition(VanillaStageNames.ship11)
class Ship11Stage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new RedDragonStageBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
        AddBehaviour(new ConveyorStageBehaviour(this));
    }
}
