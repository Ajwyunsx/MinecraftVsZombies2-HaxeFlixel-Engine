// Ported from: Assets/Scripts/MVZ2/Level/LevelRaycaster.cs
package mvz2.level;

import mvz2logic.helditems.HeldItemDefinition;
import mvz2logic.helditems.IHeldItemData;
import mvz2.ui.level.ILevelRaycastReceiver;
import pvzengine.level.LevelEngine;
import unity.*;
import unity.Debug;
import unity.eventsystems.PointerEventData;
import unity.eventsystems.PointerEventData.RaycastResult;
// PORT-NOTE: unity shim 中 UIBehaviour 位于 unity/ui/，故改为 unity.ui.UIBehaviour。
import unity.ui.UIBehaviour;
import unity.Physics2D;
import unity.RaycastHit2D;

// PORT-NOTE: C# 中 LevelRaycaster 继承 UnityEngine.EventSystems.Physics2DRaycaster。
// HaxeFlixel 没有 uGUI 事件系统，这里提供一个等价的独立射线检测器，
// 保留 ComputeRayAndDistance / Raycast 的核心筛选逻辑与结果填充顺序。
// TODO-PORT: Physics2DRaycaster 基类与 [AddComponentMenu]/[RequireComponent] 特性无等价实现。
class LevelRaycaster extends UIBehaviour
{
	private function new()
	{
		super();
	}

	public function Init(level:LevelEngine):Void
	{
		this.level = level;
	}
	public function SetHeldItem(definition:HeldItemDefinition, data:IHeldItemData, radius:Float):Void
	{
		heldItemDefinition = definition;
		heldItemData = data;
		castRadius = radius;
	}
	/// <summary>
	/// Raycast against 2D elements in the scene.
	/// </summary>
	public function Raycast(eventData:PointerEventData, resultAppendList:Array<RaycastResult>):Void
	{
		var ray = new Ray();
		var distanceToClipPlane = 0.0;
		var displayIndex = 0;
		if (!ComputeRayAndDistance(eventData, ray, displayIndex, distanceToClipPlane))
			return;

		var hitCount = 0;

		if (maxRayIntersections == 0)
		{
			if (castRadius <= 0)
			{
				// TODO-PORT: unity.Physics2D shim 只有 Raycast/OverlapPoint/OverlapCircle（移植层暂无 2D 物理后端），
				// 缺少 Physics2D.GetRayIntersectionAll / CircleCastAll / GetRayIntersectionNonAlloc /
				// CircleCastNonAlloc / ClosestPoint。此处保留原逻辑结构，缺失的查询退化为空结果；
				// 另外 ComputeRayAndDistance 目前恒返回 false，本段本就不可达。shim 补齐后请恢复原调用。
				m_Hits = [];
			}
			else
			{
				var hits:Array<RaycastHit2D> = [];
				m_Hits = ProcessCircleCasts(hits, ray.origin, distanceToClipPlane);
			}
			hitCount = m_Hits.length;
		}
		else
		{
			if (m_LastMaxRayIntersections != m_MaxRayIntersections)
			{
				m_Hits = [];
				m_Hits.resize(maxRayIntersections);
				m_LastMaxRayIntersections = m_MaxRayIntersections;
			}

			if (castRadius <= 0)
			{
				// TODO-PORT: Physics2D.GetRayIntersectionNonAlloc 在 shim 中缺失（见上方说明）。
				hitCount = 0;
			}
			else
			{
				// TODO-PORT: Physics2D.CircleCastNonAlloc 在 shim 中缺失（见上方说明）。
				hitCount = ProcessCircleCastsNonAlloc(m_Hits, 0, ray.origin, distanceToClipPlane);
			}
		}

		if (hitCount == 0)
			return;

		var b = 0;
		var bmax = hitCount;
		while (b < bmax)
		{
			var hit = m_Hits[b];
			var go = hit.collider.gameObject;

			var receiver = go.GetComponentInParent(ILevelRaycastReceiver);
			if (receiver == null)
			{
				b++;
				continue;
			}
			if (!receiver.IsValidReceiver(level, heldItemDefinition, heldItemData, eventData))
			{
				b++;
				continue;
			}

			var result = new RaycastResult();
			result.gameObject = go;
			result.module = this;
			result.distance = hit.distance;
			result.worldPosition = hit.point;
			result.worldNormal = hit.normal;
			result.screenPosition = eventData.position;
			// TODO-PORT: UnityEngine.EventSystems.RaycastResult.displayIndex 在 unity shim 中缺失，暂不写出。
			result.index = resultAppendList.length;
			result.sortingLayer = receiver.GetSortingLayer();
			result.sortingOrder = receiver.GetSortingOrder();

			resultAppendList.push(result);
			b++;
		}
	}
	private function ProcessCircleCasts(hits:Array<RaycastHit2D>, origin:Vector3, maxDistance:Float):Array<RaycastHit2D>
	{
		var hitList:Array<RaycastHit2D> = [];
		for (i in 0...hits.length)
		{
			var hit = hits[i];
			// 获取碰撞体上最近点（2D坐标）
			// TODO-PORT: Physics2D.ClosestPoint 在 unity shim 中缺失，退化为碰撞体 transform 的 2D 位置。
			var closestPoint = new Vector2(hit.collider.transform.position.x, hit.collider.transform.position.y);

			// 转换为3D点
			var hitPoint3D = new Vector3(closestPoint.x, closestPoint.y, hit.collider.transform.position.z);

			// 计算真实3D距离
			var distance = Vector3.Distance(origin, hitPoint3D);
			hit.distance = distance;
			// TODO-PORT: unity.RaycastHit2D shim 只有 distance（C# 还有 fraction），故略去 fraction 赋值。
			if (distance > maxDistance)
				continue;
			hitList.push(hit);
		}
		return hitList;
	}
	private function ProcessCircleCastsNonAlloc(hits:Array<RaycastHit2D>, count:Int, origin:Vector3, maxDistance:Float):Int
	{
		var finalCount = count;
		for (i in 0...count)
		{
			var hit = hits[i];
			// 获取碰撞体上最近点（2D坐标）
			// TODO-PORT: Physics2D.ClosestPoint 在 unity shim 中缺失，退化为碰撞体 transform 的 2D 位置。
			var closestPoint = new Vector2(hit.collider.transform.position.x, hit.collider.transform.position.y);

			// 转换为3D点
			var hitPoint3D = new Vector3(closestPoint.x, closestPoint.y, hit.collider.transform.position.z);

			// 计算真实3D距离
			var distance = Vector3.Distance(origin, hitPoint3D);
			hit.distance = distance;
			// TODO-PORT: unity.RaycastHit2D shim 只有 distance（C# 还有 fraction），故略去 fraction 赋值。
			if (distance > maxDistance)
			{
				var j = i;
				while (j < count - 1)
				{
					hits[j] = hits[j + 1];
					j++;
				}
				finalCount--;
			}
		}
		return finalCount;
	}

	// PORT-NOTE: 以下成员来自 C# 基类 Physics2DRaycaster / BaseRaycaster，
	// 在 Haxe 兼容层中以占位字段与最小实现保留。
	public function ComputeRayAndDistance(eventData:PointerEventData, ray:Ray, displayIndex:Int, distanceToClipPlane:Float):Bool
	{
		// TODO-PORT: 需要相机与显示设备信息，兼容层暂未实现，返回 false。
		return false;
	}
	public var maxRayIntersections:Int = 0;
	public var finalEventMask:Int = -1;

	var m_Hits:Array<RaycastHit2D>;
	private var m_MaxRayIntersections:Int = 0;
	private var m_LastMaxRayIntersections:Int = 0;
	private var heldItemDefinition:HeldItemDefinition;
	private var heldItemData:IHeldItemData;
	private var castRadius:Float;
	private var level:LevelEngine;
}
