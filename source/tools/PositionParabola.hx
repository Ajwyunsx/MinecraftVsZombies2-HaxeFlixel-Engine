// Ported from: Assets/Scripts/Engine/Tools/Unity/PositionParabola.cs
package tools;

import tools.mathematics.MathTool;
import unity.Mathf;
import unity.Vector3;

@:executeInEditMode
class PositionParabola extends PositionTransitor
{
	public function new()
	{
		super();
	}

	override function Transit(start:Vector3, end:Vector3, time:Float):Vector3
	{
		var relativeY = end.y - start.y;
		var y = MathTool.LerpParabolla(0, 0, Mathf.Max(relativeY, maxHeight), time, inner);
		return Vector3.Lerp(start, end, time) + axis * y;
	}
	@:serializeField
	private var axis:Vector3 = new Vector3();
	@:serializeField
	private var maxHeight:Float = 0;
	@:serializeField
	private var inner:Bool = false;
}
