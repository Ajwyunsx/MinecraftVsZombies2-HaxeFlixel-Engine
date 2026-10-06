// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/BrickCannon_Trigger.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.contraptions.EntityEmptyHandClickBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.gamecontent.helditems.VanillaHeldTypes;
import mvz2logic.helditems.HeldItemBuilder;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.level.LogicHeldItemProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.brickCannon_Trigger)
class Brickcannon_Trigger extends EntityEmptyHandClickBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanEmptyHandClick(entity:Entity):Bool
    {
        if (entity.State != BrickCannon.STATE_IDLE)
            return false;
        if (BrickCannon.HasNoMissile(entity))
            return false;
        return super.CanEmptyHandClick(entity);
    }
    public override function IsValidPointerInteraction(entity:Entity, interaction:PointerInteractionData):Bool
    {
        if (interaction.pointer.type == PointerTypes.TOUCH)
        {
            if (interaction.interaction == PointerInteraction.Release || interaction.interaction == PointerInteraction.Drag)
                return true;
        }
        else if (interaction.pointer.type == PointerTypes.MOUSE)
        {
            if (interaction.interaction == PointerInteraction.Down)
                return true;
        }
        return false;
    }
    public override function EmptyHandClick(entity:Entity):Void
    {
        var builder = new HeldItemBuilder(VanillaHeldTypes.brickCannon, 100);
        // PORT-NOTE: C# 扩展方法 builder.SetEntityID(...) / level.SetHeldItem(...) 在 Haxe 中改为静态调用
        // （与 mvz2/gamecontent/helditems/SelectBlueprintHeldItemBehaviour.hx、mvz2/gamecontent/stages/BreakoutStage.hx 一致）。
        LogicHeldItemProps.SetEntityID(builder, entity.ID);
        LogicLevelExt.SetHeldItem(entity.Level, builder);
    }
}
