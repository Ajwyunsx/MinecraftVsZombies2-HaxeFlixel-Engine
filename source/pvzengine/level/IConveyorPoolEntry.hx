// Ported from: Assets/Scripts/Engine/Level/Level/IConveyorPoolEntry.cs
package pvzengine.level;

import pvzengine.NamespaceID;

// PORT-NOTE: C# 的 `NamespaceID ID { get; }` 等只读属性 → Haxe `(default, null)` 字段。
// 既有实现 mvz2/metas/ConveyorPoolEntry.hx 用的正是 `public var ID(default, null):NamespaceID;`
// 形式，故接口属性也必须写成 `(default, null)`（Haxe 要求接口与实现类的属性访问权限一致）。
interface IConveyorPoolEntry
{
	public var ID(default, null):NamespaceID;
	public var Count(default, null):Int;
	public var MinCount(default, null):Int;
}
