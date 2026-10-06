// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyDictionary.cs (class PropertyDictionary)
package pvzengine;

import unity.Debug;

// PORT-NOTE: C# 的 `Dictionary<IPropertyKey, object?>` 使用了 PropertyKeyComparer（按 int Key 比较）。
// Haxe 的 Map 无法自定义比较器，因此这里以属性键的 int Key 为键（`Map<Int, Dynamic>`），
// 并用 keyObjects 保存每个键对象以支持 GetPropertyNames()/ToSerializable()。
// PORT-NOTE: C# 的 `out T? value` 参数在 Haxe 中无法表达，按工程约定移植为引用容器结构
// `{ value:Dynamic }`（见 pvzengine/level/IModifiablePropertyTarget.hx）。
// 既有调用点混用了两种写法——`{value:T}` 匿名结构（MapElement/GlobalGame/Definition）与
// `tools.Ref<T>`（LogicSpawnProps）——两者都带有名为 `value` 的可写字段，均满足该结构类型。
class PropertyDictionary
{
    public function new()
    {
    }
    public function SetPropertyObject(key:IPropertyKey, value:Dynamic):Bool
    {
        if (key.Key == 0)
        {
            Debug.LogWarning("Trying to set a property with an invalid key!");
        }
        var valueBefore:Dynamic = propertyDict.get(key.Key);
        if (value == null)
        {
            if (!propertyDict.exists(key.Key) || valueBefore == null)
                return false;
        }
        else
        {
            if (propertyDict.exists(key.Key) && valueEquals(valueBefore, value))
                return false;
        }
        propertyDict.set(key.Key, value);
        keyObjects.set(key.Key, key);
        return true;
    }
    public function SetProperty<T>(key:PropertyKey<T>, value:Null<T>):Bool
    {
        return SetPropertyObject(key, value);
    }
    public function GetPropertyObject(name:IPropertyKey):Dynamic
    {
        var boxed = {value: (null:Dynamic)};
        if (TryGetPropertyObject(name, boxed))
            return boxed.value;
        return null;
    }
    // PORT-NOTE: C# 的 `out object? value` 参数按工程约定移植为引用容器结构 `{ value:Dynamic }`
    //（同 pvzengine/level/IModifiablePropertyTarget.hx），调用点的 `{value:T}` 结构、tools.Ref 均满足该类型。
    public function TryGetPropertyObject(name:IPropertyKey, value:{ value:Dynamic }):Bool
    {
        if (propertyDict.exists(name.Key))
        {
            if (value != null)
                value.value = propertyDict.get(name.Key);
            return true;
        }
        if (value != null)
            value.value = null;
        return false;
    }
    public function GetProperty<T>(name:PropertyKey<T>):Null<T>
    {
        var boxed = {value: (null:Dynamic)};
        if (TryGetProperty(name, boxed))
            return cast boxed.value;
        return name.GetDefaultValue();
    }
    // PORT-NOTE: C# 中若键存在但值无法转换为 T，返回 false 并给出 DefaultValue；
    // Haxe 没有运行期泛型检查，这里按键是否存在来判定（值按 Dynamic 传递并 cast）。
    public function TryGetProperty<T>(name:PropertyKey<T>, value:{ value:Dynamic }):Bool
    {
        if (propertyDict.exists(name.Key))
        {
            if (value != null)
                value.value = propertyDict.get(name.Key);
            return true;
        }
        if (value != null)
            value.value = name.GetDefaultValue();
        return false;
    }
    public function RemovePropertyObject(name:IPropertyKey):Bool
    {
        if (!propertyDict.exists(name.Key))
            return false;
        propertyDict.remove(name.Key);
        keyObjects.remove(name.Key);
        return true;
    }
    public function RemoveProperty<T>(name:PropertyKey<T>):Bool
    {
        return RemovePropertyObject(name);
    }
    public function Clear():Void
    {
        propertyDict.clear();
        keyObjects.clear();
    }
    public function GetPropertyNames():Array<IPropertyKey>
    {
        var names:Array<IPropertyKey> = [];
        for (key in keyObjects)
        {
            names.push(key);
        }
        return names;
    }
    public function ToSerializable():SerializablePropertyDictionary
    {
        var properties = new Map<String, Dynamic>();
        for (keyInt in propertyDict.keys())
        {
            var key = keyObjects.get(keyInt);
            var fullName = PropertyMapper.ConvertToFullName(key);
            if (fullName == null || fullName.length == 0)
            {
                Debug.LogWarning('Trying to serialize a property with key $key, which is not registered.');
                continue;
            }
            properties.set(fullName, propertyDict.get(keyInt));
        }
        return new SerializablePropertyDictionary(properties);
    }
    public function LoadFromSerializable(seri:Null<SerializablePropertyDictionary>):Void
    {
        propertyDict.clear();
        keyObjects.clear();
        if (seri != null && seri.properties != null)
        {
            for (name in seri.properties.keys())
            {
                var key = PropertyMapper.ConvertFromName(name);
                propertyDict.set(key.Key, seri.properties.get(name));
                keyObjects.set(key.Key, key);
            }
        }
    }
    public var Count(get, never):Int;
    inline function get_Count():Int return Lambda.count(propertyDict);
    // PORT-NOTE: C# 用 `value.Equals(valueBefore)`；Haxe 中对 Dynamic 无法直接调用 Equals，
    // 用 Reflect 调用同名的 Equals 方法，否则退化为引用比较（与 C# 默认行为一致）。
    private static function valueEquals(a:Dynamic, b:Dynamic):Bool
    {
        if (a == null || b == null)
            return a == b;
        if (Reflect.hasField(a, "Equals"))
        {
            var result:Dynamic = Reflect.callMethod(a, Reflect.field(a, "Equals"), [b]);
            if (Std.isOfType(result, Bool))
                return cast result;
        }
        return a == b;
    }
    private var propertyDict:Map<Int, Dynamic> = new Map<Int, Dynamic>();
    private var keyObjects:Map<Int, IPropertyKey> = new Map<Int, IPropertyKey>();
}
