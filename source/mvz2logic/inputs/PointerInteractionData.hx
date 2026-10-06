// Ported from: Assets/Scripts/Logic/Inputs/PointerPhase.cs (struct PointerInteractionData)
// PORT-NOTE: C# struct 改为普通类；IEquatable<T> 由 Haxe 的 == 运算符重载等价实现。
package mvz2logic.inputs;

class PointerInteractionData
{
	public function new(?pointer:PointerData, interaction:PointerInteraction = PointerInteraction.Hover)
	{
		this.pointer = pointer;
		this.interaction = interaction;
	}

	public function toString():String
	{
		return 'pointer: ${pointer}\ninteraction: ${interaction}';
	}
	public function Equals(other:PointerInteractionData):Bool
	{
		var pointerEquals = (pointer == null && other.pointer == null) || (pointer != null && pointer.Equals(other.pointer));
		return pointerEquals &&
			   interaction == other.interaction;
	}
	public function GetHashCode():Int
	{
		// PORT-NOTE: C# 为 HashCode.Combine(pointer, interaction)。
		var pointerHash = pointer != null ? pointer.GetHashCode() : 0;
		return pointerHash * 397 ^ (cast interaction : Int);
	}

	// PORT-NOTE: Haxe 不支持类上的运算符重载（@:op 仅对 abstract 有效），改为显式静态方法 eq/neq。
	public static function eq(left:PointerInteractionData, right:PointerInteractionData):Bool
	{
		if (left == null || right == null)
			return left == right;
		return left.Equals(right);
	}
	public static function neq(left:PointerInteractionData, right:PointerInteractionData):Bool
	{
		return !eq(left, right);
	}

	public var pointer:PointerData;
	public var interaction:PointerInteraction;
}
