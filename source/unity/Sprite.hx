package unity;

// Minimal UnityEngine.Sprite shim.
class Sprite extends UnityObject {
    public var rect:Rect = new Rect();
    public var border:Vector4 = new Vector4();
    public var texture:Texture2D;
    public var pixelsPerUnit:Float = 100;
    public var pivot:Vector2 = new Vector2(0.5, 0.5);
    public var bounds:Bounds = new Bounds();

    public function new(?texture:Texture2D, ?rect:Rect, ?pivot:Vector2) {
        super();
        this.texture = texture;
        if (rect != null) this.rect = rect;
        if (pivot != null) this.pivot = pivot;
    }

    public static function Create(texture:Texture2D, rect:Rect, pivot:Vector2):Sprite {
        var sprite = new Sprite(texture, rect, pivot);
        sprite.name = "Sprite";
        return sprite;
    }
}
