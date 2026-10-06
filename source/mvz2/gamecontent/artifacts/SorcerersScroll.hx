// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter5/SorcerersScroll.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.sorcerersScroll)
class SorcerersScroll extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new StarshardAura());
    }
}

// PORT-NOTE: C# 嵌套类 SorcerersScroll.StarshardAura → Haxe 模块子类型，访问路径一致。
class StarshardAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Level.sorcerersScrollStarshard);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        results.push(auraEffect.Source.GetLevel());
    }
}
