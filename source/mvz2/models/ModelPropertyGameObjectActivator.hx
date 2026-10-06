// Ported from: Assets/Scripts/MVZ2/Models/Components/GameObjectActivater/ModelPropertyGameObjectActivator.cs
package mvz2.models;

// abstract
class ModelPropertyGameObjectActivator extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        var active = GetActive();
        if (active != gameObject.activeSelf) {
            gameObject.SetActive(active);
        }
    }
    // abstract
    public function GetActive():Bool {
        throw "abstract";
    }
}
