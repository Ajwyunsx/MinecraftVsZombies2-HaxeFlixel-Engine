// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Mausoleum6Stage.cs
package mvz2.gamecontent.stages;

import pvzengine.definitions.StageDefinition;

@:autoStageDefinition(VanillaStageNames.mausoleum6)
class Mausoleum6Stage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new Mausoleum6Behaviour(this));
    }
}
