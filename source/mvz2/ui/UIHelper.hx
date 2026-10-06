// Ported from: Assets/Scripts/View/UIHelper.cs
package mvz2.ui;

import unity.Canvas;
import unity.Mathf;
import unity.Matrix4x4;
import unity.Rect;
import unity.RectTransform;
import unity.Transform;
import unity.UnityObject;
import unity.Vector2;
import unity.Vector3;

class UIHelper
{
	// PORT-NOTE: C# 使用 Unity 的 RectTransform.rect（由布局系统计算：尺寸取 sizeDelta，原点按 pivot 偏移）。
	// unity shim 的 RectTransform 未定义 rect，这里按同一语义复算局部矩形。
	// TODO-PORT: 待 unity 域在 RectTransform 上补 rect 后改用 shim 属性，并删除本函数。
	public static function GetLocalRect(rectTrans:RectTransform):Rect
	{
		var size = rectTrans.sizeDelta;
		return new Rect(-rectTrans.pivot.x * size.x, -rectTrans.pivot.y * size.y, size.x, size.y);
	}
	// PORT-NOTE: C# 使用 Transform.localToWorldMatrix（TRS 矩阵）。unity shim 的 Transform 未定义该属性，
	// 这里用 unity.Matrix4x4.SetTRS 按 position/rotation/lossyScale 复算（shim 的 SetTRS 本身同样只处理平移与缩放）。
	// TODO-PORT: 待 unity 域在 Transform 上补 localToWorldMatrix 后改用 shim 属性，并删除本函数。
	public static function GetLocalToWorldMatrix(trans:Transform):Matrix4x4
	{
		var matrix = new Matrix4x4();
		matrix.SetTRS(trans.position, trans.rotation, trans.lossyScale);
		return matrix;
	}
	// C# 扩展方法 RectTransform.GetWorldRect()
	public static function GetWorldRect(rectTrans:RectTransform):Rect
	{
		var localRect = GetLocalRect(rectTrans);
		var min = localRect.min;
		var max = localRect.max;
		var matrix4x:Matrix4x4 = GetLocalToWorldMatrix(rectTrans);
		var worldMin = matrix4x.MultiplyPoint(new unity.Vector3(min.x, min.y, 0));
		var worldMax = matrix4x.MultiplyPoint(new unity.Vector3(max.x, max.y, 0));
		return new Rect(worldMin.x, worldMin.y, worldMax.x - worldMin.x, worldMax.y - worldMin.y);
	}
	// C# 扩展方法 RectTransform.GetRootCanvas()
	public static function GetRootCanvas(target:RectTransform):Null<Canvas>
	{
		var cacheList:Array<Canvas> = [];
		return GetRootCanvasNonAlloc(target, cacheList);
	}
	// C# 扩展方法 RectTransform.GetRootCanvasNonAlloc(List<Canvas>)
	public static function GetRootCanvasNonAlloc(target:RectTransform, cacheList:Array<Canvas>):Null<Canvas>
	{
		cacheList.resize(0);
		for (canvas in target.GetComponentsInParent(Canvas, true))
		{
			cacheList.push(canvas);
		}
		return cacheList.length > 0 ? cacheList[cacheList.length - 1] : null;
	}
	// C# 扩展方法 RectTransform.LimitInsideScreen()
	public static function LimitInsideScreen(target:RectTransform):Void
	{
		var rootCanvas = GetRootCanvas(target);
		if (!UnityObject.exists(rootCanvas))
			return;
		var rootCanvasTrans:RectTransform = cast rootCanvas.transform;
		if (!UnityObject.exists(rootCanvasTrans))
			return;
		LimitInsideScreenWithRoot(target, rootCanvasTrans);
	}
	// C# 扩展方法 RectTransform.LimitInsideScreenNonAlloc(List<Canvas>)
	public static function LimitInsideScreenNonAlloc(target:RectTransform, cacheList:Array<Canvas>):Void
	{
		var rootCanvas = GetRootCanvasNonAlloc(target, cacheList);
		if (!UnityObject.exists(rootCanvas))
			return;
		var rootCanvasTrans:RectTransform = cast rootCanvas.transform;
		if (!UnityObject.exists(rootCanvasTrans))
			return;
		LimitInsideScreenWithRoot(target, rootCanvasTrans);
	}
	// PORT-NOTE: C# 扩展方法 RectTransform.LimitInsideScreen(RectTransform) 在 Haxe 中改名以区分重载。
	public static function LimitInsideScreenWithRoot(target:RectTransform, rootCanvasTransform:RectTransform):Void
	{
		// PORT-NOTE: C# 为 `target.rect.size`；见 GetLocalRect 的 TODO-PORT。
		var size = GetLocalRect(target).size;
		LimitInsideScreenWithSize(target, rootCanvasTransform, size);
	}
	// PORT-NOTE: C# 扩展方法 RectTransform.LimitInsideScreen(RectTransform, Vector2)。
	public static function LimitInsideScreenWithSize(target:RectTransform, rootCanvasRectTransform:RectTransform, size:Vector2):Void
	{
		var rootCanvasWorldRect = GetWorldRect(rootCanvasRectTransform);
		var localMin = target.parent.InverseTransformPoint(new unity.Vector3(rootCanvasWorldRect.min.x, rootCanvasWorldRect.min.y, 0));
		var localMax = target.parent.InverseTransformPoint(new unity.Vector3(rootCanvasWorldRect.max.x, rootCanvasWorldRect.max.y, 0));

		var targetPos = target.localPosition;
		var xMin = localMin.x + size.x * target.pivot.x;
		var xMax = localMax.x - size.x * (1 - target.pivot.x);
		var yMin = localMin.y + size.y * target.pivot.y;
		var yMax = localMax.y - size.y * (1 - target.pivot.y);
		targetPos.x = Mathf.Clamp(targetPos.x, xMin, xMax);
		targetPos.y = Mathf.Clamp(targetPos.y, yMin, yMax);
		target.localPosition = targetPos;
	}
}
