// Ported from: Assets/Scripts/ExpressionEvaluator/CompiledExpression.cs

package expressionevaluator;

class CompiledExpression {
	private var _root:Expr;
	public var ExpressionString(default, null):String;

	// PORT-NOTE: C# internal 构造函数 → Haxe private + @:allow(expressionevaluator)，
	// 仅允许同一包（ExpressionEngine/Parser）实例化。
	@:allow(expressionevaluator)
	private function new(root:Expr, expressionString:String) {
		_root = root;
		ExpressionString = expressionString;
	}

	public function Evaluate(ctx:IAttributeContext):Dynamic {
		return _root.Eval(ctx);
	}
}
