// Ported from: Assets/Scripts/Engine/Level/Collisions/Level/QuadTreeParams.cs
// PORT-NOTE: C# 为 struct；上层代码（mvz2/level/LevelController.hx 的 Awake_Collision）
// 用 `new QuadTreeParams()` 后逐字段赋值再传入 BuiltinCollisionSystem，故实现为普通类。
package pvzengine.collisions.level;

import unity.Rect;

class QuadTreeParams
{
    public function new()
    {
    }
    public var size:Rect = new Rect(0, 0, 0, 0); // PORT-NOTE: C# Rect 为 struct，默认 (0,0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var maxObjects:Int;
    public var collapseObjects:Int;
    public var maxDepth:Int;
}
