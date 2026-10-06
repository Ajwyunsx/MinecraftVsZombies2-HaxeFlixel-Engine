// Ported from: Assets/Scripts/ExpressionEvaluator/ExpressionEngine.cs

package expressionevaluator;

// =============================
// IL2CPP SAFE EXPRESSION ENGINE
// - No Reflection.Emit
// - No Expression.Compile
// - Pure interpreter (AST)
// - Designed for Unity + Attribute Dictionary systems
// =============================
class ExpressionEngine {
	private static var _parser:Parser = new Parser();
	private static var _cache:Map<String, CompiledExpression> = new Map();

	public static function Compile(expr:String):CompiledExpression {
		var c = _cache.get(expr);
		if (c != null)
			return c;

		var parsed = _parser.Parse(expr);
		var compiled = new CompiledExpression(parsed, expr);
		_cache.set(expr, compiled);
		return compiled;
	}
}
