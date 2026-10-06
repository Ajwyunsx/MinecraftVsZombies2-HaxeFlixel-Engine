// Ported from: Assets/Scripts/View/Level/HintArrow.cs
package mvz2.ui.level;

import unity.Transform;
import unity.Vector2;
import unity.Vector3;
import unity.MonoBehaviour;

class HintArrow extends unity.MonoBehaviour
{
	public function SetVisible(visible:Bool):Void
	{
		gameObject.SetActive(visible);
	}
	public function SetTarget(target:Transform, offset:Vector2, angle:Float):Void
	{
		targetTransform = target;
		targetOffset = offset;
		transform.localEulerAngles = new Vector3(0, 0, angle);
		UpdatePosition();
	}
	function Update():Void
	{
		if (updatesPosition)
			UpdatePosition();
	}
	private function UpdatePosition():Void
	{
		if (targetTransform != null)
		{
			var position = transform.position;
			position.x = targetTransform.position.x + targetOffset.x;
			position.y = targetTransform.position.y + targetOffset.y;
			transform.position = position;
		}
		else
		{
			transform.position = new Vector3(-1000, -1000, 0);
		}
	}
	@:serializeField
	private var updatesPosition:Bool = true;
	@:serializeField
	private var targetTransform:Transform;
	@:serializeField
	private var targetOffset:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 null 解引用（该字段在 Unity 由 prefab 序列化赋值，移植层由 prefab 数据覆盖）
}
