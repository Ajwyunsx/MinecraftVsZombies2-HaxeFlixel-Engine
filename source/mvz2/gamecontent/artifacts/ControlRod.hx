// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter6/ControlRod.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.enemies.ControlRodUnstableBuff;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.entities.EntityTypes;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.controlRod)
class ControlRod extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new BlueprintAura());
        AddTrigger(LevelCallbacks.POST_ENTITY_INIT, PostEnemyInitCallback, 0, EntityTypes.ENEMY);
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        artifact.SetGlowing(true);
    }
    function PostEnemyInitCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var level = entity.Level;
        var artifacts = level.GetArtifacts();
        for (artifact in artifacts)
        {
            if (artifact == null)
                continue;
            if (artifact.Definition != this)
                continue;
            artifact.Highlight();
            entity.AddBuff(ControlRodUnstableBuff);
        }
    }
}

// PORT-NOTE: C# 嵌套类 ControlRod.BlueprintAura → Haxe 模块子类型，访问路径一致。
class BlueprintAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.SeedPack.controlRodRecharge, 4);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        for (seed in level.GetAllSeedPacks())
        {
            if (seed == null)
                continue;
            var seedDef = seed.Definition;
            if (seedDef == null)
                continue;
            results.push(seed);
        }
    }
}
