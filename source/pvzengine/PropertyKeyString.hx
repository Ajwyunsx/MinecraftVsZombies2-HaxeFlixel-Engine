// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyKeyString.cs
package pvzengine;

// PORT-NOTE: C# 的 `PropertyKeyString` 是 struct，并定义了到/从 string 的隐式转换，以及 `==` / `!=`（值语义）。
// 既有移植代码（mvz2/models/Model.hx、各 Model 子类）直接传入字符串字面量
// （如 `Model.SetProperty("points", points)`、`TriggerModel("GunFire")`），因此这里移植为
// `abstract PropertyKeyString(String) from String to String`：
//   * from/to String 复刻 C# 的隐式转换；
//   * `==` / `!=` 与 `Map<PropertyKeyString, V>` 均为值语义（与 C# struct 一致）。
abstract PropertyKeyString(String) from String to String
{
    public inline function new(propertyKey:String)
    {
        this = propertyKey;
    }
    public function Equals(obj:Dynamic):Bool
    {
        if (obj == null)
            return false;
        return (this : String) == Std.string(obj);
    }
    public function GetHashCode():Int
    {
        // C#: HashCode.Combine(propertyKey)
        if (this == null)
            return 0;
        var hash = 7;
        for (i in 0...this.length)
        {
            hash = hash * 31 + this.charCodeAt(i);
        }
        return hash;
    }
    public static function IsValid(key:PropertyKeyString):Bool
    {
        return key != null && (key : String) != null && (key : String).length > 0;
    }
    public function ToString():String
    {
        return this;
    }
    public function toString():String
    {
        return this;
    }
    public var propertyKey(get, never):String;
    inline function get_propertyKey():String
    {
        return this;
    }
}
