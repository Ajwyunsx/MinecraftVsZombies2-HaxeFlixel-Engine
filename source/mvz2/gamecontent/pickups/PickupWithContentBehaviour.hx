// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Behaviours/PickupWithContentBehaviour.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.pickups.VanillaPickupProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupWithContent)
class PickupWithContentBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(pickup:Entity):Void
    {
        // PORT-NOTE: 原 C# 代码在 Init 中调用的是 base.Update(pickup)（而非 base.Init），此处按要求 1:1 保留。
        super.Update(pickup);
        pickup.SetModelProperty("ContentID", pickup.GetPickupContentID());
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        pickup.SetModelProperty("ContentID", pickup.GetPickupContentID());
    }
}
