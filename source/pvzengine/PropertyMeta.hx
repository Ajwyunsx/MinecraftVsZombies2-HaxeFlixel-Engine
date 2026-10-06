// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyMeta.cs
package pvzengine;

// PORT-NOTE: C# 中 `PropertyMeta` 是非泛型的抽象基类，`PropertyMeta<T>` 继承它，并通过
// `implicit operator PropertyKey<T>(PropertyMeta<T>)` 隐式转换为属性键。
// Haxe 是单继承，且既有移植代码把属性元数据直接当 `PropertyKey<T>` 用（如
// `def.SetProperty(LogicEntityProps.NAME, ...)`、`PropertyDictionary.GetProperty(PROP_X)`），
// 因此这里让 `PropertyMeta<T>` 直接继承 `PropertyKey<T>`（隐式转换由子类型关系天然成立），
// 非泛型基类改为标记接口 `IPropertyMeta`（供 PropertyMapper 做反射扫描时的运行期类型判定）。
// 这与 mvz2/entities/EntityController.hx 中的 PORT-NOTE 一致。
interface IPropertyMeta
{
    public function RegisterNames(namespaceName:String, regionName:String):Void;
    public function SetRegisteredKey(key:IPropertyKey):Void;
    public function CreateKey(namespaceKey:Int, propertyKey:Int):IPropertyKey;
    public function GetPropertyName():String;
    public function GetPropertyType():Dynamic;
    public function GetDefaultValueObject():Dynamic;
    public function GetObsoleteNames():Array<String>;
}

class PropertyMeta<T> extends PropertyKey<T> implements IPropertyMeta
{
    public function new(name:String, ?defaultValue:Null<T>, ?obsoleteNames:Array<String>)
    {
        super(0, 0, defaultValue);
        propertyName = name;
        this.defaultValue = defaultValue;
        this.obsoleteNames = obsoleteNames != null ? obsoleteNames : [];
    }
    override public function ToString():String
    {
        return PropertyKeyHelper.CombineFullName(namespaceName, regionName, propertyName);
    }
    // C#: public abstract void SetRegisteredKey(IPropertyKey key);
    public function SetRegisteredKey(key:IPropertyKey):Void
    {
        if (key == null)
            return;
        // C#: if (key is PropertyKey<T> tKey) { this.key = tKey; }
        this.key = key.Key;
        this.defaultValue = cast key.DefaultValue;
    }
    // PORT-NOTE: C# 用 PropertyKeyHelper.FromType（反射）创建键；Haxe 无法按 System.Type 构造泛型类型，
    // 改由元数据自身（泛型实参在编译期已知）创建与其类型一致的属性键。
    public function CreateKey(namespaceKey:Int, propertyKey:Int):IPropertyKey
    {
        return new PropertyKey<T>(namespaceKey, propertyKey, defaultValue);
    }
    // PORT-NOTE: C# 的 `Equals(object obj)` 是 override；父类 PropertyKey<T> 已有 `Equals(IPropertyKey)`，
    // Haxe 不允许同名字段的不同签名，故改名 EqualsObject。
    public function EqualsObject(obj:Dynamic):Bool
    {
        if (obj == null)
            return false;
        if (Std.isOfType(obj, IPropertyKey))
        {
            return EqualsKey(cast obj);
        }
        if (Std.isOfType(obj, IPropertyMeta))
        {
            var meta:PropertyMeta<Dynamic> = cast obj;
            return namespaceName == meta.namespaceName &&
                propertyName == meta.propertyName &&
                regionName == meta.regionName;
        }
        return false;
    }
    override public function GetHashCode():Int
    {
        // C#: HashCode.Combine(namespaceName, regionName, propertyName)
        var hash = 17;
        hash = hash * 31 + hashString(namespaceName);
        hash = hash * 31 + hashString(regionName);
        hash = hash * 31 + hashString(propertyName);
        return hash;
    }
    private static function hashString(str:String):Int
    {
        if (str == null)
            return 0;
        var hash = 7;
        for (i in 0...str.length)
        {
            hash = hash * 31 + str.charCodeAt(i);
        }
        return hash;
    }
    public function RegisterNames(namespaceName:String, regionName:String):Void
    {
        this.namespaceName = namespaceName;
        this.regionName = regionName;
    }
    public function GetPropertyName():String return propertyName;
    public function GetPropertyType():Dynamic return propertyType;
    public function GetDefaultValueObject():Dynamic return defaultValue;
    public function GetObsoleteNames():Array<String> return obsoleteNames;
    public var namespaceName:Null<String>;
    public var regionName:Null<String>;
    public var propertyName:String;
    public var obsoleteNames:Array<String>;
    // PORT-NOTE: C# 为 `System.Type propertyType`。Haxe 无运行期泛型类型信息，保留同名成员以维持 1:1，
    // 其值由调用方/反射填充（当前移植版中不被使用）。
    public var propertyType:Dynamic;
}
