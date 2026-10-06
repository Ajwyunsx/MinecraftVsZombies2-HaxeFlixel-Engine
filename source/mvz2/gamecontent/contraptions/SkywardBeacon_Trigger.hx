// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/SkywardBeacon_Trigger.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.contraptions.EntityEmptyHandClickBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.gamecontent.helditems.VanillaHeldTypes;
import mvz2logic.helditems.HeldItemBuilder;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
using mvz2logic.inputs.PointerHelper;
using mvz2logic.level.LogicHeldItemProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skywardBeacon_Trigger)
class SkywardBeacon_Trigger extends EntityEmptyHandClickBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function IsValidPointerInteraction(entity:Entity, interaction:PointerInteractionData):Bool
    {
        return interaction.IsPointerDownOrDrag();
    }
    public override function EmptyHandClick(entity:Entity):Void
    {
        var builder = new HeldItemBuilder(VanillaHeldTypes.skywardBeacon, 100);
        builder.SetEntityID(entity.ID);
        entity.Level.SetHeldItem(builder);
    }
}
