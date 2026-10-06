// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter1/DreamKey.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.artifacts.ArtifactSourceReference;
import pvzengine.NamespaceID;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.entities.EntityTypes;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.dreamKey)
class DreamKey extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_CONTRAPTION_EVOKE, PostContraptionEvokeCallback);
        AddAura(new EvokedContraptionInvincibleAura());
    }
    function PostContraptionEvokeCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var contraption = param.entity;
        var level = contraption.Level;
        var artifact = level.GetArtifact(ID);
        if (artifact == null)
            return;
        // PORT-NOTE: C# 重载 new ArtifactSourceReference(artifact)，Haxe 不支持重载，改用静态工厂 FromArtifact。
        contraption.HealEffectsSourced(contraption.GetMaxHealth(), ArtifactSourceReference.FromArtifact(artifact));
        artifact.Highlight();
    }
    public static var ID:NamespaceID = VanillaArtifactID.dreamKey;
}

// PORT-NOTE: C# 嵌套类 DreamKey.EvokedContraptionInvincibleAura → Haxe 模块子类型，访问路径一致。
class EvokedContraptionInvincibleAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Contraption.dreamKeyShield, 7);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        for (target in level.FindEntities(e -> e.Type == EntityTypes.PLANT && e.IsEvoked()))
            results.push(target);
    }
}
