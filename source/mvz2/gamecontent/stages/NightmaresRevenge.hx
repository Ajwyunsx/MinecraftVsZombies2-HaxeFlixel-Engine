// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Minigames/NightmaresRevenge.cs
package mvz2.gamecontent.stages;

import pvzengine.level.StageDefinition;

@:autoStageDefinition(VanillaStageNames.nightmaresRevenge)
class NightmaresRevenge extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new NightmareStageBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
    }
}
