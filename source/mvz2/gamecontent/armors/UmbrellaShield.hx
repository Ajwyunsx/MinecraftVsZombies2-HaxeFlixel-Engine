// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/UmbrellaShield.cs
package mvz2.gamecontent.armors;

import mvz2.gamecontent.armors.VanillaArmorBehaviourID.VanillaArmorBehaviourNames;
import mvz2.gamecontent.buffs.enemies.ParatroopBuff;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.armors.LogicArmorSlots;
import pvzengine.armors.Armor;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.definitions.ArmorBehaviourDefinition;

@:autoArmorBehaviourDefinition(VanillaArmorBehaviourNames.umbrellaShield)
class UmbrellaShield extends ArmorBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEntityDeathCallback);
    }
    public override function PostUpdate(armor:Armor):Void
    {
        super.PostUpdate(armor);
        var raised = false;
        if (armor.Owner != null && ParatroopBuff.IsParachuting(armor.Owner))
        {
            raised = true;
        }
        armor.SetModelProperty("Raised", raised);
    }
    function PostEntityDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (VanillaEntityExt.WillRemoveOnDeath(entity, info))
            return;
        var shield = entity.GetArmorAtSlot(LogicArmorSlots.shield);
        if (shield == null)
            return;
        if (!shield.Definition.HasBehaviour(this))
            return;
        shield.Destroy();
    }
}
