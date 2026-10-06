// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter2/BottledBlackhole.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.contraptions.BottledBlackholeDamageBuff;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.Buff;
import pvzengine.buffs.IBuffTarget;
import pvzengine.entities.EntityTypes;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.bottledBlackhole)
class BottledBlackhole extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new BottledBlackholeDamageAura());
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        var level = artifact.Level;
        artifact.SetGlowing(!level.IsConveyorMode() && level.GetSeedSlotCount() > level.GetSeedPackCount());
    }
    public static inline var DAMAGE_MULTIPLIER:Float = 0.1;
}

// PORT-NOTE: C# 嵌套类 BottledBlackhole.DamageAura → Haxe 模块级类 BottledBlackholeDamageAura
// （同包内多模块的同名子类型会触发 "Type name X is redefined"，按仓库既有约定加前缀消歧）；
// 对主类常量的引用按移植约定加类名限定。
class BottledBlackholeDamageAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Contraption.bottledBlackholeDamage);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        for (target in level.FindEntities(e -> e.Type == EntityTypes.PLANT && e.IsFriendlyEntity()))
            results.push(target);
    }
    public override function UpdateTargetBuff(effect:AuraEffect, target:IBuffTarget, buff:Buff):Void
    {
        super.UpdateTargetBuff(effect, target, buff);
        var level = effect.Level;
        if (level.IsConveyorMode())
            return;
        var count = level.GetSeedSlotCount() - level.GetSeedPackCount();
        BottledBlackholeDamageBuff.SetDamageMultiplier(buff, count * BottledBlackhole.DAMAGE_MULTIPLIER);
    }
}
