// Ported from: Assets/Scripts/ExpressionEvaluator/Expr/FuncExpr.cs

package expressionevaluator;

class FuncExpr extends Expr {
	private var _name:String;
	private var _args:Array<Expr>;

	public function new(name:String, args:Array<Expr>) {
		super();
		_name = name;
		_args = args;
	}

	public override function Eval(ctx:IAttributeContext):Dynamic {
		var argArray = new Array<Dynamic>();
		for (i in 0..._args.length) {
			argArray[i] = _args[i].Eval(ctx);
		}
		return ctx.EvaluateFunction(_name, argArray);
	}
}
