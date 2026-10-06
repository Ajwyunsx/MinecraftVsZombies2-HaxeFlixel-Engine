// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter1/TheCreaturesHeart.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.seedpacks.TheCreaturesHeartReduceCostBuff;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import pvzengine.NamespaceID;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.Buff;
import pvzengine.buffs.IBuffTarget;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.entities.EntityTypes;
import pvzengine.seedpacks.SeedPack;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.theCreaturesHeart)
class TheCreaturesHeart extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_LEVEL_START, PostLevelStartCallback);
        AddTrigger(LevelCallbacks.POST_ENTITY_INIT, PostEntityInitCallback, 0, EntityTypes.PLANT);
        AddTrigger(LevelCallbacks.POST_ENTITY_REMOVE, PostEntityRemoveCallback, 0, EntityTypes.PLANT);
        AddAura(new ReduceCostAura());
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        artifact.SetGlowing(true);
    }
    function PostLevelStartCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        for (artifact in level.GetArtifacts())
        {
            if (artifact == null || artifact.Definition != this)
                continue;
            // TODO-PORT: C# 泛型 GetAuraEffect<T>()，Haxe 调用处不支持显式类型参数，按移植层约定省略（类型由实现侧推断）。
            var aura = artifact.GetAuraEffect();
            if (aura == null)
                continue;
            aura.UpdateAura();
        }
    }
    function PostEntityInitCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var contraption = param.entity;
        var level = contraption.Level;
        for (artifact in level.GetArtifacts())
        {
            if (artifact == null || artifact.Definition != this)
                continue;
            // TODO-PORT: 同上，C# GetAuraEffect<ReduceCostAura>() 的显式类型参数在 Haxe 调用处无法书写。
            var aura = artifact.GetAuraEffect();
            if (aura == null)
                continue;
            aura.UpdateAura();
        }
    }
    function PostEntityRemoveCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var contraption = param.entity;
        var level = contraption.Level;
        for (artifact in level.GetArtifacts())
        {
            if (artifact == null || artifact.Definition != this)
                continue;
            // TODO-PORT: 同上，C# GetAuraEffect<ReduceCostAura>() 的显式类型参数在 Haxe 调用处无法书写。
            var aura = artifact.GetAuraEffect();
            if (aura == null)
                continue;
            aura.UpdateAura();
        }
    }
    public static var ID:NamespaceID = VanillaArtifactID.theCreaturesHeart;
}

// PORT-NOTE: C# 嵌套类 TheCreaturesHeart.ReduceCostAura → Haxe 模块子类型，访问路径一致。
class ReduceCostAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.SeedPack.theCreaturesHeartReduceCost, 15);
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
            if (LogicSeedProps.GetSeedType(seedDef) != SeedTypes.ENTITY)
                continue;
            var entityID = LogicSeedProps.GetSeedEntityID(seedDef);
            if (!NamespaceID.IsValid(entityID))
                continue;
            var entityDef = level.Content.GetEntityDefinition(entityID);
            if (entityDef == null || entityDef.Type != EntityTypes.PLANT)
                continue;
            results.push(seed);
        }
    }
    public override function UpdateTargetBuff(effect:AuraEffect, target:IBuffTarget, buff:Buff):Void
    {
        super.UpdateTargetBuff(effect, target, buff);
        if (!Std.isOfType(target, SeedPack))
            return;
        var seed:SeedPack = cast target;
        // PORT-NOTE: C# 重载 GetSeedType(this SeedPack) 在移植层重命名为 GetSeedTypeOfPack。
        if (LogicSeedProps.GetSeedTypeOfPack(seed) != SeedTypes.ENTITY)
            return;
        var entityID = LogicSeedProps.GetSeedEntityIDOfPack(seed);
        if (!NamespaceID.IsValid(entityID))
            return;
        buff.SetProperty(TheCreaturesHeartReduceCostBuff.PROP_ADDITION, seed.Level.GetEntityCount(entityID) * REDUCTION);
    }
    public static inline var REDUCTION:Float = -5;
}
