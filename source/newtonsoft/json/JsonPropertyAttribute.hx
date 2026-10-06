// Ported from: Newtonsoft.Json.JsonPropertyAttribute (minimal shim)
package newtonsoft.json;

class JsonPropertyAttribute {
    public var PropertyName:String;

    public function new(?propertyName:String) {
        PropertyName = propertyName;
    }
}
