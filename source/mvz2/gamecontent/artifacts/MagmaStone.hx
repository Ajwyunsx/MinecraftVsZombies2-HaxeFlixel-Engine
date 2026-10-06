// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter6/MagmaStone.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.callbacks.VanillaCallbackPriorities;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreTakeDamageParams;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.callbacks.CallbackResult;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.magmaStone)
class MagmaStone extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.PRE_ENTITY_TAKE_DAMAGE, PreEntityTakeDamageCallback, VanillaCallbackPriorities.MULTIPLY);
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        artifact.SetGlowing(true);
    }
    function PreEntityTakeDamageCallback(param:PreTakeDamageParams, result:CallbackResult):Void
    {
        var input = param.input;
        if (!input.HasEffect(VanillaDamageEffects.FIRE))
            return;
        var entity = input.Entity;
        if (!entity.IsHostileEntity())
            return;
        // PORT-NOTE: LINQ Count(predicate) → Lambda.count。
        var count = Lambda.count(entity.Level.GetArtifacts(), a -> a != null && a.Definition == this);
        input.Multiply(1 + DAMAGE_MULTIPLIER_ADDITION * count);
    }
    public static inline var DAMAGE_MULTIPLIER_ADDITION:Float = 0.5;
}
