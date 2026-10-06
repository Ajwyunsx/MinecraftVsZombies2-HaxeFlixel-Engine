// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter5/UFOBlueAbsorbBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.buffs.pickups.AbsorbedByUFOBuff;
import mvz2.vanilla.pickups.VanillaPickupProps;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.Buff;
import pvzengine.buffs.IBuffTarget;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityID;
import pvzengine.entities.EntityTypes;
using mvz2.vanilla.pickups.VanillaPickupExt;

@:autoBuffDefinition(VanillaBuffNames.Enemy_ufoBlueAbsorb)
class UFOBlueAbsorbBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new Aura());
    }
}

// PORT-NOTE: C# 嵌套类 UFOBlueAbsorbBuff.Aura → Haxe 模块子类型，访问路径一致。
class Aura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Pickup.absorbedByUFO, 4);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Level;
        for (pickup in level.FindEntities(function(e) return CanAbsorb(auraEffect, e)))
        {
            results.push(pickup);
        }
    }

    public override function UpdateTargetBuff(effect:AuraEffect, target:IBuffTarget, buff:Buff):Void
    {
        super.UpdateTargetBuff(effect, target, buff);
        var entity = effect.Source.GetEntity();
        if (entity != null)
        {
            AbsorbedByUFOBuff.SetUFOID(buff, new EntityID(entity));
        }
    }
    private function CanAbsorb(effect:AuraEffect, entity:Entity):Bool
    {
        if (entity.Type != EntityTypes.PICKUP) // 是掉落物
            return false;
        if (entity.IsCollected()) // 没有被拾取
            return false;
        if (VanillaPickupProps.NoPickupStolen(entity)) // 能被偷取
            return false;
        if (VanillaPickupProps.IsImportantPickup(entity))
            return false;
        var sourceEntity = effect.Source != null ? effect.Source.GetEntity() : null;
        if (sourceEntity != null)
        {
            var entityID = sourceEntity.ID;
            // 掉落物本身有被吸取BUFF，并且这个BUFF的主人不是自己。
            var absorbBuffs = entity.GetBuffs(AbsorbedByUFOBuff);
            var absorbedByThis = true;
            if (absorbBuffs.length > 0)
            {
                absorbedByThis = false;
                for (buff in absorbBuffs)
                {
                    var ufoID = AbsorbedByUFOBuff.GetUFOID(buff);
                    if (ufoID != null && ufoID.ID == entityID)
                    {
                        absorbedByThis = true;
                        break;
                    }
                }
            }
            if (!absorbedByThis)
            {
                return false;
            }
        }
        return true;
    }
}
