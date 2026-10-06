// Ported from: Assets/Scripts/MVZ2/Models/Components/GameObjectActivater/ModelPropertyGameObjectActivatorBoolean.cs
package mvz2.models;

class ModelPropertyGameObjectActivatorBoolean extends ModelPropertyGameObjectActivator {
    public function new() {
        super();
    }

    override public function GetActive():Bool {
        return Model.GetProperty(propertyName) != whenFalse;
    }
    private var whenFalse:Bool;
    private var propertyName:String = null;
}
