// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Puzzles/IZombiePuzzleStage.cs
package mvz2.gamecontent.stages;

import pvzengine.NamespaceID;
import pvzengine.level.StageDefinition;

// abstract
class IZombiePuzzleStage extends StageDefinition
{
    public function new(nsp:String, name:String, layout:NamespaceID)
    {
        super(nsp, name);
        AddBehaviour(new IZombiePuzzleBehaviour(this, layout));
    }
}
