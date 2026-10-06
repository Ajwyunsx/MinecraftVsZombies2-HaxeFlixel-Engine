// Ported from: Assets/Scripts/Engine/Tools/Geometry/Geometry.cs
package tools.geometrical;

import unity.Bounds;
import unity.Mathf;
import unity.Rect;
import unity.Vector2;
import unity.Vector3;

/**
 * PORT-NOTE（out 参数）：C# 的 `out T x` 在 Haxe 中改为引用对象 `x:{value:T}`（PORTING.md §扩展方法/out），
 * 与既有调用点（如 `Geometry.DoRectAndRayIntersect(rect, pos, dir, targetPoint)` 传
 * `{value:Vector2}`）保持一致。
 * PORT-NOTE（重载）：Haxe 无方法重载，C# 中同名的重载合并为带可选参数的单个方法，
 * 并在参数类型无法静态区分时按运行期类型分流。
 */
class Geometry
{
	// #region 1D数轴
	public static function DoRangesIntersect(start1:Float, end1:Float, start2:Float, end2:Float):Bool
	{
		return Mathf.Max(start1, end1) >= Mathf.Min(start2, end2) && Mathf.Min(start1, end1) <= Mathf.Max(start2, end2);
	}

	// #endregion

	// #region 2D平面
	// C#: public static float Cross(this Vector2 vector1, Vector2 vector2)
	public static function Cross(vector1:Vector2, vector2:Vector2):Float
	{
		return vector1.x * vector2.y - vector1.y * vector2.x;
	}
	// C#: public static bool OverlapOptimized(this Rect rect, Rect target)
	public static function OverlapOptimized(rect:Rect, target:Rect):Bool
	{
		if (rect.yMin > target.yMax)
		{
			return false;
		}
		if (rect.yMax < target.yMin)
		{
			return false;
		}
		if (rect.xMax < target.xMin)
		{
			return false;
		}
		if (rect.xMin > target.xMax)
		{
			return false;
		}
		return true;
	}
	public static function DoRectsOverlap(rectCenter1:Vector2, rectSize1:Vector2, rectCenter2:Vector2, rectSize2:Vector2):Bool
	{
		var rect1ExtentX = rectSize1.x * 0.5;
		var rect1ExtentY = rectSize1.y * 0.5;
		var rect2ExtentX = rectSize2.x * 0.5;
		var rect2ExtentY = rectSize2.y * 0.5;
		if (!DoRangesIntersect(rectCenter1.x - rect1ExtentX, rectCenter1.x + rect1ExtentX, rectCenter2.x - rect2ExtentX, rectCenter2.x + rect2ExtentX))
			return false;
		if (!DoRangesIntersect(rectCenter1.y - rect1ExtentY, rectCenter1.y + rect1ExtentY, rectCenter2.y - rect2ExtentY, rectCenter2.y + rect2ExtentY))
			return false;
		return true;
	}
	public static function DoRectAndRayIntersect(rect:Rect, point:Vector2, dir:Vector2, intersection:{value:Vector2}):Bool
	{
		for (i in 0...4)
		{
			var line1:Vector2;
			var line2:Vector2;
			switch (i)
			{
				case 1:
					line1 = new Vector2(rect.xMin, rect.yMax);
					line2 = new Vector2(rect.xMax, rect.yMax);
				case 2:
					line1 = new Vector2(rect.xMax, rect.yMax);
					line2 = new Vector2(rect.xMax, rect.yMin);
				case 3:
					line1 = new Vector2(rect.xMax, rect.yMin);
					line2 = new Vector2(rect.xMin, rect.yMin);
				default:
					line1 = new Vector2(rect.xMin, rect.yMin);
					line2 = new Vector2(rect.xMin, rect.yMax);
			}
			if (DoLineAndRayIntersect(line1, line2, point, dir, intersection))
			{
				return true;
			}
		}
		intersection.value = Vector2.zero;
		return false;
	}
	// C#: public static bool DoLinesIntersect(Vector2 lineA1, Vector2 lineA2, Vector2 lineB1, Vector2 lineB2)
	//     public static bool DoLinesIntersect(Vector2 lineA1, Vector2 lineA2, Vector2 lineB1, Vector2 lineB2, out Vector2 intersection)
	// PORT-NOTE: 两个重载合并；不传 intersection 即等价于 4 参数版本。
	public static function DoLinesIntersect(lineA1:Vector2, lineA2:Vector2, lineB1:Vector2, lineB2:Vector2, ?intersection:{value:Vector2} = null):Bool
	{
		var result = intersection != null ? intersection : {value: Vector2.zero};
		result.value = Vector2.zero;
		var A1ToB1 = lineA1 - lineB1;
		var A2ToB1 = lineA2 - lineB1;
		var A1ToB2 = lineA1 - lineB2;
		var A2ToB2 = lineA2 - lineB2;
		// 三角形abc 面积的2倍
		var area_abc = Cross(A1ToB1, A2ToB1);

		// 三角形abd 面积的2倍
		var area_abd = Cross(A1ToB2, A2ToB2);

		// 面积符号相同则两点在线段同侧,不相交 (对点在线段上的情况,本例当作不相交处理);
		if (area_abc * area_abd >= 0)
		{
			return false;
		}

		var B1ToA1 = lineB1 - lineA1;
		var B2ToA1 = lineB2 - lineA1;
		// 三角形cda 面积的2倍
		var area_cda = Cross(B1ToA1, B2ToA1);
		// 三角形cdb 面积的2倍
		// 注意: 这里有一个小优化.不需要再用公式计算面积,而是通过已知的三个面积加减得出.
		var area_cdb = area_cda + area_abc - area_abd;
		if (area_cda * area_cdb >= 0)
		{
			return false;
		}

		//计算交点坐标
		var distanceToA1 = area_cda / (area_abd - area_abc);
		var d = (lineA2 - lineA1) * distanceToA1;
		result.value = lineA1 + d;
		return true;
	}
	private static function DoLineAndRayIntersect(line1:Vector2, line2:Vector2, point:Vector2, dir:Vector2, intersection:{value:Vector2}):Bool
	{
		intersection.value = Vector2.zero;
		// 判断A1和A2是否在射线的两端
		var line1ToPoint = line1 - point;
		var line2ToPoint = line2 - point;
		var lineDir = line2 - line1;
		var line1CrossRay = Cross(line1ToPoint, dir);
		var line2CrossRay = Cross(line2ToPoint, dir);
		var lineCrossPoint = Cross(lineDir, line2ToPoint);
		var lineCrossPointRay = Cross(lineDir, line2 - (point + dir));

		// A1和A2在射线的同一侧，不相交
		if (line1CrossRay * line2CrossRay > 0)
		{
			return false;
		}
		// 线段A在射线的另一侧
		if (Mathf.Abs(lineCrossPointRay) > Mathf.Abs(lineCrossPoint))
		{
			return false;
		}

		// 如果line是竖线
		if (lineDir.x == 0)
		{
			// 如果都是竖线
			if (dir.x == 0)
			{
				return false;
			}
			// 如果只有line是竖线
			else
			{
				var raySlope = dir.y / dir.x;
				var rayOffset = point.y - point.x * raySlope;

				var x = line1.x;
				var y = raySlope * line1.x + rayOffset;
				intersection.value = new Vector2(x, y);
				return true;
			}
		}
		else
		{
			// 如果只有dir是竖线
			if (dir.x == 0)
			{
				var lineSlope = lineDir.y / lineDir.x;
				var lineOffset = line1.y - line1.x * lineSlope;

				var x = point.x;
				var y = lineSlope * point.x + lineOffset;
				intersection.value = new Vector2(x, y);
				return true;
			}
			// 如果两个都不是竖线
			else
			{
				// ax1 + b = y1
				// ax2 + b = y2
				// a = (y2 - y1) / (x2 - x1)
				// b = y - ax;
				var lineSlope = lineDir.y / lineDir.x;
				var lineOffset = line1.y - line1.x * lineSlope;

				var raySlope = dir.y / dir.x;
				var rayOffset = point.y - point.x * raySlope;

				// ax + b = y;
				// cx + d = y;
				// (a - c)x + (b - d) = 0;
				// x = (d - b) / (a - c);
				var x = (rayOffset - lineOffset) / (lineSlope - raySlope);
				var y = lineSlope * x + lineOffset;
				intersection.value = new Vector2(x, y);
				return true;
			}
		}
	}
	private static function DoLinesIntersectNormal(lineA1:Vector2, lineA2:Vector2, lineB1:Vector2, lineB2:Vector2, intersection:{value:Vector2}):Bool
	{
		intersection.value = Vector2.zero;
		//线段A的法线NormalA
		var normalA = new Vector2(lineA2.y - lineA1.y, lineA1.x - lineA2.x);

		//线段B的法线NormalB
		var normalB = new Vector2(lineB2.y - lineB1.y, lineB1.x - lineB2.x);

		//两条法线做叉乘, 如果结果为0, 说明线段A和线段B平行或共线,不相交
		var denominator = Cross(normalA, normalB);
		if (denominator == 0)
		{
			return false;
		}

		//在法线NormalB上的投影
		var distB1_NB = Vector2.Dot(normalB, lineB1);
		var distA1_NB = Vector2.Dot(normalB, lineA1) - distB1_NB;
		var distA2_NB = Vector2.Dot(normalB, lineA2) - distB1_NB;

		// 点A1投影和点A2投影在点B1投影同侧 (对点在线段上的情况,本例当作不相交处理);
		if (distA1_NB * distA2_NB >= 0)
		{
			return false;
		}

		//
		//判断点B1点B2和线段A的关系, 原理同上
		//
		//在法线N1上的投影
		var distA1_NA = Vector2.Dot(normalA, lineA1);
		var distB1_NA = Vector2.Dot(normalA, lineB1) - distA1_NA;
		var distB2_NA = Vector2.Dot(normalA, lineB2) - distA1_NA;
		if (distB1_NA * distB2_NA >= 0)
		{
			return false;
		}

		//计算交点坐标
		var fraction = distA1_NB / denominator;
		var distance = new Vector2(fraction * normalA.y, -fraction * normalA.x);
		intersection.value = lineA1 + distance;
		return true;
	}
	public static function CollideBetweenRectangleAndCircle(circleCenter:Vector2, circleRadius:Float, rectCenter:Vector2, rectScale:Vector2):Bool
	{
		// 将目标圆的坐标(world Potition)转换为矩形的 localPosition
		var circlePos = circleCenter - rectCenter;

		// 使用上面方法计算的 circlePos 会受到 矩形 rectScale 影响
		// 当矩形 rectScale = Vector2.one 时计算结果为 (x, y)
		// 当矩形 rectScale = new Vector2(a, b) 时, 计算所得 localPos = (x / a, y / b)
		// 通过下面计算将结果转换
		// circlePos.x *= rectScale.x;
		// circlePos.y *= rectScale.y;

		// 将 circlePos x、y 分别于 max、min 的 x、y 做比较
		//  x 取值范围 (min.x, max.x)
		//  y 取值范围 (min.y, max.y)
		var x = circlePos.x;
		x = Mathf.Clamp(x, -rectScale.x * 0.5, rectScale.x * 0.5);

		var y = circlePos.y;
		y = Mathf.Clamp(y, -rectScale.y * 0.5, rectScale.y * 0.5);

		// x、y 重新取值后得到新坐标
		var pos = new Vector2(x, y);

		// 求新坐标 pos 与 circlePos 的距离
		var distance = (circlePos - pos).magnitude;
		// 距离大于半径则不相交
		return distance <= circleRadius;
	}
	// #endregion

	// #region 3D物体
	// C#: public static Rect GetBottomRect(this Bounds bounds)
	public static function GetBottomRect(bounds:Bounds):Rect
	{
		var boundsMin = bounds.min;
		var boundsSize = bounds.size;
		return new Rect(boundsMin.x, bounds.min.z, boundsSize.x, boundsSize.z);
	}
	// C#: public static bool IntersectsOptimized(this Bounds a, Bounds b)
	public static function IntersectsOptimized(a:Bounds, b:Bounds):Bool
	{
		var centerA = a.center;
		var extentsA = a.extents;
		var centerB = b.center;
		var extentsB = b.extents;

		// X 轴检查
		var minA = centerA.x - extentsA.x;
		var maxB = centerB.x + extentsB.x;
		if (minA > maxB)
			return false;

		var maxA = centerA.x + extentsA.x;
		var minB = centerB.x - extentsB.x;
		if (maxA < minB)
			return false;

		// Y 轴检查
		minA = centerA.y - extentsA.y;
		maxB = centerB.y + extentsB.y;
		if (minA > maxB)
			return false;

		maxA = centerA.y + extentsA.y;
		minB = centerB.y - extentsB.y;
		if (maxA < minB)
			return false;

		// Z 轴检查
		minA = centerA.z - extentsA.z;
		maxB = centerB.z + extentsB.z;
		if (minA > maxB)
			return false;

		maxA = centerA.z + extentsA.z;
		minB = centerB.z - extentsB.z;
		if (maxA < minB)
			return false;

		return true;
	}
	public static function ClosestPointAABBToAABB(a:Bounds, b:Bounds):Vector3
	{
		var p = new Vector3();
		var aMin = a.min;
		var aMax = a.max;
		var bCenter = b.center;

		p.x = Mathf.Clamp(bCenter.x, aMin.x, aMax.x);
		p.y = Mathf.Clamp(bCenter.y, aMin.y, aMax.y);
		p.z = Mathf.Clamp(bCenter.z, aMin.z, aMax.z);

		return p;
	}
	public static function CollideBetweenCubeAndCylinder(cylinder:Cylinder, cube:Bounds):Bool
	{
		var cylinderRectSide:Rect;
		var cubeRectSide:Rect;
		var cylinderCenterTop:Vector2;
		var cubeRectTop:Rect;
		var cubeMin = cube.min;
		var cubeSize = cube.size;
		switch (cylinder.axis)
		{
			case Axis.X:
				cylinderRectSide = new Rect(cylinder.center.x - cylinder.length * 0.5, cylinder.center.y - cylinder.radius, cylinder.length, cylinder.radius * 2);
				cubeRectSide = new Rect(cubeMin.x, cubeMin.y, cubeSize.x, cubeSize.y);

				cylinderCenterTop = new Vector2(cylinder.center.z, cylinder.center.y);
				cubeRectTop = new Rect(cubeMin.z, cubeMin.y, cubeSize.z, cubeSize.y);
			case Axis.Y:
				cylinderRectSide = new Rect(cylinder.center.x - cylinder.radius, cylinder.center.y - cylinder.length * 0.5, cylinder.radius * 2, cylinder.length);
				cubeRectSide = new Rect(cubeMin.x, cubeMin.y, cubeSize.x, cubeSize.y);

				cylinderCenterTop = new Vector2(cylinder.center.x, cylinder.center.z);
				cubeRectTop = new Rect(cubeMin.x, cubeMin.z, cubeSize.x, cubeSize.z);
			case Axis.Z:
				cylinderRectSide = new Rect(cylinder.center.x - cylinder.radius, cylinder.center.z - cylinder.length * 0.5, cylinder.radius * 2, cylinder.length);
				cubeRectSide = new Rect(cubeMin.x, cubeMin.z, cubeSize.x, cubeSize.z);

				cylinderCenterTop = new Vector2(cylinder.center.x, cylinder.center.y);
				cubeRectTop = new Rect(cubeMin.x, cubeMin.y, cubeSize.x, cubeSize.y);
			default:
				return false;
		}

		// 检测圆柱体侧面1是否与方块侧面相交。
		if (!cubeRectSide.Overlaps(cylinderRectSide))
			return false;

		return CollideBetweenRectangleAndCircle(cylinderCenterTop, cylinder.radius, cubeRectTop.center, cubeRectTop.size);
	}
	public static function CollideBetweenCubeAndRoundCube(roundCube:RoundCube, cube:Bounds):Bool
	{
		var radius = roundCube.radius;
		var coreSize = roundCube.size;

		// 如果圆角半径过大，退化成球
		if (coreSize.x <= 0 && coreSize.y <= 0 && coreSize.z <= 0)
		{
			// 退化为：球 vs AABB
			var closest = cube.ClosestPoint(roundCube.center);
			return (closest - roundCube.center).sqrMagnitude <= radius * radius;
		}
		var coreBox = new Bounds(roundCube.center, coreSize);
		var closestPoint = ClosestPointAABBToAABB(coreBox, cube);
		var closestOnOther = cube.ClosestPoint(closestPoint);
		return (closestOnOther - closestPoint).sqrMagnitude <= radius * radius;
	}
	// C#: public static bool CollideBetweenCubeAndSphere(Vector3 sphereCenter, float sphereRadius, Vector3 cubeCenter, Vector3 cubeSize)
	//     public static bool CollideBetweenCubeAndSphere(Bounds cube, Vector3 sphereCenter, float sphereRadius)
	// PORT-NOTE: 两个重载合并；第一个实参为 Bounds 时按第二个重载解释，否则按第一个重载解释。
	public static function CollideBetweenCubeAndSphere(a:Dynamic, b:Dynamic, c:Dynamic, ?d:Vector3 = null):Bool
	{
		if (Std.isOfType(a, Bounds))
		{
			var cube:Bounds = cast a;
			var sphereCenter:Vector3 = cast b;
			var sphereRadius:Float = cast c;
			return (cube.ClosestPoint(sphereCenter) - sphereCenter).sqrMagnitude <= sphereRadius * sphereRadius;
		}
		else
		{
			var sphereCenter:Vector3 = cast a;
			var sphereRadius:Float = cast b;
			var cubeCenter:Vector3 = cast c;
			var cubeSize:Vector3 = d;
			var cube = new Bounds(cubeCenter, cubeSize);
			return CollideBetweenCubeAndSphere(cube, sphereCenter, sphereRadius);
		}
	}
	public static function CollideBetweenCubeAndCapsule(capsule:Capsule, aabb:Bounds):Bool
	{
		return GetSegmentAABBSqrDistance(capsule.point0, capsule.point1, aabb) <= capsule.radius * capsule.radius;
	}
	// C#: public static bool CollideBetweenCubeAndLine(Vector3 a, Vector3 b, Bounds cube)
	//     public static bool CollideBetweenCubeAndLine(Vector3 start, Vector3 end, Bounds cube, out float tMin, out float tMax)
	// PORT-NOTE: 两个重载合并，out 参数改为可选的引用对象。
	public static function CollideBetweenCubeAndLine(start:Vector3, end:Vector3, cube:Bounds, ?tMinRef:{value:Float} = null, ?tMaxRef:{value:Float} = null):Bool
	{
		if (tMinRef == null)
			tMinRef = {value: 0.0};
		if (tMaxRef == null)
			tMaxRef = {value: 0.0};
		var dir = end - start;

		var min = cube.min;
		var max = cube.max;

		tMinRef.value = 0;
		tMaxRef.value = 1;

		for (i in 0...3)
		{
			var axisDirection = getAxis(dir, i);
			var axisStart = getAxis(start, i);
			if (axisDirection == 0)
			{
				if (axisStart < getAxis(min, i) || axisStart > getAxis(max, i))
				{
					return false;
				}
			}
			else
			{
				var t1 = (getAxis(min, i) - axisStart) / axisDirection;
				var t2 = (getAxis(max, i) - axisStart) / axisDirection;
				if (t1 > t2)
				{
					var tmp = t1;
					t1 = t2;
					t2 = tmp;
				}

				tMinRef.value = Mathf.Max(tMinRef.value, t1);
				tMaxRef.value = Mathf.Min(tMaxRef.value, t2);
			}
		}
		return tMinRef.value <= tMaxRef.value;
	}
	public static function GetSegmentAABBSqrDistance(start:Vector3, end:Vector3, box:Bounds):Float
	{
		var direction = end - start;
		var t = 0.0;

		// 先找到线段上最接近 AABB 的 t
		for (i in 0...3)
		{
			var axisStart = getAxis(start, i);
			var axisDirection = getAxis(direction, i);
			var min = getAxis(box.min, i);
			var max = getAxis(box.max, i);

			if (Mathf.Abs(axisDirection) < Mathf.Epsilon)
				continue;
			if (axisStart < min)
			{
				t = Mathf.Max(t, (min - axisStart) / axisDirection);
			}
			else if (axisStart > max)
			{
				t = Mathf.Max(t, (max - axisStart) / axisDirection);
			}
		}

		t = Mathf.Clamp01(t);

		var closestOnSegment = start + direction * t;
		var closestOnBox = box.ClosestPoint(closestOnSegment);

		return (closestOnSegment - closestOnBox).sqrMagnitude;
	}
	// C#: public static bool RayIntersectsBox(Vector3 rayOrigin, Vector3 rayDirection, Bounds box, out float hitDistance, out Vector3 hitPoint)
	//     public static bool RayIntersectsBox(Vector3 rayOrigin, Vector3 rayDirection, Vector3 boxMin, Vector3 boxMax, out float hitDistance, out Vector3 hitPoint)
	// PORT-NOTE: 两个重载合并；第三个实参为 Bounds 时按第一个重载解释。
	public static function RayIntersectsBox(rayOrigin:Vector3, rayDirection:Vector3, arg3:Dynamic, arg4:Dynamic, arg5:Dynamic, ?arg6:Dynamic = null):Bool
	{
		var boxMin:Vector3;
		var boxMax:Vector3;
		var hitDistance:{value:Float};
		var hitPoint:{value:Vector3};
		if (Std.isOfType(arg3, Bounds))
		{
			// C#: RayIntersectsBox(Vector3 rayOrigin, Vector3 rayDirection, Bounds box, out float hitDistance, out Vector3 hitPoint)
			var box:Bounds = cast arg3;
			boxMin = box.min;
			boxMax = box.max;
			hitDistance = cast arg4;
			hitPoint = cast arg5;
		}
		else
		{
			// C#: RayIntersectsBox(Vector3 rayOrigin, Vector3 rayDirection, Vector3 boxMin, Vector3 boxMax, out float hitDistance, out Vector3 hitPoint)
			boxMin = cast arg3;
			boxMax = cast arg4;
			hitDistance = cast arg5;
			hitPoint = cast arg6;
		}

		hitDistance.value = 0;
		hitPoint.value = Vector3.zero;

		// 初始化最小和最大t值
		var tMin = FLOAT_MIN_VALUE;
		var tMax = FLOAT_MAX_VALUE;

		// 检查每个坐标轴（X, Y, Z）
		for (axis in 0...3)
		{
			var axisDirection = getAxis(rayDirection, axis);
			var axisStart = getAxis(rayOrigin, axis);
			var axisBoxMin = getAxis(boxMin, axis);
			var axisBoxMax = getAxis(boxMax, axis);
			// 处理方向接近0的情况（避免除零）
			if (Math.abs(axisDirection) < Mathf.Epsilon)
			{
				// 如果射线起点不在当前轴的边界内，则不相交
				if (axisStart < axisBoxMin || axisStart > axisBoxMax)
					return false;
				continue;
			}
			// 计算当前轴的两个交点t值
			var t1 = (axisBoxMin - axisStart) / axisDirection;
			var t2 = (axisBoxMax - axisStart) / axisDirection;

			// 确保t1是较小值，t2是较大值
			if (t1 > t2)
			{
				var tmp = t1;
				t1 = t2;
				t2 = tmp;
			}

			// 更新最小和最大t值
			tMin = Mathf.Max(tMin, t1);
			tMax = Mathf.Min(tMax, t2);

			// 检查是否无交集
			if (tMin > tMax || tMax < 0)
				return false;
		}

		// 处理射线起点在盒子内部的情况
		if (tMin < 0)
		{
			if (tMax < 0)
				return false; // 盒子完全在射线后方
			hitDistance.value = 0; // 起点作为交点
		}
		else
		{
			hitDistance.value = tMin;
		}

		// 计算交点位置
		hitPoint.value = rayOrigin + rayDirection * hitDistance.value;
		return true;
	}
	public static function CalculateAABBCollisionTime(startCenter:Vector3, endCenter:Vector3, size:Vector3, target:Bounds, collisionTimeRef:{value:Float}):Bool
	{
		collisionTimeRef.value = 0;
		var velocity = endCenter - startCenter;

		var movingStart = new Bounds(startCenter, size);

		var tEntry = Math.NEGATIVE_INFINITY;
		var tExit = Math.POSITIVE_INFINITY;
		var movingMin = movingStart.min;
		var movingMax = movingStart.max;
		var targetMin = target.min;
		var targetMax = target.max;

		for (axis in 0...3)
		{
			var minA = getAxis(movingMin, axis);
			var maxA = getAxis(movingMax, axis);
			var minB = getAxis(targetMin, axis);
			var maxB = getAxis(targetMax, axis);
			var vel = getAxis(velocity, axis);

			// 处理静态重叠情况
			if (vel == 0)
			{
				if (maxA <= minB || minA >= maxB)
					return false; // 无重叠
				continue; // 保持当前时间范围不变
			}

			var t0 = (minB - maxA) / vel;
			var t1 = (maxB - minA) / vel;

			if (vel < 0) // 确保t0是进入时间，t1是离开时间
			{
				var tmp = t0;
				t0 = t1;
				t1 = tmp;
			}

			tEntry = Math.max(tEntry, t0);
			tExit = Math.min(tExit, t1);
		}

		// 检查是否发生碰撞且在[0,1]时间范围内
		if (tEntry > tExit || tExit < 0 || tEntry > 1)
			return false;

		collisionTimeRef.value = tEntry;
		return true;
	}
	// #endregion

	// #region AABB
	public static function AABBSweep(Ea:Vector3, Eb:Vector3, A1:Vector3, B1:Vector3, prevA:Vector3, prevB:Vector3, firstTimeRef:{value:Float}, lastTimeRef:{value:Float}):Bool
	{
		var prevBoxA = new Bounds(prevA, Ea); //previous state of AABB A
		var prevBoxB = new Bounds(prevB, Eb); //previous state of AABB B
		var displacementA = A1 - prevA; //displacement of A
		var displacementB = B1 - prevB; //displacement of B
		//the problem is solved in A's frame of reference

		var relativeDisplacement = displacementB - displacementA;
		//relative velocity (in normalized time)

		var firstTimeAxises = new Vector3(0, 0, 0);
		//first times of overlap along each axis

		var lastTimeAxises = new Vector3(1, 1, 1);
		//last times of overlap along each axis

		//check if they were overlapping
		// on the previous frame
		if (prevBoxA.IntersectsOptimized(prevBoxB))
		{
			firstTimeRef.value = 0;
			lastTimeRef.value = 0;
			return true;
		}

		//find the possible first and last times
		//of overlap along each axis
		var prevMinA = prevBoxA.min;
		var prevMaxA = prevBoxA.max;
		var prevMinB = prevBoxB.min;
		var prevMaxB = prevBoxB.max;
		for (i in 0...3)
		{
			var minA = getAxis(prevMinA, i);
			var maxA = getAxis(prevMaxA, i);
			var minB = getAxis(prevMinB, i);
			var maxB = getAxis(prevMaxB, i);
			var displacement = getAxis(relativeDisplacement, i);
			if (maxA < minB && displacement < 0)
			{
				setAxis(firstTimeAxises, i, (maxA - minB) / displacement);
			}
			else if (maxB < minA && displacement > 0)
			{
				setAxis(firstTimeAxises, i, (minA - maxB) / displacement);
			}

			if (maxB > minA && displacement < 0)
			{
				setAxis(lastTimeAxises, i, (minA - maxB) / displacement);
			}
			else if (maxA > minB && displacement > 0)
			{
				setAxis(lastTimeAxises, i, (maxA - minB) / displacement);
			}
		}

		//possible first time of overlap
		firstTimeRef.value = Mathf.Max(Mathf.Max(firstTimeAxises.x, firstTimeAxises.y), firstTimeAxises.z);

		//possible last time of overlap
		lastTimeRef.value = Mathf.Min(Mathf.Min(lastTimeAxises.x, lastTimeAxises.y), lastTimeAxises.z);

		//they could have only collided if
		//the first time of overlap occurred
		//before the last time of overlap
		return firstTimeRef.value <= lastTimeRef.value;
	}
	// #endregion

	// C# 的 float.MinValue / float.MaxValue（不是无穷大）
	private static inline var FLOAT_MIN_VALUE:Float = -3.4028234663852886e+38;
	private static inline var FLOAT_MAX_VALUE:Float = 3.4028234663852886e+38;

	// PORT-NOTE: C# 用 `vector[i]` 索引 Vector3 的分量；Haxe 的 unity.Vector3 无索引访问器，故提供下列辅助函数。
	private static inline function getAxis(v:Vector3, i:Int):Float
	{
		return i == 0 ? v.x : (i == 1 ? v.y : v.z);
	}
	private static inline function setAxis(v:Vector3, i:Int, value:Float):Void
	{
		if (i == 0)
			v.x = value;
		else if (i == 1)
			v.y = value;
		else
			v.z = value;
	}
}
