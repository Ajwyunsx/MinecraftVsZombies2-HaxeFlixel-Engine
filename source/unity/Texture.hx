package unity;

// Minimal UnityEngine.Texture shim.
class Texture extends UnityObject {
    public var width:Int = 0;
    public var height:Int = 0;
    public var filterMode:FilterMode = FilterMode.Bilinear;
    public var wrapMode:TextureWrapMode = TextureWrapMode.Clamp;

    public function new(?width:Int = 0, ?height:Int = 0) {
        super();
        this.width = width;
        this.height = height;
    }
    public function GetNativeTexturePtr():Dynamic return null;
}
