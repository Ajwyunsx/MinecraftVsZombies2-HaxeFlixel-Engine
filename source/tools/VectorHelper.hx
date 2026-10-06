// Ported from: Assets/Scripts/Engine/Tools/VectorHelper.cs
package tools;

import unity.Mathf;
import unity.Quaternion;
import unity.Vector2;
import unity.Vector3;

// C# 中本类是 UnityEngine.Vector2 / Vector3 的扩展方法集合，调用点写为 `vector.Abs()` 等。
// PORT-NOTE: 既有上层调用点未 `using tools.VectorHelper;`（运行期的 `Exists`/`Abs` 扩展由
// tools.ObjectExtensions 与 unity.Vector3 上的实例/静态成员承担），此处仍按 PORTING.md
// 「扩展方法改为静态普通方法」保留同签名静态方法。
class VectorHelper
{
	public static function RotateClockwise(vector:Vector2, angle:Float):Vector2
	{
		// C#: Quaternion.AngleAxis(angle, Vector3.back) * vector
		// PORT-NOTE: unity.Quaternion 上的 `*` 运算符重载（mul / mulV）在当前 shim 下无法正确解析，
		// 故显式调用 mulV，等价于 C# 的四元数乘向量。
		var rotation = Quaternion.AngleAxis(angle, Vector3.back);
		var rotated:Vector3 = Quaternion.mulV(rotation, new Vector3(vector.x, vector.y, 0));
		return new Vector2(rotated.x, rotated.y);
	}
	public static function Abs(vector:Vector3):Vector3
	{
		vector.x = Mathf.Abs(vector.x);
		vector.y = Mathf.Abs(vector.y);
		vector.z = Mathf.Abs(vector.z);
		return vector;
	}
}
