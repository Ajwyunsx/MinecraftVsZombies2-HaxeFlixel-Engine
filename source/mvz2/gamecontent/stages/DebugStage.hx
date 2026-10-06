// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/DebugStage.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.progressbars.VanillaProgressBarID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.StageDefinition;
import pvzengine.level.LevelEngine;

@:autoStageDefinition(VanillaStageNames.debug)
class DebugStage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        //AddBehaviour(new ConveyorStageBehaviour(this));
    }
    override public function OnStart(level:LevelEngine):Void
    {
        super.OnStart(level);
        ClassicStart(level);
        //ConveyorStart(level);
        level.LevelProgressVisible = true;
        LogicLevelExt.SetProgressBarToBoss(level, VanillaProgressBarID.lockedChest);
        LogicLevelExt.SetTriggerActive(level, true);
        mvz2logic.level.LogicLevelProps.SetStarshardSlotCount(level, 5);
        mvz2.vanilla.level.VanillaLevelExt.RefreshCarts(level);

        pvzengine.buffs.BuffExt.AddBuff(level, VanillaBuffID.Level.debugEnergy);
        pvzengine.buffs.BuffExt.AddBuff(level, VanillaBuffID.Level.debugGodmode);
        pvzengine.buffs.BuffExt.AddBuff(level, VanillaBuffID.Level.debugNoRecharge);
        pvzengine.buffs.BuffExt.AddBuff(level, VanillaBuffID.Level.debugStarshard);
    }
    override public function OnUpdate(level:LevelEngine):Void
    {
        super.OnUpdate(level);
        mvz2.vanilla.level.VanillaLevelExt.CheckGameOver(level);
    }
    private function ClassicStart(level:LevelEngine):Void
    {
        level.SetEnergy(9990);
        level.SetSeedSlotCount(10);
        LogicLevelExt.FillSeedPacks(level, [
            VanillaContraptionID.dispenser,
            VanillaContraptionID.tnt,
            VanillaContraptionID.obsidian,
            VanillaContraptionID.gravityPad,
            VanillaContraptionID.forcePad,
            VanillaContraptionID.beacon,
            VanillaContraptionID.skywardBeacon,
            VanillaEnemyID.zombie,
            VanillaEnemyID.ironHelmettedZombie,
            VanillaEnemyID.mesmerizer,
        ]);
        LogicLevelExt.SetArtifactSlotCount(level, 3);
    }
    private function ConveyorStart(level:LevelEngine):Void
    {
        level.SetConveyorSlotCount(10);
        level.AddConveyorSeedPack(VanillaBossID.slenderman);
    }
}
