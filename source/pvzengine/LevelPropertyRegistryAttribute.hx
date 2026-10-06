// Ported from: Assets/Scripts/Engine/Level/Properties/LevelPropertyRegistryAttribute.cs
package pvzengine;

// PORT-NOTE: 同 EntityPropertyRegistryAttribute —— C# 特性改为 Haxe 元数据
// `@:propertyRegistryRegion(PropertyRegions.level)`（见 mvz2/gamecontent/difficulties/VanillaDifficultyLevelProps.hx）。
// 本类仅保留 C# 结构以维持 1:1。
class LevelPropertyRegistryAttribute extends PropertyRegistryAttribute
{
	public function new(?regionName:String)
	{
		super(regionName, PropertyRegions.level);
	}
}
