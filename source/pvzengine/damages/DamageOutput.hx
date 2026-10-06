// Ported from: Assets/Scripts/Engine/Level/Damage/DamageOutput.cs
package pvzengine.damages;

import pvzengine.NamespaceID;
import pvzengine.entities.Entity;

class DamageOutput
{
    public function new(entity:Entity)
    {
        Entity = entity;
    }

    public var Entity:Entity;
    public var BodyResult:Null<BodyDamageResult>;
    public var ArmorResult:Null<ArmorDamageResult>;
    public var ShieldResult:Null<ArmorDamageResult>;
    public var ShieldTarget:Null<NamespaceID>;
    public function HasDamageAmount():Bool
    {
        if (ArmorResult != null && ArmorResult.HasDamageAmount())
            return true;
        if (BodyResult != null && BodyResult.HasDamageAmount())
            return true;
        if (ShieldResult != null && ShieldResult.HasDamageAmount())
            return true;
        return false;
    }
    public function HasAnyNotFatal():Bool
    {
        if (ArmorResult != null && ArmorResult.Fatal)
            return false;
        if (BodyResult != null && BodyResult.Fatal)
            return false;
        if (ShieldResult != null && ShieldResult.Fatal)
            return false;
        return true;
    }
    public function HasAnyFatal():Bool
    {
        if (ArmorResult != null && ArmorResult.Fatal)
            return true;
        if (BodyResult != null && BodyResult.Fatal)
            return true;
        if (ShieldResult != null && ShieldResult.Fatal)
            return true;
        return false;
    }
    public function GetTotalAmount():Float
    {
        var sum:Float = 0;
        if (ArmorResult != null)
            sum += ArmorResult.Amount;
        if (BodyResult != null)
            sum += BodyResult.Amount;
        if (ShieldResult != null)
            sum += ShieldResult.Amount;
        return sum;
    }
    public function GetTotalSpendAmount():Float
    {
        var sum:Float = 0;
        if (ArmorResult != null)
            sum += ArmorResult.SpendAmount;
        if (BodyResult != null)
            sum += BodyResult.SpendAmount;
        if (ShieldResult != null)
            sum += ShieldResult.SpendAmount;
        return sum;
    }
    public function GetAllResults():Array<DamageResult>
    {
        var results:Array<DamageResult> = [];
        if (ArmorResult != null) results.push(ArmorResult);
        if (BodyResult != null) results.push(BodyResult);
        if (ShieldResult != null) results.push(ShieldResult);
        return results;
    }
}
