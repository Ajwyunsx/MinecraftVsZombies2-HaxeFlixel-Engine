// Ported from: Assets/Scripts/View/UI/PanZoomController.cs
package mvz2.ui;

import unity.Camera;
import unity.Input;
import unity.Mathf;
import unity.RectTransform;
import unity.RectTransformUtility;
import unity.Touch;
import unity.UnityObject;
import unity.Vector2;
import unity.Vector3;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import unity.Time;
import unity.Mathf.FloatRef;
import unity.RectTransformUtility.Vector2Ref;
import unity.Touch.TouchPhase;
import unity.eventsystems.IEventSystemHandler.IDragHandler;
import unity.eventsystems.IEventSystemHandler.IScrollHandler;

// @:RequireComponent(RectTransform)
class PanZoomController extends unity.MonoBehaviour implements IDragHandler implements IScrollHandler
{
	function Awake():Void
	{
		rectTransform = GetComponent(RectTransform);
		originalScale = new Vector3(1, 1, 1);
		originalPosition = new Vector3(0, 0, 0);
		targetPosition = originalPosition;
		ResetView();
	}

	function Update():Void
	{
		// 处理双指触控
		HandleTouchInput();

		// 平滑移动
		if (smoothPan && rectTransform.localPosition != targetPosition)
		{
			var velocityRef:unity.Mathf.FloatRef = {value: 0};
			rectTransform.localPosition = smoothDampPosition(rectTransform.localPosition, targetPosition, smoothTime);
			if (enableConstraints)
			{
				ApplyMovementConstraints();
			}
		}
	}

	// PORT-NOTE: Vector3.SmoothDamp 需要 ref velocity，Haxe 用实例字段 velocity 保存速度。
	private function smoothDampPosition(current:Vector3, target:Vector3, smoothTime:Float):Vector3
	{
		var velRef:unity.Mathf.FloatRef = {value: velocity.x};
		var velRefY:unity.Mathf.FloatRef = {value: velocity.y};
		var velRefZ:unity.Mathf.FloatRef = {value: velocity.z};
		var result = new Vector3(
			Mathf.SmoothDamp(current.x, target.x, velRef, smoothTime, Math.POSITIVE_INFINITY, unity.Time.deltaTime),
			Mathf.SmoothDamp(current.y, target.y, velRefY, smoothTime, Math.POSITIVE_INFINITY, unity.Time.deltaTime),
			Mathf.SmoothDamp(current.z, target.z, velRefZ, smoothTime, Math.POSITIVE_INFINITY, unity.Time.deltaTime));
		velocity = new Vector3(velRef.value, velRefY.value, velRefZ.value);
		return result;
	}

	// 处理鼠标拖拽
	public function OnDrag(eventData:PointerEventData):Void
	{
		// 只响应鼠标左键或单指触控
		if (eventData.pointerId == -1 || eventData.pointerId == 0)
		{
			var localPos1 = ScreenToLocalPoint(eventData.position - eventData.delta);
			var localPos2 = ScreenToLocalPoint(eventData.position);
			var localDelta = localPos2 - localPos1;
			var delta = localDelta * panSensitivity;
			targetPosition += new Vector3(delta.x, delta.y, 0);
			if (!smoothPan)
			{
				rectTransform.localPosition = targetPosition;
			}
			if (enableConstraints)
			{
				ApplyMovementConstraints();
			}
		}
	}

	// 处理鼠标滚轮缩放
	public function OnScroll(eventData:PointerEventData):Void
	{
		Zoom(eventData.scrollDelta.y * zoomSpeed, eventData.position);
	}

	// 处理触屏输入
	private function HandleTouchInput():Void
	{
		// 双指触控
		if (Input.touchCount == 2)
		{
			var touch1 = Input.GetTouch(0);
			var touch2 = Input.GetTouch(1);

			// 初始状态
			if (touch2.phase == TouchPhase.Began)
			{
				initialDistance = Vector2.Distance(touch1.position, touch2.position);
				initialScale = rectTransform.localScale;
				initialMidpoint = (touch1.position + touch2.position) * 0.5;
				initialPosition = rectTransform.localPosition;
			}

			// 移动中
			if (touch1.phase == TouchPhase.Moved || touch2.phase == TouchPhase.Moved)
			{
				// 计算当前距离和缩放比例
				var currentDistance = Vector2.Distance(touch1.position, touch2.position);
				var scaleFactor = currentDistance / initialDistance;
				var newScale = initialScale * scaleFactor;

				// 应用缩放限制
				newScale = new Vector3(
					Mathf.Clamp(newScale.x, minZoom, maxZoom),
					Mathf.Clamp(newScale.y, minZoom, maxZoom),
					1
				);

				rectTransform.localScale = newScale;

				// 计算中点位置变化
				var currentMidpoint = (touch1.position + touch2.position) * 0.5;
				var midpointDelta = currentMidpoint - initialMidpoint;

				// 根据缩放比例调整移动量
				midpointDelta *= 1 / rectTransform.localScale.x;

				// 更新位置
				rectTransform.localPosition = initialPosition + new Vector3(midpointDelta.x, midpointDelta.y, 0);
				targetPosition = rectTransform.localPosition;

				if (enableConstraints)
				{
					ApplyMovementConstraints();
				}
			}
		}
	}
	private function ScreenToLocalPoint(position:Vector2):Vector2
	{
		var canvas = UIHelper.GetRootCanvas(rectTransform);
		if (!UnityObject.exists(canvas))
			return new Vector2(0, 0);
		var camera = canvas.worldCamera;
		var localPoint:unity.RectTransformUtility.Vector2Ref = {value: new Vector2()};
		RectTransformUtility.ScreenPointToLocalPointInRectangle(
			cast rectTransform.parent,
			position,
			camera,
			localPoint
		);
		return localPoint.value;
	}

	// 缩放函数
	private function Zoom(increment:Float, zoomCenter:Vector2):Void
	{
		// 计算缩放前的局部坐标
		var localPoint = ScreenToLocalPoint(zoomCenter);

		// 计算缩放比例
		var newScale = Mathf.Clamp(
			rectTransform.localScale.x + increment,
			minZoom,
			maxZoom
		);

		// 应用缩放
		var oldScale = rectTransform.localScale;
		rectTransform.localScale = new Vector3(newScale, newScale, 1);

		// 计算缩放后位置偏移
		var scaleFactor = new Vector3(newScale / oldScale.x, newScale / oldScale.y, 1 / oldScale.z);
		var localPos = rectTransform.localPosition;
		localPos = Vector3.Scale(localPos - new Vector3(localPoint.x, localPoint.y, 0), scaleFactor) + new Vector3(localPoint.x, localPoint.y, 0);

		// 更新位置
		rectTransform.localPosition = localPos;
		targetPosition = rectTransform.localPosition;
		if (enableConstraints)
		{
			ApplyMovementConstraints();
		}
	}

	// 重置视图
	public function ResetView():Void
	{
		rectTransform.localScale = originalScale;
		rectTransform.localPosition = originalPosition;
		targetPosition = originalPosition;
		velocity = new Vector3(0, 0, 0);
		if (enableConstraints)
		{
			ApplyMovementConstraints();
		}
	}
	// 应用移动限制（实时）
	private function ApplyMovementConstraints():Void
	{
		targetPosition = ClampPosition(targetPosition);
	}
	// PORT-NOTE: C# 的 ref Vector3 参数在 Haxe 中改为返回值形式。
	private function ClampPosition(position:Vector3):Vector3
	{
		if (viewport == null)
			return position;

		// 获取视区和内容的尺寸
		// PORT-NOTE: C# 为 `viewport.rect.size` / `rectTransform.rect.size`；unity shim 的 RectTransform
		// 暂无 rect，用 UIHelper.GetLocalRect 按同一语义复算（见 UIHelper 的 TODO-PORT）。
		var viewportSize = UIHelper.GetLocalRect(viewport).size;
		var contentSize = UIHelper.GetLocalRect(rectTransform).size * rectTransform.localScale.x;

		// 计算边界
		var minX = (viewportSize.x - contentSize.x) * 0.5 + constraintPadding;
		var maxX = -minX;
		var minY = (viewportSize.y - contentSize.y) * 0.5 + constraintPadding;
		var maxY = -minY;

		// 当内容小于视区时，限制移动范围
		if (contentSize.x < viewportSize.x)
		{
			position.x = 0;
		}
		else
		{
			position.x = Mathf.Clamp(position.x, minX, maxX);
		}

		if (contentSize.y < viewportSize.y)
		{
			position.y = 0;
		}
		else
		{
			position.y = Mathf.Clamp(position.y, minY, maxY);
		}
		return position;
	}
	// [Header("Zoom Settings")]
	public var zoomSpeed:Float = 0.1;
	public var minZoom:Float = 0.5;
	public var maxZoom:Float = 3;

	// [Header("Pan Settings")]
	public var panSensitivity:Float = 1;
	public var smoothPan:Bool = true;
	public var smoothTime:Float = 0.1;

	// [Header("Viewport Constraints")]
	public var viewport:RectTransform; // 视区矩形
	public var enableConstraints:Bool = true; // 是否启用移动限制
	public var constraintPadding:Float = 10; // 边界内边距

	private var rectTransform:RectTransform;
	private var originalScale:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var originalPosition:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var targetPosition:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var velocity:Vector3 = new Vector3(0, 0, 0);

	// 用于触屏双指缩放
	private var initialDistance:Float;
	private var initialScale:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var initialMidpoint:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var initialPosition:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
