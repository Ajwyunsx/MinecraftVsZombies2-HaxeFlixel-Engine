// Ported from: Assets/Scripts/View/Level/Blueprints/ClassicBlueprintSet.cs
package mvz2.ui.level;

import mvz2.ui.ElementList;
import unity.UnityObject;
import unity.Vector2;
import unity.Vector3;

// abstract
class ClassicBlueprintSet extends BlueprintSet
{
	public function SetSlotCount(count:Int):Void
	{
		slots.updateList(count);
	}
	public function GetBlueprintLocalPosition(index:Int):Vector2
	{
		if (horizontal)
		{
			return offset + new Vector2(1, 0) * index * cellSize.x;
		}
		return offset + new Vector2(0, -1) * index * cellSize.y;
	}
	// abstract
	public function GetBlueprintCount():Int throw "abstract";
	function Update():Void
	{
		for (i in 0...GetBlueprintCount())
		{
			var element = GetBlueprintAt(i);
			if (!UnityObject.exists(element))
				continue;
			var localPos = element.transform.localPosition;
			localPos = Vector3.Lerp(localPos, new Vector3(GetBlueprintLocalPosition(i).x, GetBlueprintLocalPosition(i).y, 0), alignSpeed);
			element.transform.localPosition = localPos;
		}
	}
	@:serializeField
	private var slots:ElementList;
	@:serializeField
	private var offset:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 null 解引用（该字段在 Unity 由 prefab 序列化赋值，移植层由 prefab 数据覆盖）
	@:serializeField
	private var cellSize:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 null 解引用（该字段在 Unity 由 prefab 序列化赋值，移植层由 prefab 数据覆盖）
	@:serializeField
	private var alignSpeed:Float = 0.5;
}
