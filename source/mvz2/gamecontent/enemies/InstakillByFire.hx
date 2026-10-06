// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/InstakillByFire.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageOutput;
import pvzengine.definitions.EntityBehaviourDefinition;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.instakillByFire)
class InstakillByFire extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);
        if (result.BodyResult != null && result.BodyResult.HasEffect(VanillaDamageEffects.FIRE))
        {
            var damageEffects = new DamageEffectList([VanillaDamageEffects.FIRE, VanillaDamageEffects.INSTA_KILL]);
            result.Entity.Die(damageEffects, result.BodyResult.Source);
        }
    }
}
