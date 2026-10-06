package unity;

// Minimal UnityEngine.Gizmos shim（Unity 编辑器/调试绘制 API）。
// PORT-NOTE: C# 侧只在 LevelController_OnDrawGizmos 中用它对碰撞四叉树/碰撞盒做调试可视化。
// HaxeFlixel 没有等价的“随手绘制”通道，这里保留 API 形状但绘制为空实现；
// 这样 LevelController 可以照搬 C# 的绘制逻辑，将来接真实绘制时也无需改调用点。
class Gizmos {
    public static var color:Color = new Color(1, 1, 1, 1);
    public static var matrix:Matrix4x4 = new Matrix4x4();

    public static function DrawCube(center:Vector3, size:Vector3):Void {}
    public static function DrawWireCube(center:Vector3, size:Vector3):Void {}
    public static function DrawSphere(center:Vector3, radius:Float):Void {}
    public static function DrawWireSphere(center:Vector3, radius:Float):Void {}
    public static function DrawLine(from:Vector3, to:Vector3):Void {}
    public static function DrawRay(r:Ray):Void {}
    public static function DrawRayV(origin:Vector3, direction:Vector3):Void {}
    public static function DrawMesh(mesh:Dynamic, ?position:Vector3, ?rotation:Quaternion, ?scale:Vector3):Void {}
}
