package unity;

// Minimal UnityEngine.Matrix4x4 shim (row-major 4x4, only the parts used by the port).
class Matrix4x4 {
    public var m00:Float = 1; public var m01:Float = 0; public var m02:Float = 0; public var m03:Float = 0;
    public var m10:Float = 0; public var m11:Float = 1; public var m12:Float = 0; public var m13:Float = 0;
    public var m20:Float = 0; public var m21:Float = 0; public var m22:Float = 1; public var m23:Float = 0;
    public var m30:Float = 0; public var m31:Float = 0; public var m32:Float = 0; public var m33:Float = 1;

    public static var identity(get, never):Matrix4x4;
    static function get_identity():Matrix4x4 return new Matrix4x4();

    public function new() {}

    public function SetTRS(pos:Vector3, q:Quaternion, s:Vector3):Void {
        // PORT-NOTE: 只处理平移与缩放（2D 用途）。
        m00 = s.x; m11 = s.y; m22 = s.z;
        m03 = pos.x; m13 = pos.y; m23 = pos.z;
    }

    public function MultiplyPoint(point:Vector3):Vector3 {
        return new Vector3(
            m00 * point.x + m01 * point.y + m02 * point.z + m03,
            m10 * point.x + m11 * point.y + m12 * point.z + m13,
            m20 * point.x + m21 * point.y + m22 * point.z + m23);
    }
    public function MultiplyPoint3x4(point:Vector3):Vector3 return MultiplyPoint(point);
    public function MultiplyVector(v:Vector3):Vector3 {
        return new Vector3(
            m00 * v.x + m01 * v.y + m02 * v.z,
            m10 * v.x + m11 * v.y + m12 * v.z,
            m20 * v.x + m21 * v.y + m22 * v.z);
    }

    public var inverse(get, never):Matrix4x4;
    function get_inverse():Matrix4x4 {
        // PORT-NOTE: 仅支持无旋转的仿射逆变换。
        var result = new Matrix4x4();
        result.m00 = m00 != 0 ? 1 / m00 : 0;
        result.m11 = m11 != 0 ? 1 / m11 : 0;
        result.m22 = m22 != 0 ? 1 / m22 : 0;
        result.m03 = -m03 * result.m00;
        result.m13 = -m13 * result.m11;
        result.m23 = -m23 * result.m22;
        return result;
    }
}
