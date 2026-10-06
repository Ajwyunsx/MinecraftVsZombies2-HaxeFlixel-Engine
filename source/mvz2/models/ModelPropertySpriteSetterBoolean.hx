// Ported from: Assets/Scripts/MVZ2/Models/Components/SpriteSetters/ModelPropertySpriteSetterBoolean.cs
package mvz2.models;

class ModelPropertySpriteSetterBoolean extends SpriteSetter {
    public function new() {
        super();
    }

    override public function GetIndex():Int {
        return Model.GetProperty(propertyName) ? 1 : 0;
    }
    private var propertyName:String = null;
}
