// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/InstakillByImpact.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageOutput;
import pvzengine.definitions.EntityBehaviourDefinition;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.instakillByImpact)
class InstakillByImpact extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);
        if (result.BodyResult != null && result.BodyResult.HasEffect(VanillaDamageEffects.IMPACT))
        {
            var damageEffects = new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.INSTA_KILL]);
            result.Entity.Die(damageEffects, result.BodyResult.Source);
        }
    }
}
