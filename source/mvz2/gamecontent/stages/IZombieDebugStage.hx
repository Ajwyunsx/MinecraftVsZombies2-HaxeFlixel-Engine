// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Puzzles/IZombieDebugStage.cs
package mvz2.gamecontent.stages;

@:autoStageDefinition(VanillaStageNames.iZombieDebug)
class IZombieDebugStage extends IZombiePuzzleStage
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaIZombieLayoutID.iZombieDebug);
    }
}
