// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter3/WitherSkull.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostTakeDamageParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.witherSkull)
class WitherSkull extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.APPLY_DAMAGE_SPECIAL_EFFECTS, ApplyDamageEffectsCallback);
    }
    public override function Init(projectile:Entity):Void
    {
        super.Init(projectile);
        projectile.SetModelProperty("Source", projectile.Position);
        projectile.SetModelProperty("Dest", projectile.Position + projectile.Velocity);
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        projectile.SetModelProperty("Source", projectile.Position);
        projectile.SetModelProperty("Dest", projectile.Position + projectile.Velocity);
    }
    function ApplyDamageEffectsCallback(param:PostTakeDamageParams, callbackResult:CallbackResult):Void
    {
        var output = param.output;
        if (output == null)
            return;
        var entity = output.Entity;
        if (entity == null)
            return;
        if (!entity.Level.WitherSkullWithersTarget())
            return;
        if (entity.IsUndead())
            return;
        if (output.BodyResult == null)
            return;
        if (output.BodyResult.Amount <= 0)
            return;
        var source = output.BodyResult.Source;
        if (source != null && source.DefinitionID == GetID())
        {
            entity.InflictWither(WITHER_TIME, source);
        }
    }
    public static inline var WITHER_TIME:Int = 900;
}
