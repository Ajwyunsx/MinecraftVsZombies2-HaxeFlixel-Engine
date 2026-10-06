// Ported from: Assets/Scripts/Engine/Level/Damage/ArmorDestroyInfo.cs
package pvzengine.damages;

import pvzengine.NamespaceID;
import pvzengine.armors.Armor;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelSourceReference;

class ArmorDestroyInfo
{
    public function new(entity:Entity, armor:Armor, slot:NamespaceID, effects:DamageEffectList, source:Null<ILevelSourceReference>, damage:Null<ArmorDamageResult>)
    {
        Effects = effects;
        Entity = entity;
        Armor = armor;
        Slot = slot;
        Source = source;
        Damage = damage;
    }
    public function HasEffect(effect:NamespaceID):Bool
    {
        if (Effects == null)
            return false;
        return Effects.HasEffect(effect);
    }
    public var Effects(default, null):DamageEffectList;
    public var Entity(default, null):Entity;
    public var Source:Null<ILevelSourceReference>;
    public var Damage(default, null):Null<ArmorDamageResult>;
    public var Armor(default, null):Armor;
    public var Slot(default, null):NamespaceID;
}
