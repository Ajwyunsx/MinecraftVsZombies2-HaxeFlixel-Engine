// Ported from: Assets/Scripts/MVZ2/Models/Components/Carts/NyanCatModel.cs
package mvz2.models;

import unity.GameObject;

class NyanCatModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function OnPropertySet(name:String, value:Dynamic):Void {
        super.OnPropertySet(name, value);
        if (name == "Nyaightmare") {
            UpdateNyanCat();
        }
    }
    private function UpdateNyanCat():Void {
        var nyaightmare:Bool = Model.GetProperty("Nyaightmare");
        nyanCatRoot.SetActive(!nyaightmare);
        nyaightmareRoot.SetActive(nyaightmare);
    }
    private var nyanCatRoot:GameObject = null;
    private var nyaightmareRoot:GameObject = null;
}
