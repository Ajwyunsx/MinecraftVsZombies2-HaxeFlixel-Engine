// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/FinalClear/FinalWaveClearBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.level.VanillaLevelStates;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;

class FinalWaveClearBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }

    override public function Update(level:LevelEngine):Void
    {
        switch (level.WaveState)
        {
            case VanillaLevelStates.STATE_FINAL_WAVE:
                VanillaLevelExt.CheckClearUpdate(level);
        }
    }
}
