// Ported from: Assets/Scripts/MVZ2/Managers/ResourceManager.cs 中使用的 C# 值元组 `(NamespaceID key, T resource)`
package mvz2.managers;

import pvzengine.NamespaceID;

// TODO-PORT: C# 使用 System.ValueTuple 作为 `LoadResourcesByLocations<T>` 的返回元素类型，
// Haxe 无值元组，改用等价的小型数据类。
class ResourceLoadPair<T>
{
	public var key:NamespaceID;
	public var resource:T;

	public function new(key:NamespaceID, resource:T)
	{
		this.key = key;
		this.resource = resource;
	}
}
