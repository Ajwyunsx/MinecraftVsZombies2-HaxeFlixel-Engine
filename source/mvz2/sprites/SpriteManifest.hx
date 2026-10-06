package mvz2.sprites;

import unity.ScriptableObject;
import unity.Sprite;

// Ported from: Assets/Scripts/MVZ2/Sprites/SpriteManifest.cs
@:createAssetMenu("NewSpriteManifest", "MVZ2/Sprite Manifest", 0)
class SpriteManifest extends ScriptableObject {
    public var spriteEntries:Array<SpriteEntry>;
    public var spritesheetEntries:Array<SpriteSheetEntry>;
}

@:structInit
class SpriteEntry {
    public var name:String;
    public var sprite:Sprite;
}

@:structInit
class SpriteSheetEntry {
    public var name:String;
    public var spritesheet:Array<Sprite>;
}
