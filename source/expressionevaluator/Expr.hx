// Ported from: Assets/Scripts/ExpressionEvaluator/Expr/Expr.cs

package expressionevaluator;

// PORT-NOTE: C# abstract class → Haxe class；C# abstract 方法以 throw 代替。
class Expr {
	public function new() {}

	public function Eval(ctx:IAttributeContext):Dynamic {
		throw "abstract";
	}
}
