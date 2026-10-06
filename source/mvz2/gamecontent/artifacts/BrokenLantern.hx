// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter3/BrokenLantern.cs
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
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.brokenLantern)
class BrokenLantern extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new BrokenLanternAura());
        AddTrigger(LevelCallbacks.POST_ENTITY_INIT, PostContraptionInitCallback, 0, EntityTypes.PLANT);
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        artifact.SetGlowing(true);
    }
    function PostContraptionInitCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var contraption = param.entity;
        if (!contraption.IsLightSource())
            return;
        var level = contraption.Level;
        var lantern = level.GetArtifact(GetID());
        if (lantern == null)
            return;
        // TODO-PORT: C# 泛型 GetAuraEffect<Aura>()，Haxe 调用处不支持显式类型参数，按移植层约定省略。
        var aura = lantern.GetAuraEffect();
        if (aura == null)
            return;
        aura.UpdateAura();
    }
}

// PORT-NOTE: C# 嵌套类 BrokenLantern.Aura → Haxe 模块级类 BrokenLanternAura
// （同包内多模块的同名子类型会触发 "Type name X is redefined"，按仓库既有约定加前缀消歧）。
class BrokenLanternAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Contraption.brokenLantern, 4);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        updateBuffer = [];
        level.FindEntitiesNonAlloc(e -> e.IsLightSource() && e.Type == EntityTypes.PLANT && e.IsFriendlyEntity(), updateBuffer);
        for (entity in updateBuffer)
        {
            results.push(entity);
        }
    }
    var updateBuffer:Array<Entity> = [];
}
