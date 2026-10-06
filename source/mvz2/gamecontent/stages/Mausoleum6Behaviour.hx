// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/IZombie/Mausoleum6Behaviour.cs
package mvz2.gamecontent.stages;

import mvz2logic.izombie.IZombieLayoutDefinition;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import tools.RandomGenerator;

class Mausoleum6Behaviour extends IZombieBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function GetNewLayout(round:Int, rng:RandomGenerator):NamespaceID
    {
        switch (round)
        {
            case 0:
                return layout1;
            case 1:
                return layout2;
            default:
                return layout3;
        }
    }

    override public function GetMaxRounds():Int
    {
        return 3;
    }
    override public function ReplaceBlueprints(level:LevelEngine, layout:IZombieLayoutDefinition):Void
    {
        if (layout == null || layout.Blueprints == null)
            return;
        LogicLevelExt.FillSeedPacks(level, layout.Blueprints);
    }
    private var layout1:NamespaceID = VanillaIZombieLayoutID.dispenserPunchton4;
    private var layout2:NamespaceID = VanillaIZombieLayoutID.highAndLow4;
    private var layout3:NamespaceID = VanillaIZombieLayoutID.redAlert5;
}
