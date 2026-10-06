// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Entity/SkywardBeaconHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.buffs.entities.WhiteFlashBuff;
import mvz2.gamecontent.contraptions.SkywardBeacon;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.helditems.HeldItemTargetGrid;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.inputs.PointerInteractionData;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.skywardBeacon)
class SkywardBeaconHeldItemBehaviour extends ClickContraptionTargetHeldItemBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function OnUseOnGrid(targetGrid:HeldItemTargetGrid, data:IHeldItemData, pointerParams:PointerInteractionData):Void
    {
        var level = targetGrid.GetLevel();
        var entity = GetEntity(level, data);
        if (entity != null)
        {
            SkywardBeacon.SetTargetColumn(entity, targetGrid.Target.Column);
            SkywardBeacon.SetTargetLane(entity, targetGrid.Target.Lane);
            LogicEntityExt.PlaySound(entity, VanillaSoundID.wakeup);
            WhiteFlashBuff.AddToEntity(entity, 30);
        }
    }
}
