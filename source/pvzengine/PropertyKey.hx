// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyKey.cs (struct PropertyKey<T>)
package pvzengine;

// PORT-NOTE: 见 IPropertyKey.hx 顶部说明（原 C# 文件被拆为多个 Haxe 模块）。
class PropertyKey<T> implements IPropertyKey
{
    public function new(namespaceKey:Int, propertyKey:Int, defaultValue:Null<T>)
    {
        key = ((propertyKey << PROPERTY_KEY_SHIFT) & PROPERTY_KEY_MASK) |
            ((namespaceKey << NAMESPACE_KEY_SHIFT) & NAMESPACE_KEY_MASK);
        this.defaultValue = defaultValue;
    }
    // PORT-NOTE: 既有移植代码（mvz2/entities/EntityController.hx、mvz2logic 等）需要把属性元数据
    // 当作属性键使用（C# 依靠 `implicit operator PropertyKey<T>(PropertyMeta<T>)`），
    // 因此把编码后的键与默认值暴露为可写字段，供 PropertyMeta<T>（其子类）注册时写入。
    public var key:Int;
    public var defaultValue:Null<T>;
    public var Key(get, never):Int;
    inline function get_Key():Int return key;
    public var Type(get, never):Dynamic;
    inline function get_Type():Dynamic return null;
    public var DefaultValue(get, never):Null<T>;
    inline function get_DefaultValue():Null<T> return defaultValue;
    public function GetDefaultValue():Null<T> return defaultValue;
    public function SetKey(namespaceKey:Int, propertyKey:Int):Void
    {
        key = ((propertyKey << PROPERTY_KEY_SHIFT) & PROPERTY_KEY_MASK) |
            ((namespaceKey << NAMESPACE_KEY_SHIFT) & NAMESPACE_KEY_MASK);
    }
    public function Equals(other:IPropertyKey):Bool
    {
        if (other == null)
            return false;
        return key == other.Key;
    }
    // PORT-NOTE: C# 中 Equals(PropertyKey<T>) 与 Equals(IPropertyKey) 是重载，Haxe 无重载，后者改名 EqualsKey。
    public function EqualsKey(other:PropertyKey<T>):Bool
    {
        if (other == null)
            return false;
        return key == other.key;
    }
    public function ToString():String
    {
        return Std.string(key);
    }
    public function GetHashCode():Int
    {
        return key;
    }
    private static inline var PROPERTY_BITS = 20;
    private static inline var NAMESPACE_BITS = 12;

    private static inline var PROPERTY_KEY_SHIFT = 0;
    private static inline var PROPERTY_KEY_MASK = (1 << PROPERTY_BITS) - 1;
    private static inline var NAMESPACE_KEY_SHIFT = PROPERTY_KEY_SHIFT + PROPERTY_BITS;
    private static inline var NAMESPACE_KEY_MASK = ((1 << NAMESPACE_BITS) - 1) << NAMESPACE_KEY_SHIFT;
}

// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyKey.cs (struct InvalidPropertyKey)
// PORT-NOTE: C# 的 struct 在 Haxe 中改为 class（同工程其他 struct 的处理方式）。
class InvalidPropertyKey implements IPropertyKey
{
    public function new() {}
    public var Key(get, never):Int;
    inline function get_Key():Int return 0;
    public var Type(get, never):Dynamic;
    inline function get_Type():Dynamic return null;
    public var DefaultValue(get, never):Dynamic;
    inline function get_DefaultValue():Dynamic return null;
    public function ToString():String return "0";
}

// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyKey.cs (class PropertyKeyComparer)
// PORT-NOTE: C# 中用于 `Dictionary<IPropertyKey, object>` 的相等比较器。
// Haxe 版 PropertyDictionary 改用 `Map<Int, Dynamic>`（以 Key 为键），本类仅为保留 C# 结构而存在。
class PropertyKeyComparer
{
    public function new() {}
    public function Equals(x:IPropertyKey, y:IPropertyKey):Bool
    {
        if (x == y)
            return true;
        if (x == null || y == null)
            return false;
        return x.Key == y.Key; // 直接比较 int Key
    }
    public function GetHashCode(obj:IPropertyKey):Int
    {
        if (obj == null)
            return 0;
        return obj.Key; // 直接使用 int 的哈希码
    }
}
