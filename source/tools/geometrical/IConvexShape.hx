// Ported from: Assets/Scripts/Engine/Tools/Geometry/IConvexShape.cs
package tools.geometrical;

import unity.Vector3;

// 凸体接口
interface IConvexShape
{
	public function GetFarthestPointInDirection(direction:Vector3):Vector3;
	public function GetCenter():Vector3;
}
