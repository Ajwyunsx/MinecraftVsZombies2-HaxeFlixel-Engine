// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter3/SmartPhone.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.effects.GemEffect;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import unity.Vector3;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.level.LevelPositions;
using mvz2logic.level.LogicLevelExt;
using mvz2logic.level.LogicStageProps;

@:autoArtifactDefinition(VanillaArtifactNames.smartPhone)
class SmartPhone extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_LEVEL_CLEAR, PostLevelClearCallback);
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        var level = artifact.Level;
        if (level.IsEndless())
        {
            artifact.SetInactive(true);
            artifact.SetNumber(-1);
            return;
        }
        artifact.SetInactive(false);
        if (level.CurrentWave < level.GetTotalWaveCount())
        {
            artifact.SetNumber(GetMoney(Std.int(level.Energy)));
            artifact.SetGlowing(false);
        }
        else
        {
            artifact.SetGlowing(true);
        }
    }
    function PostLevelClearCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        var artifacts = level.GetArtifacts();
        for (artifact in artifacts)
        {
            if (artifact == null)
                continue;
            if (artifact.Definition != this)
                continue;
            var money = artifact.GetNumber();
            if (money <= 0)
                continue;
            // PORT-NOTE: C# 依赖 Unity 的 Vector2 → Vector3 隐式转换，Haxe 显式构造 Vector3。
            var slotPosition = level.GetEnergySlotEntityPosition();
            GemEffect.SpawnGemEffects(level, money, new Vector3(slotPosition.x, slotPosition.y, 0), null, false);
            artifact.Highlight();
            artifact.SetNumber(0);
        }
    }
    function GetMoney(energy:Int):Int
    {
        if (energy <= 0)
            return 0;
        var unit = Std.int(energy / ENERGY_UNIT);
        return unit * MONEY_UNIT;
    }
    public static inline var ENERGY_UNIT:Int = 10;
    public static inline var MONEY_UNIT:Int = 10;
}
