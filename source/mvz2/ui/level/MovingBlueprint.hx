// Ported from: Assets/Scripts/View/Level/BlueprintChoose/MovingBlueprint.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import tools.PositionTransition;
import unity.Transform;
import unity.Vector3;
import unity.MonoBehaviour;
import unity.Time;
import flixel.util.FlxSignal;

class MovingBlueprint extends unity.MonoBehaviour
{
	function OnDisable():Void
	{
		Finish();
	}
	// PORT-NOTE: C# 的 SetMotion 重载在 Haxe 中改名为 SetMotionToTransform / SetMotionToPosition。
	public function SetMotionToTransform(startPosition:Vector3, targetTransform:Transform):Void
	{
		transition.setStartPosition(startPosition);
		transition.setTargetTransform(targetTransform);
		transition.enabled = true;
		moving = true;
	}
	public function SetMotionToPosition(startPosition:Vector3, targetPosition:Vector3):Void
	{
		transition.setStartPosition(startPosition);
		transition.setTargetPosition(targetPosition);
		transition.enabled = true;
		moving = true;
	}
	public function SetBlueprint(blueprint:Blueprint):Void
	{
		this.blueprint = blueprint;
		blueprint.transform.SetParent(transform, false);
		blueprint.transform.localPosition = new Vector3(0, 0, 0);
	}
	public function Finish():Void
	{
		if (moving)
		{
			moving = false;
			transition.time = 1;
			OnMotionFinished.dispatch(this);
		}
	}
	function Update():Void
	{
		if (moving)
		{
			transition.time += unity.Time.deltaTime * moveSpeed;
			if (transition.time >= 1)
			{
				Finish();
			}
		}
	}
	public var OnMotionFinished:FlxTypedSignal<MovingBlueprint->Void> = new FlxTypedSignal();
	@:serializeField
	private var moving:Bool;
	@:serializeField
	private var moveSpeed:Float;
	@:serializeField
	private var transition:PositionTransition;
	@:serializeField
	private var blueprint:Null<Blueprint>;
}
