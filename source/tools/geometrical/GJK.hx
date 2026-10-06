// Ported from: Assets/Scripts/Engine/Tools/Geometry/GJK.cs
package tools.geometrical;

import unity.Mathf;
import unity.Vector3;

// GJK算法实现
// PORT-NOTE: C# 的 `ref Vector3 dir` 在 Haxe 中改为引用对象 `{value:Vector3}`（PORTING.md §out/ref）。
// PORT-NOTE: C# 的 `List<Vector3>` 与 `s[^1]`（从末尾索引）分别改为 `Array<Vector3>` 与 `s[s.length - 1]`。
class GJK
{
	private static inline var MAX_ITERATIONS:Int = 32;

	// GJK支持函数（Minkowski差）
	private static function Support(shapeA:IConvexShape, shapeB:IConvexShape, direction:Vector3):Vector3
	{
		var pointA = shapeA.GetFarthestPointInDirection(direction);
		var pointB = shapeB.GetFarthestPointInDirection(-direction);
		return pointA - pointB;
	}

	public static function CheckCollision(a:IConvexShape, b:IConvexShape):Bool
	{
		var dir = b.GetCenter() - a.GetCenter();
		if (dir.sqrMagnitude < Mathf.Epsilon)
			dir = Vector3.right;

		var simplex:Array<Vector3> = [];

		var A = Support(a, b, dir);
		simplex.push(A);
		dir = -A;

		var dirRef = {value: dir};
		for (i in 0...MAX_ITERATIONS)
		{
			if (dirRef.value.sqrMagnitude < Mathf.Epsilon)
				dirRef.value = -simplex[simplex.length - 1];

			A = Support(a, b, dirRef.value);

			// 推进失败 → 一定不相交
			if (Vector3.Dot(A, dirRef.value) <= Mathf.Epsilon)
				return false;

			simplex.push(A);

			if (HandleSimplex(simplex, dirRef))
				return true;
		}

		// 正常情况下永远不会走到这里
		return false;
	}

	static function HandleSimplex(s:Array<Vector3>, dirRef:{value:Vector3}):Bool
	{
		switch (s.length)
		{
			case 2:
				return Line(s, dirRef);
			case 3:
				return Triangle(s, dirRef);
			case 4:
				return Tetrahedron(s, dirRef);
			default:
		}
		return false;
	}

	static function Line(s:Array<Vector3>, dirRef:{value:Vector3}):Bool
	{
		var A = s[s.length - 1];
		var B = s[s.length - 2];
		var AB = B - A;
		var AO = -A;

		if (Vector3.Dot(AB, AO) > 0)
		{
			dirRef.value = Vector3.Cross(Vector3.Cross(AB, AO), AB);
		}
		else
		{
			s.resize(0);
			s.push(A);
			dirRef.value = AO;
		}

		return false;
	}

	static function Triangle(s:Array<Vector3>, dirRef:{value:Vector3}):Bool
	{
		var A = s[s.length - 1];
		var B = s[s.length - 2];
		var C = s[s.length - 3];

		var AB = B - A;
		var AC = C - A;
		var AO = -A;

		var ABC = Vector3.Cross(AB, AC);

		// AC side
		if (Vector3.Dot(Vector3.Cross(ABC, AC), AO) > 0)
		{
			if (Vector3.Dot(AC, AO) > 0)
			{
				s.resize(0);
				s.push(C);
				s.push(A);
				dirRef.value = Vector3.Cross(Vector3.Cross(AC, AO), AC);
			}
			else
			{
				s.resize(0);
				s.push(B);
				s.push(A);
				return Line(s, dirRef);
			}
			return false;
		}

		// AB side
		if (Vector3.Dot(Vector3.Cross(AB, ABC), AO) > 0)
		{
			s.resize(0);
			s.push(B);
			s.push(A);
			return Line(s, dirRef);
		}

		// Above or below triangle
		if (Vector3.Dot(ABC, AO) > 0)
		{
			dirRef.value = ABC;
		}
		else
		{
			s.resize(0);
			s.push(B);
			s.push(C);
			s.push(A);
			dirRef.value = -ABC;
		}

		return false;
	}

	static function Tetrahedron(s:Array<Vector3>, dirRef:{value:Vector3}):Bool
	{
		var A = s[s.length - 1];
		var B = s[s.length - 2];
		var C = s[s.length - 3];
		var D = s[s.length - 4];

		var AO = -A;

		var AB = B - A;
		var AC = C - A;
		var AD = D - A;

		var ABC = Vector3.Cross(AB, AC);
		var ACD = Vector3.Cross(AC, AD);
		var ADB = Vector3.Cross(AD, AB);

		if (Vector3.Dot(ABC, AO) > 0)
		{
			s.resize(0);
			s.push(C);
			s.push(B);
			s.push(A);
			dirRef.value = ABC;
			return false;
		}

		if (Vector3.Dot(ACD, AO) > 0)
		{
			s.resize(0);
			s.push(D);
			s.push(C);
			s.push(A);
			dirRef.value = ACD;
			return false;
		}

		if (Vector3.Dot(ADB, AO) > 0)
		{
			s.resize(0);
			s.push(B);
			s.push(D);
			s.push(A);
			dirRef.value = ADB;
			return false;
		}

		// 原点在四面体内部
		return true;
	}
}
