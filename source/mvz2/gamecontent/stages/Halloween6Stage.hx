// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Halloween6Stage.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.stages.RedstoneStageBehaviour.RedstoneDropStageBehaviour;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.definitions.StageDefinition;
import pvzengine.level.LevelEngine;

@:autoStageDefinition(VanillaStageNames.halloween6)
class Halloween6Stage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        var waveStageBehaviour = new WaveStageBehaviour(this);
        waveStageBehaviour.SpawnFlagZombie = false;
        AddBehaviour(waveStageBehaviour);
        AddBehaviour(new WhackAGhostBehaviour(this));
        AddBehaviour(new FinalWaveClearBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
        AddBehaviour(new RedstoneDropStageBehaviour(this));
        AddBehaviour(new SpeedUpStageBehaviour(this, 3, 5));
    }
    override public function OnSetup(level:LevelEngine):Void
    {
        super.OnSetup(level);
        mvz2.vanilla.level.VanillaLevelExt.StartRain(level);
    }
    override public function OnStart(level:LevelEngine):Void
    {
        super.OnStart(level);

        level.SetSeedSlotCount(3);
        LogicLevelExt.FillSeedPacks(level, [
            LogicBlueprintID.FromEntity(VanillaContraptionID.glowstone),
            LogicBlueprintID.FromEntity(VanillaContraptionID.obsidian),
            LogicBlueprintID.FromEntity(VanillaContraptionID.punchton),
        ]);
    }
}
