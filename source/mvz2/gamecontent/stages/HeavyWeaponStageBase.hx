// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Minigames/HeavyWeaponStageBase.cs
package mvz2.gamecontent.stages;

import mvz2logic.level.LogicLevelExt;
import mvz2.gamecontent.stages.RedstoneStageBehaviour.RedstoneDropStageBehaviour;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;

// abstract
class HeavyWeaponStageBase extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new FinalWaveClearBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new RedstoneDropStageBehaviour(this));
        AddBehaviour(new HeavyWeaponStageBehaviour(this));
        AddBehaviour(new SpeedUpStageBehaviour(this, 1.5, 2));
    }
    override public function OnStart(level:LevelEngine):Void
    {
        super.OnStart(level);
        var blueprints = GetBlueprintsID();
        level.SetSeedSlotCount(blueprints.length);
        LogicLevelExt.FillSeedPacks(level, blueprints);
    }
    // abstract
    public function GetBlueprintsID():Array<NamespaceID>
    {
        throw "abstract";
    }
}
