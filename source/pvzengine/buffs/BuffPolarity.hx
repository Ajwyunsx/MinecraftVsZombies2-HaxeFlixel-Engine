// Ported from: Assets/Scripts/Engine/Level/Buffs/BuffPolarity.cs
// PORT-NOTE: C# static class 的 const 常量 → Haxe 全静态类 + public static inline var（PORTING.md）。
package pvzengine.buffs;

class BuffPolarity
{
	public static inline var UTILITY:Int = 0;
	public static inline var POSITIVE:Int = 1;
	public static inline var NEGATIVE:Int = 2;
	public static inline var MIXED:Int = 3;
}

// PORT-NOTE: C# 同文件内的 BuffClarity（工程内无其它引用），按 PORTING.md「其余类放同文件底部」保留为模块子类型
//   pvzengine.buffs.BuffPolarity.BuffClarity。
class BuffClarity
{
	public static inline var LOW:Int = 0;
	public static inline var MEDIUM:Int = 1;
	public static inline var HIGH:Int = 2;
}
