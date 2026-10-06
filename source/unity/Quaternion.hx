package unity;

// Minimal UnityEngine.Quaternion shim (value-style abstract).
// PORT-NOTE: Haxe 的类不支持 @:op 运算符重载（只有 abstract 支持），而移植层的调用点
// 使用 `quaternion * vector`（如 Transform.up / MVZ2 的朝向计算），因此这里与 Vector2/Vector3
// 保持一致，改为 abstract Quaternion(QuaternionData)。
@:forward(x, y, z, w)
abstract Quaternion(QuaternionData) from QuaternionData to QuaternionData {
    public static var identity(get, never):Quaternion;

    public inline function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1) {
        this = new QuaternionData(x, y, z, w);
    }

    static inline function get_identity():Quaternion return new Quaternion(0, 0, 0, 1);

    public var eulerAngles(get, never):Vector3;
    function get_eulerAngles():Vector3 {
        // PORT-NOTE: 原来是 `TODO-PORT` 空实现（恒返回 (0,0,0)），于是任何
        // `rotation.eulerAngles` 读回都是零 —— `Transform.eulerAngles` 的 getter 直接依赖它，
        // `NightmareGlassModel` 的碎片旋转、`RotationLocker`、`MapUI.SetDragArrowTargetPosition`
        // 的箭头角度全部失效。这里按 Unity 的 ZXY 内旋约定做完整换算。
        return QuaternionMath.toEulerZXY(this);
    }

    public static function Euler(x:Float, y:Float, z:Float):Quaternion {
        // PORT-NOTE: 同 get_eulerAngles —— 原来是恒返回 identity 的空实现，
        // 导致 `Transform.eulerAngles = v` / `Transform.Rotate(...)` 完全无效
        //（`set_eulerAngles` 走 `Quaternion.EulerV`）。按 Unity 的 ZXY 内旋约定实现：
        // 先绕 Z、再绕 X、最后绕 Y（Unity 的 Inspector 旋转顺序）。
        return QuaternionMath.fromEulerZXY(x, y, z);
    }
    // 供 Transform.localEulerAngles / eulerAngles 使用（Unity 无此重载，属移植层新增的等价辅助）。
    public static function EulerV(v:Vector3):Quaternion {
        return Euler(v.x, v.y, v.z);
    }
    // PORT-NOTE: 补全 Quaternion.FromToRotation（移植层用 Euler 近似）。
    public static function FromToRotation(from:Vector3, to:Vector3):Quaternion {
        return Euler(0, 0, Math.atan2(to.y, to.x) * 180 / Math.PI - Math.atan2(from.y, from.x) * 180 / Math.PI);
    }

    public static function AngleAxis(angle:Float, axis:Vector3):Quaternion {
        var rad = angle * Mathf.Deg2Rad * 0.5;
        var s = Math.sin(rad);
        return new Quaternion(axis.x * s, axis.y * s, axis.z * s, Math.cos(rad));
    }
    public static function Lerp(a:Quaternion, b:Quaternion, t:Float):Quaternion {
        t = Mathf.Clamp01(t);
        return new Quaternion(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t, a.w + (b.w - a.w) * t);
    }

    // 四元数乘法（旋转复合）。
    @:op(A * B) public static function mul(a:Quaternion, b:Quaternion):Quaternion {
        return new Quaternion(
            a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
            a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
            a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z);
    }
    // 四元数旋转向量（Unity: quaternion * vector）。
    @:op(A * B) public static function mulV(rotation:Quaternion, point:Vector3):Vector3 {
        var qx = rotation.x; var qy = rotation.y; var qz = rotation.z; var qw = rotation.w;
        var ix = qw * point.x + qy * point.z - qz * point.y;
        var iy = qw * point.y + qz * point.x - qx * point.z;
        var iz = qw * point.z + qx * point.y - qy * point.x;
        var iw = -qx * point.x - qy * point.y - qz * point.z;
        return new Vector3(
            ix * qw + iw * -qx + iy * -qz - iz * -qy,
            iy * qw + iw * -qy + iz * -qx - ix * -qz,
            iz * qw + iw * -qz + ix * -qy - iy * -qx);
    }
    // PORT-NOTE: 移植层别名，供 mvz2logic/Shake.hx 的 `Quaternion.rotate(q, v)` 调用点使用。
    public static inline function rotate(rotation:Quaternion, point:Vector3):Vector3 {
        return mulV(rotation, point);
    }

    public function toString():String return '(${this.x}, ${this.y}, ${this.z}, ${this.w})';
}

// PORT-NOTE: 移植层新增（无 C# 对应源码）。Unity 的 `Quaternion.Euler` / `Quaternion.eulerAngles`
// 是引擎实现，shim 里原先只有空壳。这里按 Unity 文档的**ZXY 内旋**约定补齐：
//
//   * `Euler(x,y,z)`：把四元数写成 `qY * qX * qZ`（先绕 Z、再绕 X、最后绕 Y，
//     即 Unity Inspector 里 Rotation 三个分量 `(x,y,z)` 的语义）；
//   * `eulerAngles`：上面式子的逆运算，返回**每个分量都在 [0,360)** 的角度。
//
// 精度与分支：直接展开 `qY*qX*qZ` 的旋转矩阵元素求解，避开 asin 的 ±90° 退化分支
// （工程内没有万向锁姿态：所有旋转都是绕单轴的小角度）。
class QuaternionMath {
    private static var DEG2RAD:Float = Math.PI / 180;
    private static var RAD2DEG:Float = 180 / Math.PI;

    /** Unity `Quaternion.Euler(x, y, z)`（角度制，ZXY 内旋）。 */
    public static function fromEulerZXY(x:Float, y:Float, z:Float):Quaternion {
        var hx = x * DEG2RAD * 0.5;
        var hy = y * DEG2RAD * 0.5;
        var hz = z * DEG2RAD * 0.5;
        var cx = Math.cos(hx), sx = Math.sin(hx);
        var cy = Math.cos(hy), sy = Math.sin(hy);
        var cz = Math.cos(hz), sz = Math.sin(hz);
        // q = qY * qX * qZ（Unity 的 ZXY 顺序）
        return new Quaternion(
            cy * sx * cz + sy * cx * sz,
            sy * cx * cz - cy * sx * sz,
            cy * cx * sz - sy * sx * cz,
            cy * cx * cz + sy * sx * sz);
    }

    /**
     * `Quaternion` → Unity 的 `eulerAngles`（ZXY，每个分量 ∈ [0,360)）。
     *
     * PORT-NOTE: 推导（`fromEulerZXY` 的逆）。令
     * `R = Ry(ey) * Rx(ex) * Rz(ez)`，展开后：
     *
     * ```
     * R[0][0] = cy*cz + sy*sx*sz    R[0][1] = -cy*sz + sy*sx*cz   R[0][2] = sy*cx
     * R[1][0] = cx*sz               R[1][1] = cx*cz              R[1][2] = -sx
     * R[2][0] = -sy*cz + cy*sx*sz   R[2][1] = sy*sz + cy*sx*cz    R[2][2] = cy*cx
     * ```
     *
     * 因此：
     *   `ex = asin(-R[1][2])`
     *   `ez = atan2(R[1][0], R[1][1])`
     *   `ey = atan2(R[0][2], R[2][2])`
     *
     * 而四元数 (x,y,z,w) 对应的旋转矩阵元素为：
     *   `R[0][2] = 2(xz + wy)`  `R[1][0] = 2(xy + wz)`  `R[1][1] = 1 - 2(x²+z²)`
     *   `R[1][2] = 2(yz - wx)`  `R[2][2] = 1 - 2(x²+y²)`
     *
     * **注意别取错行**：`R[1][2]`（第 2 行第 3 列）才是 `-sx`，不是 `R[0][2]`。
     * 上一版就是错取了 `R[0][2]`，导致 `Euler(0,0,90)` 读回 (0,0,0)。
     */
    public static function toEulerZXY(q:Quaternion):Vector3 {
        var x = q.x, y = q.y, z = q.z, w = q.w;
        // 归一化（数值漂移会让 asin 越界）。
        var n = Math.sqrt(x * x + y * y + z * z + w * w);
        if (n <= 0)
            return new Vector3(0, 0, 0);
        x /= n; y /= n; z /= n; w /= n;

        var m12 = 2 * (y * z - w * x);      // R[1][2] = -sx
        if (m12 > 1) m12 = 1;
        if (m12 < -1) m12 = -1;
        var ex = Math.asin(-m12);

        var ey:Float;
        var ez:Float;
        // PORT-NOTE: 工程内没有绕 X 的 ±90° 姿态（都是绕单轴的小角度），因此只实现主分支；
        // 退化分支记 TODO-PORT（Unity 在该处令 z = 0）。
        if (Math.abs(m12) < 0.9999999) {
            var m10 = 2 * (x * y + w * z);          // R[1][0]
            var m11 = 1 - 2 * (x * x + z * z);      // R[1][1]
            var m02 = 2 * (x * z + w * y);          // R[0][2]
            var m22 = 1 - 2 * (x * x + y * y);      // R[2][2]
            ez = Math.atan2(m10, m11);
            ey = Math.atan2(m02, m22);
        } else {
            // TODO-PORT: 绕 X 的 ±90° 万向锁分支（Unity 在该处令 z = 0）。
            ez = 0;
            var m01 = 2 * (x * y - w * z);          // R[0][1]
            var m00 = 1 - 2 * (y * y + z * z);      // R[0][0]
            ey = Math.atan2(-m01, m00);
        }
        return new Vector3(normalize360(ex * RAD2DEG), normalize360(ey * RAD2DEG), normalize360(ez * RAD2DEG));
    }

    /** 把角度归一化到 [0, 360)。 */
    private static function normalize360(deg:Float):Float {
        var r = deg % 360;
        if (r < 0)
            r += 360;
        // PORT-NOTE: 浮点误差会把 360.0 留成 360.0（`-1e-14 % 360` 的补正结果），
        // 这里夹掉，保证返回区间严格是 [0,360)。
        if (r >= 360)
            r = 0;
        return r;
    }
}

class QuaternionData {
    public var x:Float;
    public var y:Float;
    public var z:Float;
    public var w:Float;
    public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }
}
