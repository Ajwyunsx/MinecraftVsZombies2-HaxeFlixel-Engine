// Ported from: Assets/Scripts/MVZ2/Models/Components/SpriteSetters/DamagePercentSpriteSetter.cs
package mvz2.models;

import unity.Mathf;

class DamagePercentSpriteSetter extends SpriteSetter {
    public function new() {
        super();
    }

    override public function GetIndex():Int {
        if (sprites == null)
            return 0;
        var percent:Float = Model.GetProperty("DamagePercent");
        var count = sprites.length;
        return Mathf.FloorToInt(percent * count);
    }
}
