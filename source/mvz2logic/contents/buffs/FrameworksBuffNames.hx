// Ported from: Assets/Scripts/Logic/Contents/Buffs/FrameworksBuffID.cs
// PORT-NOTE: C# 用嵌套静态类 FrameworksBuffNames.Entity / FrameworksBuffNames.Enemy 组织名称常量。
// Haxe 不支持嵌套类，且同一包内两个模块不能声明同名子类型（FrameworksBuffID 已有 Entity/Enemy 子类型），
// 故此处把名称常量平铺为 Entity_/Enemy_ 前缀的常量。
package mvz2logic.contents.buffs;

class FrameworksBuffNames
{
	public static inline var Entity_damageColor:String = "damage_color";

	public static inline var Enemy_beingRiden:String = "being_riden";
	public static inline var Enemy_ridingPassenger:String = "riding_passenger";

	private function new() {}
}
