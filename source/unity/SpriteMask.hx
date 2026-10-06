package unity;

// Minimal UnityEngine.SpriteMask shim.
class SpriteMask extends Renderer {
    public var frontSortingOrder:Int = 0;
    public var backSortingOrder:Int = 0;
    public var alphaCutoff:Float = 0;
    public var sprite:Sprite;

    public function new() {
        super();
    }
}
