package unity;

// Minimal UnityEngine.TextAsset shim.
class TextAsset extends UnityObject {
    public var bytes:haxe.io.Bytes;
    public var text(get, never):String;
    function get_text():String {
        return bytes == null ? "" : bytes.toString();
    }

    public function new(?bytes:haxe.io.Bytes, ?name:String) {
        super();
        this.bytes = bytes == null ? haxe.io.Bytes.alloc(0) : bytes;
        if (name != null) this.name = name;
    }
}
