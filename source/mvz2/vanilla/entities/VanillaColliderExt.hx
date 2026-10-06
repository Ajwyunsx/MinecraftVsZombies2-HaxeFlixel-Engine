// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/VanillaColliderExt.cs
package mvz2.vanilla.entities;

import mvz2.vanilla.armors.VanillaArmorExt;
import mvz2logic.armors.LogicArmorSlots;
import pvzengine.NamespaceID;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageInput;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.EntitySourceReference;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.level.ILevelSourceReference;

// PORT-NOTE: C# 扩展方法 → 以 IEntityCollider 为首参的静态方法（PORTING.md §扩展方法）。
class VanillaColliderExt
{
    public static function IsForMain(collider:IEntityCollider):Bool
    {
        return !NamespaceID.IsValid(collider.ArmorSlot);
    }
    public static function IsForHelmet(collider:IEntityCollider):Bool
    {
        return collider.ArmorSlot == LogicArmorSlots.main;
    }
    public static function IsMainCollider(collider:IEntityCollider):Bool
    {
        return collider.Name == EntityCollisionHelper.NAME_MAIN;
    }
    public static function GetDamageInput(collider:IEntityCollider, amount:Float, effects:DamageEffectList, source:Entity):DamageInput
    {
        return new DamageInput(amount, effects, collider.Entity, new EntitySourceReference(source), collider.ArmorSlot);
    }
    public static function TakeDamage(collider:IEntityCollider, amount:Float, effects:DamageEffectList, source:Entity):DamageOutput
    {
        return TakeDamageWithSourceRef(collider, amount, effects, new EntitySourceReference(source));
    }
    // PORT-NOTE: Haxe has no method overloading; renamed overload to TakeDamageWithSourceRef.
    public static function TakeDamageWithSourceRef(collider:IEntityCollider, amount:Float, effects:DamageEffectList, source:Null<ILevelSourceReference>):DamageOutput
    {
        return VanillaEntityExt.TakeDamageSourced(collider.Entity, amount, effects, source, collider.ArmorSlot);
    }
    public static function TryDestroyBySpikes(collider:IEntityCollider, source:Entity):Bool
    {
        var armorSlot = collider.ArmorSlot;
        var entity = collider.Entity;
        if (!NamespaceID.IsValid(armorSlot))
        {
            return VanillaEntityExt.TryDestroyBySpikes(entity, source);
        }
        var armor = entity.GetArmorAtSlot(armorSlot);
        if (armor != null)
        {
            return VanillaArmorExt.TryDestroyBySpikes(armor, source);
        }
        return false;
    }
}
