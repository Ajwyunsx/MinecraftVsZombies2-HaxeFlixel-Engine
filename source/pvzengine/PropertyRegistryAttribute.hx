// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyRegistryAttribute.cs
package pvzengine;

// PORT-NOTE: C# 的 Attribute 在 Haxe 中没有运行期对应物，既有移植代码改用编译期元数据
// （如字段上的 `@:propertyRegistry(PROP_REGION)`），本类保留 C# 结构以维持 1:1
// （PropertyMapper.GetPropertyRegionName 仍以本类型作为参数类型）。
class PropertyRegistryAttribute
{
    public function new(?regionName:String, ?typeName:String)
    {
        TypeName = typeName;
        RegionName = regionName;
    }
    public var TypeName(default, null):Null<String>;
    public var RegionName(default, null):Null<String>;
}
