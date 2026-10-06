// Ported from: Assets/Scripts/Engine/Level/Entities/Hitboxes/HitboxTemplate.cs
package pvzengine.collisions;

import unity.Vector3;

class HitboxTemplate
{
	public function new() {}

	public var Size:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var Offset:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
