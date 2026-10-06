// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Collectible/CollectBehaviour_Value.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import unity.Random;
import unity.Vector3;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupCollectValue)
class CollectBehaviour_Value extends CollectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanCollect(pickup:Entity):Bool
    {
        return true;
    }
    public override function PostCollect(pickup:Entity):Void
    {
        super.PostCollect(pickup);
        var moneyValue = pickup.GetMoneyValue();
        pickup.Velocity = Vector3.zero;
        // PORT-NOTE: AddEnergyDelayed 定义在外部 PVZEngine 程序集中（本仓库无其源码），
        // 移植层暂无对应声明，此处按调用写法保留（与 LevelController 中对 ClearEnergyDelayedEntities 的调用风格一致）。
        pickup.Level.AddEnergyDelayed(pickup, pickup.GetEnergyValue());
        pickup.Level.AddDelayedMoney(pickup, moneyValue);
        pickup.SetGravity(0);
        var pitch = pickup.PlayRandomPitchOnCollect() ? Random.Range(0.95, 1.5) : 1;
        pickup.PlaySoundIfNotNull(pickup.GetCollectSound(), pitch);
        if (moneyValue > 0)
        {
            pickup.Level.ShowMoney();
        }
    }
}
