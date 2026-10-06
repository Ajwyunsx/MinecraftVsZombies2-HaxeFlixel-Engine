// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter5/DragonTooth.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
import pvzengine.entities.Entity;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.entities.LogicEntityExt;

@:autoArtifactDefinition(VanillaArtifactNames.dragonTooth)
class DragonTooth extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new DragonToothAura());
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        // TODO-PORT: C# 泛型 GetAuraEffect<Aura>()，Haxe 调用处不支持显式类型参数，按移植层约定省略。
        var aura = artifact.GetAuraEffect();
        var active = false;
        if (aura != null && aura.GetTargetCount() > 0)
        {
            active = true;
        }
        artifact.SetGlowing(active);
    }
    public static inline var HP_THRESOLD:Float = 0.5;
}

// PORT-NOTE: C# 嵌套类 DragonTooth.Aura → Haxe 模块级类 DragonToothAura
// （同包内多模块的同名子类型会触发 "Type name X is redefined"，按仓库既有约定加前缀消歧）；
// 对主类常量的引用按移植约定加类名限定。
class DragonToothAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Entity.dragonTooth, 7);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        buffer = [];
        auraEffect.Level.FindEntitiesNonAlloc(e -> !e.IsDead && e.IsHostileEntity() && e.IsVulnerableEntity() && e.Health <= e.GetMaxHealth() * DragonTooth.HP_THRESOLD, buffer);
        for (target in buffer)
            results.push(target);
    }
    var buffer:Array<Entity> = [];
}
