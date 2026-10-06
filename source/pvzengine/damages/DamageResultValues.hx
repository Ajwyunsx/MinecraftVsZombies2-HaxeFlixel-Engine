// Ported from: Assets/Scripts/Engine/Level/Damage/DamageResultValues.cs
package pvzengine.damages;

// [Serializable]
class DamageResultValues
{
    public function new(originalAmount:Float, amount:Float, spendAmount:Float)
    {
        this.originalAmount = originalAmount;
        this.amount = amount;
        this.spendAmount = spendAmount;
    }
    public var originalAmount:Float;
    public var amount:Float;
    public var spendAmount:Float;
}
