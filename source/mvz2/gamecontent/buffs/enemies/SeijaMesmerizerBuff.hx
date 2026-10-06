// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter3/SeijaMesmerizerBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.definitions.BuffDefinition;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;

@:autoBuffDefinition(VanillaBuffNames.Enemy_seijaMesmerizer)
class SeijaMesmerizerBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEntityDeathCallback);
    }
    private function PostEntityDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (!entity.HasBuff(SeijaMesmerizerBuff))
            return;
        for (seija in entity.Level.FindEntities(VanillaBossID.seija))
        {
            if (seija.IsDead)
                continue;
            seija.Die();
        }
    }
}
