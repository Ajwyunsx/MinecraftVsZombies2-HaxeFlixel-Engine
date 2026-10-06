// Ported from: Assets/Scripts/ExpressionEvaluator/Expr/VarExpr.cs

package expressionevaluator;

class VarExpr extends Expr {
	private var _name:String;

	public function new(name:String) {
		super();
		_name = name;
	}

	public override function Eval(ctx:IAttributeContext):Dynamic {
		return ctx.EvaluateVariable(_name);
	}
}
