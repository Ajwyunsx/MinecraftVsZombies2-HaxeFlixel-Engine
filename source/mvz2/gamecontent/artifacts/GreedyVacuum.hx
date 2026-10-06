// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter4/GreedyVacuum.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
using mvz2logic.artifacts.LogicArtifactProps;

@:autoArtifactDefinition(VanillaArtifactNames.greedyVacuum)
class GreedyVacuum extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new GreedyVacuumAura());
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        artifact.SetGlowing(true);
    }
}

// PORT-NOTE: C# 嵌套类 GreedyVacuum.Aura → Haxe 模块级类 GreedyVacuumAura
// （同包内多模块的同名子类型会触发 "Type name X is redefined"，按仓库既有约定加前缀消歧）。
class GreedyVacuumAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Level.greedyVacuum, 15);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        results.push(auraEffect.Level);
    }
}
