// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter1/RedstoneCarrierBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.definitions.BuffDefinition;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Enemy_redstoneCarrier)
class RedstoneCarrierBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.ENEMY_DROP_REWARDS, PostEnemyDropRewardsCallback);
    }
    private function PostEnemyDropRewardsCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var enemy = param.entity;
        var buffs = enemy.GetBuffs(RedstoneCarrierBuff);
        for (buff in buffs)
        {
            for (i in 0...3)
            {
                // C#: enemy.Level.Spawn(...)?.Let(e => { e.Velocity = ...; });
                var redstone = enemy.Level.Spawn(VanillaPickupID.redstone, enemy.Position + Vector3.up * 10, enemy);
                if (redstone != null)
                {
                    redstone.Velocity = new Vector3(redstone.RNG.Next(-1, 1), 2, 0);
                }
            }
            buff.Remove();
        }
    }
}
