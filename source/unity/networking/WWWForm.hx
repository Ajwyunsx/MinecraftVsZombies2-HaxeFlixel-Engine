package unity.networking;

// Minimal UnityEngine.Networking.WWWForm shim.
class WWWForm {
    public var fields:Map<String, String> = new Map();

    public function new() {}

    public function AddField(fieldName:String, value:String):Void {
        fields.set(fieldName, value);
    }
    public function AddBinaryData(fieldName:String, contents:haxe.io.Bytes, ?fileName:String, ?mimeType:String):Void {}
    public function AddHeader(headerName:String, value:String):Void {}
}
