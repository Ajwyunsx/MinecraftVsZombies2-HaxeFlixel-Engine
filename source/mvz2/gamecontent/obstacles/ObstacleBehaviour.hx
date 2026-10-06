// Ported from: Assets/Scripts/Vanilla/GameContent/Obstacles/ObstacleBehaviour.cs
package mvz2.gamecontent.obstacles;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

// PORT-NOTE: C# abstract class → Haxe class（PORTING.md §abstract）。
class ObstacleBehaviour extends EntityBehaviourDefinition
{
    function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);
        var bodyResult = result.BodyResult;
        if (bodyResult != null && bodyResult.Amount > 0 && !bodyResult.HasEffect(VanillaDamageEffects.NO_DAMAGE_BLINK))
        {
            var entity = bodyResult.Entity;
            LogicEntityExt.DamageBlink(entity);
        }
    }
    public override function PostDeath(entity:Entity, damageInfo:DeathInfo):Void
    {
        super.PostDeath(entity, damageInfo);
        if (VanillaEntityExt.WillRemoveOnDeath(entity, damageInfo))
        {
            entity.Remove();
            return;
        }
        LogicEntityExt.PlayDeathSound(entity);
    }
}
