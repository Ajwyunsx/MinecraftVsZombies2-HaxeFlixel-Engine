package unity;

// Minimal UnityEngine.Physics2D shim.
class Physics2D {
    public static var queriesHitTriggers:Bool = true;

    // C#: public static void SyncTransforms()
    // PORT-NOTE: Unity 用它把 Transform 改动立即同步到物理世界；移植层没有 2D 物理后端
    // （见下方 Raycast 的 TODO-PORT），故为无副作用的空实现，调用点保持与 C# 一致。
    public static function SyncTransforms():Void {}

    // PORT-NOTE: `?distance:Float = Math.POSITIVE_INFINITY` 不是 Haxe 常量默认值，改用 null 并在函数内回落。
    public static function Raycast(origin:Vector2, direction:Vector2, ?distance:Null<Float> = null, ?layerMask:Int = -1):RaycastHit2D {
        // TODO-PORT: 物理查询由移植层的 Flixel 场景负责，尚无 2D 物理后端。
        return null;
    }
    public static function OverlapPoint(point:Vector2, ?layerMask:Int = -1):Collider2D return null;
    public static function OverlapCircle(point:Vector2, radius:Float, ?layerMask:Int = -1):Collider2D return null;

    // ======================================================================
    // PORT-NOTE: 以下查询 API 是 mvz2.level.LevelRaycaster 在 C# 中用到、而 shim 原先缺失的成员。
    // 移植层没有 2D 物理后端（见上方 TODO-PORT），全部返回空结果；
    // 保留这些入口是为了让调用点能按 C# 原样书写，而不必在游戏逻辑里写退化分支。
    // ======================================================================
    // C#: public static RaycastHit2D[] GetRayIntersectionAll(Ray ray, float distance, int layerMask)
    public static function GetRayIntersectionAll(ray:Ray, ?distance:Float = 0, ?layerMask:Int = -1):Array<RaycastHit2D> return [];
    // C#: public static int GetRayIntersectionNonAlloc(Ray ray, RaycastHit2D[] results, float distance, int layerMask)
    public static function GetRayIntersectionNonAlloc(ray:Ray, results:Array<RaycastHit2D>, ?distance:Float = 0, ?layerMask:Int = -1):Int {
        if (results != null) results.resize(0);
        return 0;
    }
    // C#: public static RaycastHit2D[] CircleCastAll(Vector2 origin, float radius, Vector2 direction, float distance, int layerMask)
    public static function CircleCastAll(origin:Vector2, radius:Float, direction:Vector2, ?distance:Float = 0, ?layerMask:Int = -1):Array<RaycastHit2D> return [];
    // C#: public static int CircleCastNonAlloc(Vector2 origin, float radius, Vector2 direction, RaycastHit2D[] results, float distance, int layerMask)
    public static function CircleCastNonAlloc(origin:Vector2, radius:Float, direction:Vector2, results:Array<RaycastHit2D>, ?distance:Float = 0, ?layerMask:Int = -1):Int {
        if (results != null) results.resize(0);
        return 0;
    }
    // C#: public static Vector2 ClosestPoint(Vector2 position, Collider2D collider)
    // PORT-NOTE: 无碰撞体几何，回落到碰撞体的 transform 位置（与 LevelRaycaster 现有退化一致）。
    public static function ClosestPoint(position:Vector2, collider:Collider2D):Vector2 {
        if (collider == null || collider.transform == null) return position;
        return new Vector2(collider.transform.position.x, collider.transform.position.y);
    }
}
