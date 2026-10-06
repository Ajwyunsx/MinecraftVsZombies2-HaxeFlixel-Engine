// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/IZombie/IZombiePuzzleBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2logic.izombie.IZombieLayoutDefinition;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import tools.RandomGenerator;

class IZombiePuzzleBehaviour extends IZombieBehaviour
{
    public function new(stageDef:StageDefinition, layout:NamespaceID)
    {
        super(stageDef);
        this.layout = layout;
    }
    override public function GetNewLayout(round:Int, rng:RandomGenerator):NamespaceID
    {
        return layout;
    }

    override public function GetMaxRounds():Int
    {
        return 1;
    }
    override public function ReplaceBlueprints(level:LevelEngine, layout:IZombieLayoutDefinition):Void
    {
        if (layout == null || layout.Blueprints == null)
            return;
        LogicLevelExt.FillSeedPacks(level, layout.Blueprints);
    }
    private var layout:NamespaceID;
}
