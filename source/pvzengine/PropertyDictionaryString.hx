// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyDictionaryString.cs (class PropertyDictionaryString)
package pvzengine;

// PORT-NOTE: C# 中 GetProperty/TryGetProperty 各有「非泛型」与「泛型」两个重载，Haxe 不支持重载。
// 既有调用点（mvz2/models/Model.hx）同时使用了两种形式：
//   * `propertyDict.GetProperty(name)`（取出 object 用于转交 SetProperty）
//   * `propertyDict.GetProperty<T>(name)`（泛型形式，靠返回类型推断 T）
// 因此这里只保留泛型版本 `GetProperty<T>(name):Null<T>`：非泛型调用点由 Haxe 的返回类型推断
// （无约束时 T 退化为 Dynamic）即可编译，语义一致。
class PropertyDictionaryString
{
    public function new()
    {
    }
    public function SetProperty(key:PropertyKeyString, value:Dynamic):Bool
    {
        var valueBefore:Dynamic = propertyDict.get(key);
        if (value == null)
        {
            if (!propertyDict.exists(key) || valueBefore == null)
                return false;
        }
        else
        {
            if (propertyDict.exists(key) && value == valueBefore)
                return false;
        }
        propertyDict.set(key, value);
        return true;
    }
    public function GetProperty<T>(name:PropertyKeyString):Null<T>
    {
        var boxed = {value: (null:Dynamic)};
        if (TryGetProperty(name, boxed))
            return cast boxed.value;
        return null;
    }
    public function TryGetProperty(name:PropertyKeyString, value:{ value:Dynamic }):Bool
    {
        if (propertyDict.exists(name))
        {
            if (value != null)
                value.value = propertyDict.get(name);
            return true;
        }
        if (value != null)
            value.value = null;
        return false;
    }
    public function RemoveProperty(name:PropertyKeyString):Bool
    {
        if (!propertyDict.exists(name))
            return false;
        propertyDict.remove(name);
        return true;
    }
    public function GetPropertyNames():Array<PropertyKeyString>
    {
        var names:Array<PropertyKeyString> = [];
        for (key in propertyDict.keys())
        {
            names.push(key);
        }
        return names;
    }
    public function ToSerializable():SerializablePropertyDictionaryString
    {
        var properties = new Map<String, Dynamic>();
        for (key in propertyDict.keys())
        {
            properties.set(key.propertyKey, propertyDict.get(key));
        }
        return new SerializablePropertyDictionaryString(properties);
    }
    public static function FromSerializable(seri:SerializablePropertyDictionaryString):PropertyDictionaryString
    {
        var dict = new PropertyDictionaryString();
        dict.propertyDict.clear();
        if (seri.properties != null)
        {
            for (name in seri.properties.keys())
            {
                dict.propertyDict.set(new PropertyKeyString(name), seri.properties.get(name));
            }
        }
        return dict;
    }
    public var Count(get, never):Int;
    inline function get_Count():Int return Lambda.count(propertyDict);
    private var propertyDict:Map<PropertyKeyString, Dynamic> = new Map<PropertyKeyString, Dynamic>();
}
