// Ported from: MongoDB.Bson.BsonExtensionMethods (minimal shim)
package mongodb.bson;

// PORT-NOTE: C# 扩展方法 ToBson()/ToJson() 改为静态调用（PORTING.md §扩展方法）。
class BsonExtensionMethods {
    public static function ToBson(value:Dynamic, ?type:Dynamic, ?document:Dynamic):haxe.io.Bytes {
        var json = haxe.Json.stringify(value);
        return haxe.io.Bytes.ofString(json);
    }

    public static function ToJson(value:Dynamic):String {
        return haxe.Json.stringify(value);
    }
}
