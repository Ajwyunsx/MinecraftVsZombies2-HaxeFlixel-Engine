// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyKey.cs (static class PropertyKeyHelper)
package pvzengine;

import pvzengine.IPropertyKey;
import pvzengine.PropertyKey;
import pvzengine.PropertyKey.InvalidPropertyKey;
import tools.Ref;

// PORT-NOTE: 见 IPropertyKey.hx 顶部说明（原 C# 文件被拆为多个 Haxe 模块）。
class PropertyKeyHelper
{
    // PORT-NOTE: C# 的 `params string?[] names` 在 Haxe 中没有直接对应物，但既有调用点最多传 3 个名字
    // （`CombineFullName(nsp, region, path, key)`），因此改为定长可选参数，语义等价。
    public static function CombineFullName(namespaceName:String, ?name0:String, ?name1:String, ?name2:String, ?name3:String):String
    {
        var laterName = CombineRegionName(name0, name1, name2, name3);
        if (namespaceName != null && namespaceName.length > 0)
        {
            return '$namespaceName:$laterName';
        }
        return laterName;
    }
    public static function CombineRegionName(?name0:String, ?name1:String, ?name2:String, ?name3:String):String
    {
        var names = [name0, name1, name2, name3];
        var valid = [];
        for (name in names)
        {
            if (name != null)
                valid.push(name);
        }
        return valid.join("/");
    }
    // PORT-NOTE: C# 的 `out string? nsp, out string? region, out string property` 在 Haxe 中用 tools.Ref 表达。
    public static function ParsePropertyName(text:String, nsp:Ref<Null<String>>, region:Ref<Null<String>>, property:Ref<String>):Void
    {
        var colon = text.indexOf(':');
        var slash = text.lastIndexOf("/");
        if (colon >= 0)
        {
            nsp.value = text.substr(0, colon);
            if (slash >= 0)
            {
                region.value = text.substring(colon + 1, slash);
                property.value = text.substr(slash + 1);
            }
            else
            {
                region.value = null;
                property.value = text.substr(colon + 1);
            }
        }
        else
        {
            nsp.value = null;
            if (slash >= 0)
            {
                region.value = text.substr(0, slash);
                property.value = text.substr(slash + 1);
            }
            else
            {
                region.value = null;
                property.value = text;
            }
        }
    }
    public static function ParsePropertyFullName(propertyName:String, defaultNsp:String, ?regionName:String):String
    {
        var propID = NamespaceID.Parse(propertyName, defaultNsp);
        if (regionName == null || regionName.length == 0)
        {
            return PropertyKeyHelper.CombineFullName(propID.SpaceName, propID.Path);
        }
        return PropertyKeyHelper.CombineFullName(propID.SpaceName, regionName, propID.Path);
    }
    // PORT-NOTE: C# 通过反射（`typeof(PropertyKey<>).MakeGenericType(propertyType)`）创建属性键。
    // Haxe 没有运行期泛型，无法按 System.Type 构造 PropertyKey<T>；PropertyMapper 改为调用
    // `PropertyMeta<T>.CreateKey(namespaceKey, propertyKey)`（泛型实参在编译期已知）。
    // 此方法保留以维持 1:1 的公开 API。
    public static function FromType(namespaceKey:Int, propertyKey:Int, propertyType:Dynamic, defaultValue:Dynamic):IPropertyKey
    {
        return new PropertyKey<Dynamic>(namespaceKey, propertyKey, defaultValue);
    }
    // C#: public static bool IsValid(this IPropertyKey key) —— 扩展方法，Haxe 中为普通静态方法。
    public static function IsValid(key:IPropertyKey):Bool
    {
        if (key == null)
            return false;
        return key.Key > 0;
    }
    public static var Invalid(default, null):IPropertyKey = new InvalidPropertyKey();
}
