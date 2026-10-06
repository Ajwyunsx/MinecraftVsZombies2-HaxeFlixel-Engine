// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Prologue/GemCarrierBuff.cs
// PORT-NOTE: C# 中 gemWeights 为 List<(NamespaceID id, float weight)>；Haxe 用匿名结构数组表示元组。
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.definitions.BuffDefinition;
using mvz2.vanilla.pickups.VanillaPickupExt;

@:autoBuffDefinition(VanillaBuffNames.Enemy_gemCarrier)
class GemCarrierBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.ENEMY_DROP_REWARDS, PostEnemyDropRewardsCallback);
    }
    private function PostEnemyDropRewardsCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var enemy = param.entity;
        var buffs = enemy.GetBuffs(GemCarrierBuff);
        for (buff in buffs)
        {
            var weights = gemWeights.map(function(g) return g.weight);
            var index = enemy.DropRNG.WeightedRandom(weights);
            var gemID = gemWeights[index].id;
            enemy.Produce(gemID);
            buff.Remove();
        }
    }
    private static var gemWeights:Array<{id:NamespaceID, weight:Float}> = [
        {id: VanillaPickupID.emerald, weight: 100},
        {id: VanillaPickupID.ruby, weight: 20},
        {id: VanillaPickupID.diamond, weight: 1},
    ];
}
