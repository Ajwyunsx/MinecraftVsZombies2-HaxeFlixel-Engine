// Ported from: Assets/Scripts/Logic/Inputs/PointerPhase.cs (struct PointerData)
// PORT-NOTE: C# struct 改为普通类；IEquatable<T> 由 Haxe 的 == 运算符重载等价实现。
package mvz2logic.inputs;

class PointerData
{
	public function new(button:Int = 0, type:Int = 0)
	{
		this.button = button;
		this.type = type;
	}

	public function toString():String
	{
		return 'button: ${button}, type: ${type}';
	}
	public function Equals(other:PointerData):Bool
	{
		return button == other.button &&
			   type == other.type;
	}
	public function GetPointerIndex():Int
	{
		return type == PointerTypes.MOUSE ? -button - 1 : button;
	}
	public function GetHashCode():Int
	{
		// PORT-NOTE: C# 为 HashCode.Combine(button, type)。
		return button * 397 ^ type;
	}

	// PORT-NOTE: Haxe 不支持类上的运算符重载（@:op 仅对 abstract 有效），改为显式静态方法 eq/neq。
	public static function eq(left:PointerData, right:PointerData):Bool
	{
		if (left == null || right == null)
			return left == right;
		return left.Equals(right);
	}
	public static function neq(left:PointerData, right:PointerData):Bool
	{
		return !eq(left, right);
	}

	public var button:Int;
	public var type:Int;
}
