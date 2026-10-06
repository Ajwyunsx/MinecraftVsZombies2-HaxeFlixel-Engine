// Ported from: Tools.ObjectExtensions (external Tools 库的 Exists 扩展方法)
package tools;

// PORT-NOTE: 原工程依赖外部 Tools 库的 `Exists(this UnityEngine.Object)` 扩展方法。
// Haxe 用静态扩展方法 + `using tools.ObjectExtensions;` 保持调用写法一致。
class ObjectExtensions {
    public static function Exists(obj:Dynamic):Bool {
        if (obj == null) return false;
        if (Std.isOfType(obj, unity.UnityObject)) {
            return true;
        }
        return true;
    }

    public static function IsNull(obj:Dynamic):Bool {
        return obj == null;
    }

    // PORT-NOTE: 原工程 Tools.Geometrical 的 Abs 扩展方法（Vector3）。
    public static function Abs(v:unity.Vector3):unity.Vector3 {
        return new unity.Vector3(Math.abs(v.x), Math.abs(v.y), Math.abs(v.z));
    }

    // PORT-NOTE: 原工程 Tools.Geometrical 的 RotateClockwise 扩展方法（Vector2 顺时针旋转角度）。
    public static function RotateClockwise(v:unity.Vector2, angle:Float):unity.Vector2 {
        var rad = -angle * Math.PI / 180;
        var cos = Math.cos(rad);
        var sin = Math.sin(rad);
        return new unity.Vector2(v.x * cos - v.y * sin, v.x * sin + v.y * cos);
    }
}
