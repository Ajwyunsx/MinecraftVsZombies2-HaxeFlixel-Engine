// Ported from: Assets/Scripts/Engine/Level/Entities/Hitboxes/Hitbox.cs
package pvzengine.collisions;

import pvzengine.entities.Entity;
import tools.ObjectExtensions;
import tools.geometrical.Capsule;
import tools.geometrical.Geometry;
import unity.Bounds;
import unity.Vector3;

// PORT-NOTE: C# abstract class → Haxe 普通 class，抽象方法 GetSize/GetPivot/GetOffset 用 throw "abstract"（PORTING.md）。
// PORT-NOTE: C# 的 `out Vector3 seperation` 改为引用容器 `{value:Vector3}`（与工程内其它 out 参数的移植方式一致）。
// PORT-NOTE: C# 的 UnityEngine.Bounds 是值类型（赋值即拷贝）；Haxe 的 unity.Bounds 是引用类型，
//   GetBounds() 中「拷贝后平移 center」的写法改为显式构造新 Bounds，避免污染缓存。
class Hitbox
{
	public function new(entity:Entity)
	{
		Entity = entity;
	}
	public function ReevaluateBounds():Void
	{
		var scale = Entity.GetFinalScale();

		var size:Vector3 = GetSize();
		var offset:Vector3 = GetOffset();
		var pivot:Vector3 = GetPivot();

		var scaledSize = Vector3.Scale(size, scale);
		var scaledOffset = Vector3.Scale(offset, scale);
		var scaledPivot = Vector3.Scale(pivot, scale);

		cacheOffset = scaledOffset;

		var boundsCenter = cacheOffset + Vector3.Scale(Vector3.one * 0.5 - pivot, scaledSize);
		var boundsSize = ObjectExtensions.Abs(scaledSize);
		cache = new Bounds(boundsCenter, boundsSize);
	}
	public function IsInBox(center:Vector3, size:Vector3):Bool
	{
		var bounds = GetBounds();
		return bounds.IntersectsOptimized(new Bounds(center, size));
	}
	public function IsInSphere(center:Vector3, radius:Float):Bool
	{
		var bounds = GetBounds();
		return Geometry.CollideBetweenCubeAndSphere(bounds, center, radius);
	}
	public function IsInCapsule(pos1:Vector3, pos2:Vector3, radius:Float):Bool
	{
		var bounds = GetBounds();
		var capsule = new Capsule(pos1, pos2, radius);
		return Geometry.CollideBetweenCubeAndCapsule(capsule, bounds);
	}
	public function GetBoundsCenter():Vector3
	{
		return GetLocalCenter() + Entity.Position;
	}
	public function GetPosition():Vector3
	{
		return GetLocalOffset() + Entity.Position;
	}
	public function GetBounds():Bounds
	{
		var bounds = GetLocalBounds();
		// PORT-NOTE: 见文件头——显式构造新 Bounds，等价于 C# 值语义下的拷贝后平移。
		return new Bounds(bounds.center + Entity.Position, bounds.size);
	}
	public function GetBoundsSize():Vector3
	{
		return cache.size;
	}
	public function GetLocalBounds():Bounds
	{
		return cache;
	}
	public function GetLocalCenter():Vector3
	{
		return cache.center;
	}
	public function GetLocalOffset():Vector3
	{
		return cacheOffset;
	}
	public function Intersects(other:Hitbox):Bool
	{
		var bounds = GetBounds();
		var otherBounds = other.GetBounds();
		return bounds.IntersectsOptimized(otherBounds);
	}
	public function DoCollision(other:Hitbox, offset:Vector3, seperation:{value:Vector3}):Bool
	{
		var selfBounds = GetBounds();
		selfBounds.center += offset;
		var otherBounds = other.GetBounds();

		if (selfBounds.IntersectsOptimized(otherBounds))
		{
			seperation.value = otherBounds.center - selfBounds.center;
			return true;
		}
		seperation.value = Vector3.zero;
		return false;
	}
	// abstract
	public function GetSize():Vector3
	{
		throw "abstract";
	}
	// abstract
	public function GetPivot():Vector3
	{
		throw "abstract";
	}
	// abstract
	public function GetOffset():Vector3
	{
		throw "abstract";
	}
	public var Entity(default, null):Entity;
	private var cache:Bounds = new Bounds(); // PORT-NOTE: C# Bounds 为 struct，default 为零包围盒；显式初始化避免 abstract-over-class 的 null 解引用
	private var cacheOffset:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
