// Ported from: Assets/Scripts/MVZ2/Talks/Data/CharacterVariantSprites.cs
package mvz2.talkdata;

import pvzengine.NamespaceID;
import unity.Sprite;

class CharacterVariantSprite {
    public var variant:NamespaceID;
    public var sprite:Sprite;

    public function new(variant:NamespaceID, sprite:Sprite) {
        this.variant = variant;
        this.sprite = sprite;
    }
}
