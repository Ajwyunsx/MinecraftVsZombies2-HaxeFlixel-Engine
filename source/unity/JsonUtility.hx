package unity;

import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;

// Minimal UnityEngine.JsonUtility shim（基于 haxe.Json）。
class JsonUtility {
    public static function ToJson(obj:Dynamic, ?prettyPrint:Bool = false):String {
        return Json.stringify(obj, prettyPrint ? "  " : null);
    }
    public static function FromJson(json:String, ?type:Class<Dynamic>):Dynamic {
        if (json == null || json == "") return null;
        return Json.parse(json);
    }
    public static function ToJsonOverwrite(json:String, objectToOverwrite:Dynamic):Void {
        var data:Dynamic = Json.parse(json);
        if (data != null && objectToOverwrite != null) {
            for (field in Reflect.fields(data)) {
                Reflect.setField(objectToOverwrite, field, Reflect.field(data, field));
            }
        }
    }
}
