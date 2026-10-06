// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyRegistryRegionAttribute.cs
package pvzengine;

// PORT-NOTE: C# 的 Attribute 在 Haxe 中没有运行期对应物，既有移植代码改用编译期元数据
// （类上的 `@:propertyRegistryRegion(PropertyRegions.xxx)`），本类保留 C# 结构以维持 1:1
// （PropertyMapper.GetPropertyRegionName 仍以本类型作为参数类型）。
// C#: [AttributeUsage(AttributeTargets.Class, AllowMultiple = false, Inherited = false)]
class PropertyRegistryRegionAttribute
{
    public function new(?regionName:String)
    {
        RegionName = regionName;
    }
    public var RegionName(default, null):Null<String>;
}
