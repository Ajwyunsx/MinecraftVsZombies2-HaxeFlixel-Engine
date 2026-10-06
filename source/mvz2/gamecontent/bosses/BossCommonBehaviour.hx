// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/BossCommonBehaviour.cs
package mvz2.gamecontent.bosses;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2logic.entities.LogicEntityExt;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.damages.DamageOutput;
import pvzengine.definitions.EntityBehaviourDefinition;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.bossCommon)
class BossCommonBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override public function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);
        var bodyResult = result.BodyResult;
        if (bodyResult != null && bodyResult.Amount > 0 && !bodyResult.HasEffect(VanillaDamageEffects.NO_DAMAGE_BLINK))
        {
            var entity = bodyResult.Entity;
            LogicEntityExt.DamageBlink(entity);
        }
    }
}
