// Ported from: Assets/Scripts/ExpressionEvaluator/Tokens/Token.cs

package expressionevaluator;

// PORT-NOTE: C# struct → Haxe class（PORTING.md §struct）；
// C# 的对象初始化器 `new Token { Type = X }` → 带默认值的构造函数 `new Token(X)`。
class Token {
	public var Type:TokenType;
	public var Text:String;
	public var Number:Float;

	public function new(Type:TokenType = TokenType.End, Text:String = null, Number:Float = 0) {
		this.Type = Type;
		this.Text = Text;
		this.Number = Number;
	}
}
