// Ported from: Assets/Scripts/Engine/Level/Entities/Hitboxes/CustomHitbox.cs
package pvzengine.collisions;

import pvzengine.entities.Entity;
import unity.Vector3;

class CustomHitbox extends Hitbox
{
	public function new(entity:Entity)
	{
		super(entity);
	}
	public function SetSize(value:Vector3):Void
	{
		size = value;
	}
	public function SetPivot(value:Vector3):Void
	{
		pivot = value;
	}
	public function SetOffset(value:Vector3):Void
	{
		offset = value;
	}
	override public function GetSize():Vector3
	{
		return size;
	}
	override public function GetPivot():Vector3
	{
		return pivot;
	}
	override public function GetOffset():Vector3
	{
		return offset;
	}

	private var size:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var pivot:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var offset:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
