// Ported from: Assets/Scripts/Logic/Inputs/InputHelper.cs (class InputHelper)
package mvz2logic.inputs;

import tools.Ref;
import unity.Input;
import unity.Touch.TouchPhase;
import unity.Vector2;
import unity.eventsystems.PointerEventData;

class InputHelper
{
	//region 检测指针状态
	// TODO-PORT: C# 重载 IsPointerDown(int type, int button)，Haxe 不支持重载，重命名为 IsPointerDownByButton
	public static function IsPointerDownByButton(type:Int, button:Int):Bool return IsPointerDown(GetPointerIdByButtonAndType(button, type));
	// TODO-PORT: C# 重载 IsPointerHolding(int type, int button)，Haxe 不支持重载，重命名为 IsPointerHoldingByButton
	public static function IsPointerHoldingByButton(type:Int, button:Int):Bool return IsPointerHolding(GetPointerIdByButtonAndType(button, type));
	// TODO-PORT: C# 重载 IsPointerUp(int type, int button)，Haxe 不支持重载，重命名为 IsPointerUpByButton
	public static function IsPointerUpByButton(type:Int, button:Int):Bool return IsPointerUp(GetPointerIdByButtonAndType(button, type));
	public static function IsPointerDown(pointerId:Int):Bool
	{
		return IsPointerOfPhase(pointerId, PointerPhase.Press);
	}
	public static function IsPointerHolding(pointerId:Int):Bool
	{
		return IsPointerOfPhase(pointerId, PointerPhase.Hold);
	}
	public static function IsPointerUp(pointerId:Int):Bool
	{
		return IsPointerOfPhase(pointerId, PointerPhase.Release);
	}
	public static function IsPointerOfPhase(pointerId:Int, phase:PointerPhase):Bool
	{
		if (IsPointerMouse(pointerId))
		{
			var mouseButton = GetPointerButton(pointerId);
			switch (phase)
			{
				case PointerPhase.Press:
					return Input.GetMouseButtonDown(mouseButton);
				case PointerPhase.Hold:
					return Input.GetMouseButton(mouseButton);
				case PointerPhase.Release:
					return Input.GetMouseButtonUp(mouseButton);
				default:
			}
			return false;
		}
		var touches = Input.touches;
		for (i in 0...touches.length)
		{
			var touch = touches[i];
			if (touch.fingerId == pointerId)
			{
				switch (phase)
				{
					case PointerPhase.Press:
						return touch.phase == TouchPhase.Began;
					case PointerPhase.Hold:
						return touch.phase == TouchPhase.Stationary || touch.phase == TouchPhase.Moved;
					case PointerPhase.Release:
						return touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled;
					default:
				}
			}
		}
		return false;
	}
	public static function IsMouseButNotLeft(data:PointerEventData):Bool
	{
		var pointerType = GetPointerType(data.pointerId);
		var pointerButton = GetPointerButton(data.pointerId);
		return pointerType == PointerTypes.MOUSE && pointerButton != MouseButtons.LEFT;
	}
	//endregion

	//region 指针ID转换
	public static function GetPointerIdByButtonAndType(button:Int, type:Int):Int
	{
		return type == PointerTypes.MOUSE ? -button - 1 : button;
	}
	public static function GetPointerButton(pointerId:Int):Int
	{
		return IsPointerMouse(pointerId) ? -pointerId - 1 : pointerId;
	}
	public static function GetPointerType(pointerId:Int):Int
	{
		return IsPointerMouse(pointerId) ? PointerTypes.MOUSE : PointerTypes.TOUCH;
	}
	public static function IsPointerMouse(pointerId:Int):Bool
	{
		return pointerId < 0;
	}
	//endregion

	//region 指针数据
	public static function GetPointerDataFromEventData(eventData:PointerEventData):PointerData
	{
		return GetPointerDataFromPointerId(eventData.pointerId);
	}
	public static function GetPointerDataFromPointerId(pointerId:Int):PointerData
	{
		var data = new PointerData();
		data.button = GetPointerButton(pointerId);
		data.type = GetPointerType(pointerId);
		return data;
	}
	public static function GetPointerInteractionParamsFromEventData(eventData:PointerEventData, interaction:PointerInteraction):PointerInteractionData
	{
		var data = new PointerInteractionData();
		data.pointer = GetPointerDataFromEventData(eventData);
		data.interaction = interaction;
		return data;
	}
	public static function GetPointerInteractionParamsFromPointerId(pointerId:Int, interaction:PointerInteraction):PointerInteractionData
	{
		var data = new PointerInteractionData();
		data.pointer = GetPointerDataFromPointerId(pointerId);
		data.interaction = PointerInteraction.Hold;
		return data;
	}
	//endregion

	//region 获取指针位置
	// TODO-PORT: C# 重载 GetPointerPosition(int type, int button)，Haxe 不支持重载，重命名为 GetPointerPositionByButton
	public static function GetPointerPosition(pointerId:Int):Vector2
	{
		if (IsPointerMouse(pointerId))
		{
			return new Vector2(Input.mousePosition.x, Input.mousePosition.y);
		}
		var touches = Input.touches;
		for (i in 0...touches.length)
		{
			var touch = touches[i];
			if (touch.fingerId == pointerId)
			{
				return touch.position;
			}
		}
		return Vector2.zero;
	}
	public static function GetPointerPositionByButton(type:Int, button:Int):Vector2
	{
		if (type == PointerTypes.TOUCH)
		{
			if (Input.touchCount > button)
			{
				return Input.GetTouch(button).position;
			}
			return Vector2.zero;
		}
		return new Vector2(Input.mousePosition.x, Input.mousePosition.y);
	}
	public static function TryGetPointerPosition(type:Int, button:Int, screenPosition:Ref<Vector2>):Bool
	{
		if (type == PointerTypes.TOUCH)
		{
			if (Input.touchCount > button)
			{
				screenPosition.value = Input.GetTouch(button).position;
				return true;
			}
		}
		else if (type == PointerTypes.MOUSE)
		{
			screenPosition.value = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
			return true;
		}
		screenPosition.value = Vector2.zero;
		return false;
	}
	//endregion

	//region 获取所有指针
	// PORT-NOTE: C# 为迭代器方法（yield return），Haxe 无 yield 语法，改为返回数组。
	public static function GetTouchUps():Array<PointerPositionParams>
	{
		var results:Array<PointerPositionParams> = [];
		var touches = Input.touches;
		if (touches.length > 0)
		{
			for (i in 0...touches.length)
			{
				var touch = touches[i];
				if (touch.phase == TouchPhase.Canceled || touch.phase == TouchPhase.Ended)
				{
					var param = new PointerPositionParams();
					param.button = i;
					param.type = PointerTypes.TOUCH;
					param.position = touch.position;
					results.push(param);
				}
			}
		}
		return results;
	}
	public static function GetMouseUps(button:Int):Array<PointerPositionParams>
	{
		var results:Array<PointerPositionParams> = [];
		if (Input.GetMouseButtonUp(button))
		{
			var param = new PointerPositionParams();
			param.button = button;
			param.type = PointerTypes.MOUSE;
			param.position = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
			results.push(param);
		}
		return results;
	}
	//endregion

	private function new() {}
}
