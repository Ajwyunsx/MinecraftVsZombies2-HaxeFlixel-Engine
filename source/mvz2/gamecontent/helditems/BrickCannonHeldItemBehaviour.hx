// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Entity/BrickCannonHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2.gamecontent.contraptions.BrickCannon;
import mvz2logic.helditems.HeldItemTargetGrid;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.inputs.PointerInteractionData;

@:autoHeldItemBehaviourDefinition(VanillaHeldItemBehaviourNames.brickCannon)
class BrickCannonHeldItemBehaviour extends ClickContraptionTargetHeldItemBehaviour
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
            BrickCannon.Launch(entity, targetGrid.Target.GetEntityPosition());
        }
    }
}
