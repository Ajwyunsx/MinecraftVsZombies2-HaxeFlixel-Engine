// Ported from: Assets/Scripts/ExpressionEvaluator/Expr/NumberExpr.cs

package expressionevaluator;

class NumberExpr extends Expr {
	private var _value:Float;

	public function new(v:Float) {
		super();
		_value = v;
	}

	public override function Eval(ctx:IAttributeContext):Dynamic {
		return _value;
	}
}
