// Ported from: Assets/Scripts/Engine/Level/Damage/DamageInput.cs
package pvzengine.damages;

import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelSourceReference;

class DamageInput
{
    public function new(amount:Float, effects:DamageEffectList, entity:Entity, source:Null<ILevelSourceReference>, shieldTarget:Null<NamespaceID> = null)
    {
        OriginalAmount = amount;
        Amount = amount;
        Effects = effects;
        Entity = entity;
        Source = source;
        ShieldTarget = shieldTarget;
    }
    public function Add(value:Float):Void
    {
        Amount += value;
    }
    public function SetAmount(value:Float):Void
    {
        Amount = value;
    }
    public function Multiply(value:Float):Void
    {
        Amount *= value;
    }
    public function HasEffect(effect:NamespaceID):Bool
    {
        return Effects != null && Effects.HasEffect(effect);
    }
    public var OriginalAmount(default, null):Float;
    public var Amount(default, null):Float;
    public var Effects(default, null):DamageEffectList;
    public var Entity(default, null):Entity;
    public var ShieldTarget(default, null):Null<NamespaceID>;
    public var Source:Null<ILevelSourceReference>;
}
