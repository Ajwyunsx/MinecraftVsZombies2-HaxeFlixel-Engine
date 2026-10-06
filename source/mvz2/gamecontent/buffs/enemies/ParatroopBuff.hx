// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter5/ParatroopBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.armors.VanillaArmorID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.armors.LogicArmorSlots;
import mvz2logic.entities.LogicEnemyStates;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import pvzengine.modifiers.NumberOperator;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Enemy_paratroop)
class ParatroopBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.FALL_RESISTANCE, NumberOperator.Add, 10000));
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Multiply, 0));
        AddModifier(new IntModifier(VanillaEnemyProps.STATE_OVERRIDE, IntegerOperator.Set, LogicEnemyStates.IDLE));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        // TODO-PORT: C# 的 Entity.DeactivateArmorColliders(LogicArmorSlots.shield) 为引擎方法，
        // 当前 Haxe 工程中尚无对应实现，暂按 1:1 直译调用。
        entity.DeactivateArmorColliders(LogicArmorSlots.shield);
    }
    public override function PostRemove(buff:Buff):Void
    {
        super.PostRemove(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        entity.ActivateArmorColliders(LogicArmorSlots.shield);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var shield = entity.GetArmorAtSlot(LogicArmorSlots.shield);
        if (shield == null || shield.Definition.GetID() != VanillaArmorID.umbrellaShield)
        {
            buff.Remove();
            return;
        }
        entity.Velocity = entity.Velocity * 0.7 + Vector3.down * (FALL_SPEED * 0.3);

        if (entity.IsOnGround)
        {
            buff.Remove();
        }
    }
    public static function IsParachuting(entity:Entity):Bool
    {
        return entity.HasBuff(ParatroopBuff);
    }
    public static inline var FALL_SPEED:Float = 7;
}
