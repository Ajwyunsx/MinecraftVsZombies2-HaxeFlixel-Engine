// Ported from: Assets/Scripts/Logic/Inputs/PointerPhase.cs (class PointerHelper)
// PORT-NOTE: C# 扩展方法 (this PointerInteractionData) 改为静态方法，接收者作为第一个参数。
package mvz2logic.inputs;

class PointerHelper
{
	public static function IsInvalidReleaseAction(pointerParams:PointerInteractionData):Bool
	{
		if (pointerParams.pointer.type == PointerTypes.TOUCH)
		{
			if (pointerParams.interaction != PointerInteraction.Release)
				return true;
		}
		else if (pointerParams.pointer.type == PointerTypes.MOUSE)
		{
			if (pointerParams.interaction != PointerInteraction.Down)
				return true;
		}
		return false;
	}
	public static function IsInvalidClickButton(pointerParams:PointerInteractionData):Bool
	{
		if (pointerParams.pointer.type == PointerTypes.MOUSE)
		{
			if (pointerParams.pointer.button != MouseButtons.LEFT)
				return true;
		}
		return false;
	}
	public static function IsPointerDownOrDrag(interaction:PointerInteractionData):Bool
	{
		if (interaction.pointer.type == PointerTypes.TOUCH)
		{
			if (interaction.interaction == PointerInteraction.Release || interaction.interaction == PointerInteraction.Drag)
				return true;
		}
		else if (interaction.pointer.type == PointerTypes.MOUSE)
		{
			if (interaction.interaction == PointerInteraction.Down)
				return true;
		}
		return false;
	}

	private function new() {}
}
