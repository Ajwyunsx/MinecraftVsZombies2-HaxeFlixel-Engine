// Ported from: Newtonsoft.Json.JsonConvert (minimal shim)
package newtonsoft.json;

// PORT-NOTE: Haxe 没有运行期字段类型信息，反序列化需要显式传入目标 Class（C# 通过泛型获得）。
// 调用方式：JsonConvert.DeserializeObject(json, MyType)。
class JsonConvert {
    public static function SerializeObject(value:Dynamic, ?formatting:Dynamic):String {
        return haxe.Json.stringify(value);
    }

    public static function DeserializeObject<T>(value:String, ?type:Class<T>):T {
        if (value == null || value == "") return null;
        var parsed:Dynamic = haxe.Json.parse(value);
        if (type == null) return parsed;
        return cast convert(parsed, type);
    }

    public static function DeserializeObjectUntyped(value:String):Dynamic {
        if (value == null || value == "") return null;
        return haxe.Json.parse(value);
    }

    static function convert(value:Dynamic, type:Class<Dynamic>):Dynamic {
        if (value == null) return null;
        if (type == null) return value;
        // PORT-NOTE: Haxe 中 Int/Float/Bool 是 abstract，既不能作为 Class<Dynamic> 传入也不能与之比较，
        //   故改为「目标类型为 String」或「解析出的值本身已是基本类型」时直接返回原值。
        if (type == String) return value;
        if (Std.isOfType(value, String) || Std.isOfType(value, Float) || Std.isOfType(value, Int) || Std.isOfType(value, Bool)) return value;
        if (Std.isOfType(value, Array)) {
            var fields = Reflect.fields(value);
            var result:Array<Dynamic> = [];
            for (item in (cast value:Array<Dynamic>)) {
                result.push(convert(item, type));
            }
            return result;
        }
        var instance = Type.createInstance(type, []);
        for (field in Reflect.fields(value)) {
            Reflect.setField(instance, field, Reflect.field(value, field));
        }
        return instance;
    }
}
