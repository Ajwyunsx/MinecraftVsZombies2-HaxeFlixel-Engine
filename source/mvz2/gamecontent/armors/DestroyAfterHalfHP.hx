// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/DestroyAfterHalfHP.cs
package mvz2.gamecontent.armors;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.armors.VanillaArmorBehaviourID.VanillaArmorBehaviourNames;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.armors.Armor;
import pvzengine.armors.ArmorDestroyInfo;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.ArmorBehaviourDefinition;

@:autoArmorBehaviourDefinition(VanillaArmorBehaviourNames.destroyAfterHalfHP)
class DestroyAfterHalfHP extends ArmorBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_ENTITY_TAKE_DAMAGE, PostEntityTakeDamageCallback);
    }
    function PostEntityTakeDamageCallback(param:PostTakeDamageParams, result:CallbackResult):Void
    {
        var output = param.output;
        var entity = output.Entity;
        if (entity.Health > entity.GetMaxHealth() * 0.5)
            return;
        var armor = VanillaEntityExt.GetMainArmor(entity);
        if (armor == null || !armor.Definition.HasBehaviour(this))
            return;
        var source = output.BodyResult != null ? output.BodyResult.Source : null;
        armor.Destroy(new ArmorDestroyInfo(entity, armor, armor.Slot, new DamageEffectList(VanillaDamageEffects.SELF_DAMAGE), source, null));
    }
}
