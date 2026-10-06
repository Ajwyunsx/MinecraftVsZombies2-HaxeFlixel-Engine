// Ported from: Assets/Scripts/MVZ2/Models/Components/SpriteSetters/ModelPropertySpriteSetterInt.cs
package mvz2.models;

class ModelPropertySpriteSetterInt extends SpriteSetter {
    public function new() {
        super();
    }

    override public function GetIndex():Int {
        return Model.GetProperty(propertyName);
    }
    private var propertyName:String = null;
}
