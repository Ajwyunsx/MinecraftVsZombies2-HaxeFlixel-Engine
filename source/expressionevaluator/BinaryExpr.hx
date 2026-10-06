// Ported from: Assets/Scripts/ExpressionEvaluator/Expr/BinaryExpr.cs

package expressionevaluator;

class BinaryExpr extends Expr {
	private var _left:Expr;
	private var _right:Expr;
	private var _op:TokenType;

	public function new(l:Expr, r:Expr, op:TokenType) {
		super();
		_left = l;
		_right = r;
		_op = op;
	}

	public override function Eval(ctx:IAttributeContext):Dynamic {
		var a:Float = toDouble(_left.Eval(ctx));
		var b:Float = toDouble(_right.Eval(ctx));
		switch (_op) {
			case TokenType.Plus:
				return a + b;
			case TokenType.Minus:
				return a - b;
			case TokenType.Mul:
				return a * b;
			case TokenType.Div:
				return b == 0 ? 0 : a / b;
			case _:
				throw "Invalid op";
		}
	}

	// PORT-NOTE: C# Convert.ToDouble(object) → 手写等价转换。
	private static function toDouble(v:Dynamic):Float {
		if (v == null)
			return 0;
		if (Std.isOfType(v, Float))
			return cast(v, Float);
		if (Std.isOfType(v, Int))
			return cast(v, Int);
		if (Std.isOfType(v, Bool))
			return (cast v : Bool) ? 1 : 0;
		return Std.parseFloat(Std.string(v));
	}
}
