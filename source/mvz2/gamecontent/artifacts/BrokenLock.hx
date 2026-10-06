// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter6/BrokenLock.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.contraptions.CommandBlock;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostTakeDamageParams;
import mvz2.vanilla.properties.VanillaArtifactPropertyMeta;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.EntityTypes;
import pvzengine.seedpacks.ClassicSeedPack;
import unity.Mathf;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2.vanilla.contraptions.VanillaContraptionExt;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.brokenLock)
class BrokenLock extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_ENTITY_TAKE_DAMAGE, PostContraptionTakeDamageCallback, 0, EntityTypes.PLANT);
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        artifact.SetGlowing(false);
    }
    function PostContraptionTakeDamageCallback(param:PostTakeDamageParams, result:CallbackResult):Void
    {
        var output = param.output;
        var contraption = output.Entity;
        var level = contraption.Level;
        if (output.BodyResult != null && output.BodyResult.HasEffect(VanillaDamageEffects.NO_BROKEN_LOCK))
            return;
        if (level.IsConveyorMode())
            return;
        var entityID = contraption.GetDefinitionID();
        var commandBlock = false;
        if (entityID == VanillaContraptionID.commandBlock)
        {
            commandBlock = true;
            entityID = CommandBlock.GetTargetEntity(contraption);
        }
        else
        {
            commandBlock = contraption.IsImitated();
        }
        // PORT-NOTE: LINQ OfType<ClassicSeedPack>().FirstOrDefault(...) → Lambda.filter + 取首元素。
        var seedPacks = Lambda.filter(level.GetAllSeedPacks(), s -> Std.isOfType(s, ClassicSeedPack)
            && LogicSeedProps.GetSeedTypeOfPack(s) == SeedTypes.ENTITY
            && LogicSeedProps.GetSeedEntityIDOfPack(s) == entityID
            && LogicSeedProps.IsCommandBlockOfPack(s) == commandBlock
            && !s.IsCharged());
        var seedPack:ClassicSeedPack = null;
        if (seedPacks.length > 0)
            seedPack = cast seedPacks[0];
        if (seedPack == null)
            return;

        var maxRecharge = seedPack.GetMaxRecharge();
        var totalAmount = output.GetTotalAmount();
        var amountPercentage = Mathf.Clamp01(totalAmount / contraption.GetMaxHealth());

        for (artifact in level.GetArtifacts())
        {
            if (artifact == null || artifact.Definition != this)
                continue;
            var percentage = amountPercentage * GetRechargeMultiplier(artifact);
            seedPack.AddRecharge(maxRecharge * percentage);
            artifact.SetGlowing(true);
        }
    }

    public static function GetRechargeMultiplier(artifact:Artifact):Float
    {
        // PORT-NOTE: C# GetProperty<float> 在属性缺失时返回默认值 1f，Haxe 侧显式补默认值。
        var value = artifact.GetProperty(PROP_RECHARGE_MULTIPLIER);
        return value == null ? 1.0 : value;
    }
    public static function SetRechargeMultiplier(artifact:Artifact, value:Float):Void
    {
        artifact.SetProperty(PROP_RECHARGE_MULTIPLIER, value);
    }
    public static var PROP_RECHARGE_MULTIPLIER:VanillaArtifactPropertyMeta<Float> = new VanillaArtifactPropertyMeta<Float>("recharge_multiplier", 1.0);
}
