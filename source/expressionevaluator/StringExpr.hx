// Ported from: Assets/Scripts/ExpressionEvaluator/Expr/StringExpr.cs

package expressionevaluator;

class StringExpr extends Expr {
	private var _value:String;

	public function new(v:String) {
		super();
		_value = v;
	}

	public override function Eval(ctx:IAttributeContext):Dynamic {
		return _value;
	}
}
