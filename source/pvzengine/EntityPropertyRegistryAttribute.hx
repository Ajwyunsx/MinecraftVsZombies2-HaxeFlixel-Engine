// Ported from: Assets/Scripts/Engine/Level/Properties/EntityPropertyRegistryAttribute.cs
package pvzengine;

// PORT-NOTE: C# 特性（Attribute）在 Haxe 中改为编译期元数据：既有移植代码使用
// `@:propertyRegistryRegion(PropertyRegions.entity)`（类上）与 `@:propertyRegistry(region)`
// （字段上），见 mvz2/vanilla/entities/VanillaEntityProps.hx。因此本类不再被当作 Haxe 特性使用，
// 仅保留 C# 的类结构与默认 region 语义以维持 1:1。
class EntityPropertyRegistryAttribute extends PropertyRegistryAttribute
{
	public function new(?regionName:String)
	{
		super(regionName, PropertyRegions.entity);
	}
}
