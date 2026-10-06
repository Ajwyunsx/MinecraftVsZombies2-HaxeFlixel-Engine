// Ported from: Assets/Scripts/Logic/HeldItems/HeldTargetFlag.cs (enum HeldTargetFlag)
package mvz2logic.helditems;

// PORT-NOTE: 为支持 C# 的位运算（mask |= ...），增加 from/to Int 与 |、& 运算符。
enum abstract HeldTargetFlag(Int) from Int to Int
{
	var None = 0;
	var Plant = 1;
	var Enemy = 1 << 1;
	var Obstacle = 1 << 2;
	var Boss = 1 << 3;
	var Cart = 1 << 4;
	var Pickup = 1 << 5;
	var Projectile = 1 << 6;
	var Effect = 1 << 7;
	// C#: Vulnerable = Plant | Enemy | Obstacle | Boss
	// TODO-PORT: Haxe 的 enum abstract 内部不能对枚举值使用位运算，改为等价的字面量表达式。
	var Vulnerable = 1 | (1 << 1) | (1 << 2) | (1 << 3);
	var All = (1 << 8) - 1;

	@:op(A | B) static function or(a:HeldTargetFlag, b:HeldTargetFlag):HeldTargetFlag;
	@:op(A & B) static function and(a:HeldTargetFlag, b:HeldTargetFlag):HeldTargetFlag;
}
