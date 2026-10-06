// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter3/MiracleMalletReplica.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
import pvzengine.entities.EntityTypes;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.miracleMalletReplica)
class MiracleMalletReplica extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new MiracleMalletReplicaDamageAura());
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        artifact.SetGlowing(true);
    }
}

// PORT-NOTE: C# 嵌套类 MiracleMalletReplica.DamageAura → Haxe 模块级类 MiracleMalletReplicaDamageAura
// （同包内多模块的同名子类型会触发 "Type name X is redefined"，按仓库既有约定加前缀消歧）。
class MiracleMalletReplicaDamageAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Contraption.miracleMalletReplicaDamage);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        for (target in level.FindEntities(e -> e.Type == EntityTypes.PLANT && e.IsFriendlyEntity()))
            results.push(target);
    }
}
