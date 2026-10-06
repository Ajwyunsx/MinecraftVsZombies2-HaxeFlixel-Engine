package mvz2.sprites;

import unity.ScriptableObject;
import unity.Sprite;

// Ported from: Assets/Scripts/MVZ2/Sprites/GeneratedSpriteManifest.cs
@:createAssetMenu("NewGeneratedSpriteManifest", "MVZ2/Generated Sprite Manifest")
class GeneratedSpriteManifest extends ScriptableObject {
    public function Reset():Void {
        categories = [];
    }
    public function AddSprite(category:String, sprite:Sprite, background:Sprite):Void {
        var cat = Lambda.find(categories, c -> c.name == category);
        if (cat == null) {
            cat = new GeneratedSpriteCategory(category);
            categories.push(cat);
        }
        cat.AddSprite(sprite, background);
    }
    public function RemoveSprite(category:String, name:String):Void {
        var cat = Lambda.find(categories, c -> c.name == category);
        if (cat == null)
            return;
        cat.RemoveSprite(name);
        if (cat.Count <= 0) {
            categories.remove(cat);
        }
    }
    @:serializeField
    private var categories:Array<GeneratedSpriteCategory> = [];
}

class GeneratedSpriteCategory {
    public function new(name:String) {
        this.name = name;
    }
    public function AddSprite(sprite:Sprite, preview:Sprite):Void {
        sprites.push(new SpritePreview(sprite, preview));
    }
    public function RemoveSprite(name:String):Void {
        sprites = sprites.filter(p -> p.name != name);
    }
    public var Count(get, never):Int;
    inline function get_Count():Int return sprites.length;

    public var name:String;
    @:serializeField
    private var sprites:Array<SpritePreview> = [];
}

class SpritePreview {
    public function new(sprite:Sprite, background:Sprite) {
        this.name = sprite.name;
        this.sprite = sprite;
        this.background = background;
    }
    public var name:String;
    public var background:Sprite;
    public var sprite:Sprite;
}
