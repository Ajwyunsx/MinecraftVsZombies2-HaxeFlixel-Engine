// Ported from: Assets/Scripts/MVZ2/Models/Components/GameObjectActivater/DamagePercentGameObjectActivator.cs
package mvz2.models;

class DamagePercentGameObjectActivator extends ModelPropertyGameObjectActivator {
    public function new() {
        super();
    }

    override public function GetActive():Bool {
        var percent:Float = Model.GetProperty("DamagePercent");
        var target = numerator / denominator;
        return Compare(percent, target, comparer);
    }
    private function Compare(value:Float, target:Float, comparer:FloatComparer):Bool {
        switch (comparer) {
            case FloatComparer.Greater:
                return value > target;
            case FloatComparer.Less:
                return value < target;
            default:
        }
        return false;
    }
    private var comparer:FloatComparer;
    private var numerator:Int;
    private var denominator:Int;
}

enum abstract FloatComparer(Int) from Int to Int {
    var Greater = 0;
    var Less = 1;
}
