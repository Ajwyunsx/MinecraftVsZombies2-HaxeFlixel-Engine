// Ported from: Assets/Scripts/ExpressionEvaluator/Tokens/TokenType.cs

package expressionevaluator;

// PORT-NOTE: C# enum → Haxe enum abstract（数值与 C# 声明顺序一致）。
enum abstract TokenType(Int) {
	var Number = 0;
	var String = 1;
	var Identifier = 2;
	var Plus = 3;
	var Minus = 4;
	var Mul = 5;
	var Div = 6;
	var LParen = 7;
	var RParen = 8;
	var Comma = 9;
	var End = 10;
}
