// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter2/PagodaBranch.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import unity.Mathf;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.level.LogicLevelExt;
using mvz2logic.level.LogicLevelProps;

@:autoArtifactDefinition(VanillaArtifactNames.pagodaBranch)
class PagodaBranch extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_LEVEL_START, PostLevelStartCallback);
        AddAura(new LevelAura());
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        artifact.SetGlowing(true);
    }
    function PostLevelStartCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        var artifacts = level.GetArtifacts();
        for (artifact in artifacts)
        {
            if (artifact == null)
                continue;
            if (artifact.Definition.GetID() != VanillaArtifactID.pagodaBranch)
                continue;
            var slotCount = level.GetStarshardSlotCount();
            var starshardCount = level.GetStarshardCount();
            if (starshardCount < slotCount)
            {
                // PORT-NOTE: C# Mathf.Clamp(int, int, int) → unity.Mathf.ClampInt（shim 中 Clamp 仅接受 Float）。
                starshardCount = Mathf.ClampInt(starshardCount + 2, 0, slotCount);
                artifact.Highlight();
                level.PlaySound(VanillaSoundID.starshardUse);
            }
            level.SetStarshardCount(starshardCount);
        }
    }
}

// PORT-NOTE: C# 嵌套类 PagodaBranch.LevelAura → Haxe 模块子类型，访问路径一致。
class LevelAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Level.pagodaBranchLevel);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        results.push(auraEffect.Level);
    }
}
