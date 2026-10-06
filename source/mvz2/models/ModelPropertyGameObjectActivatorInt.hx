// Ported from: Assets/Scripts/MVZ2/Models/Components/GameObjectActivater/ModelPropertyGameObjectActivatorInt.cs
package mvz2.models;

class ModelPropertyGameObjectActivatorInt extends ModelPropertyGameObjectActivator {
    public function new() {
        super();
    }

    override public function GetActive():Bool {
        var value:Int = Model.GetProperty(propertyName);
        return Compare(value, constValue, comparer);
    }
    private function Compare(value:Int, target:Int, comparer:IntComparer):Bool {
        switch (comparer) {
            case IntComparer.Equals:
                return value == target;
            case IntComparer.NotEqual:
                return value != target;
            case IntComparer.Greater:
                return value > target;
            case IntComparer.Less:
                return value < target;
            case IntComparer.GEqual:
                return value >= target;
            case IntComparer.LEqual:
                return value <= target;
            default:
        }
        return false;
    }
    private var propertyName:String = null;
    private var comparer:IntComparer;
    private var constValue:Int;
}

enum abstract IntComparer(Int) from Int to Int {
    var Equals = 0;
    var NotEqual = 1;
    var Greater = 2;
    var Less = 3;
    var GEqual = 4;
    var LEqual = 5;
}
