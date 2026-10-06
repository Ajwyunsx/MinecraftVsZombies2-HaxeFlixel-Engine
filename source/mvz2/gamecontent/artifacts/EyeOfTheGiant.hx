// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter4/EyeOfTheGiant.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
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
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.eyeOfTheGiant)
class EyeOfTheGiant extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new EyeOfTheGiantAura());
        AddTrigger(LevelCallbacks.POST_ENTITY_INIT, PostEntityInitCallback, 0, EntityTypes.PLANT);
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        artifact.SetGlowing(true);
    }
    function PostEntityInitCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var contraption = param.entity;
        var level = contraption.Level;
        for (artifact in level.GetArtifacts())
        {
            if (artifact == null || artifact.Definition != this)
                continue;
            // TODO-PORT: C# 泛型 GetAuraEffect<EyeOfTheGiantAura>()，Haxe 调用处不支持显式类型参数，按移植层约定省略。
            var aura = artifact.GetAuraEffect();
            if (aura == null)
                continue;
            aura.UpdateAura();
        }
    }
}

// PORT-NOTE: C# 嵌套类 EyeOfTheGiant.EyeOfTheGiantAura → Haxe 模块子类型，访问路径一致。
class EyeOfTheGiantAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Contraption.eyeOfTheGiant);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        for (target in level.FindEntities(e -> e.Type == EntityTypes.PLANT && e.IsFriendlyEntity()))
            results.push(target);
    }
}
