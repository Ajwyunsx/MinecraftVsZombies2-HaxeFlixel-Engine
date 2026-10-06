// Ported from: Assets/Scripts/Engine/Level/Damage/DamageStates.cs
package pvzengine.damages;

// PORT-NOTE: C# `public static class DamageStates { public const int X = n; }` →
// Haxe 全静态类 + static inline var（PORTING.md 的 const 映射），与工程内其它静态类一致（不声明构造函数）。
class DamageStates
{
    public static inline var BREAK:Int = 0;
    public static inline var CONTINUE:Int = 1;
    public static inline var RETURN:Int = 2;
}
