// Ported from: Assets/Scripts/ExpressionEvaluator/Tokens/Tokenizer.cs

package expressionevaluator;

class Tokenizer {
	private var _text:String;
	// PORT-NOTE: C# int 字段默认 0；Haxe 动态目标上未初始化的 Int 为 null，故显式初始化。
	private var _pos:Int = 0;

	public function new(text:String) {
		_text = text;
	}

	public function Next():Token {
		SkipWhite();

		if (_pos >= _text.length)
			return new Token(TokenType.End);

		var c = _text.charAt(_pos);

		if (isDigit(c) || c == ".")
			return ReadNumber();

		if (c == "\"")
			return ReadString();

		if (isLetter(c) || c == "_")
			return ReadIdentifier();

		_pos++;
		switch (c) {
			case "+":
				return new Token(TokenType.Plus);
			case "-":
				return new Token(TokenType.Minus);
			case "*":
				return new Token(TokenType.Mul);
			case "/":
				return new Token(TokenType.Div);
			case "(":
				return new Token(TokenType.LParen);
			case ")":
				return new Token(TokenType.RParen);
			case ",":
				return new Token(TokenType.Comma);
			case _:
		}

		throw 'Unexpected char: ${c}';
	}

	private function SkipWhite():Void {
		while (_pos < _text.length && isWhiteSpace(_text.charAt(_pos)))
			_pos++;
	}

	private function ReadNumber():Token {
		var start = _pos;
		while (_pos < _text.length && (isDigit(_text.charAt(_pos)) || _text.charAt(_pos) == "."))
			_pos++;

		var s = _text.substr(start, _pos - start);
		// PORT-NOTE: double.Parse(s, CultureInfo.InvariantCulture) → Std.parseFloat。
		return new Token(TokenType.Number, null, Std.parseFloat(s));
	}

	private function ReadString():Token {
		_pos++; // skip "
		var start = _pos;

		while (_pos < _text.length && _text.charAt(_pos) != "\"")
			_pos++;

		var s = _text.substr(start, _pos - start);
		_pos++; // skip "

		return new Token(TokenType.String, s, 0);
	}

	private function ReadIdentifier():Token {
		var start = _pos;
		while (_pos < _text.length && (isLetterOrDigit(_text.charAt(_pos)) || _text.charAt(_pos) == "_"))
			_pos++;

		return new Token(TokenType.Identifier, _text.substr(start, _pos - start), 0);
	}

	// PORT-NOTE: C# char.IsDigit / char.IsLetter / char.IsLetterOrDigit / char.IsWhiteSpace
	// → 基于 ASCII 的等价判断（表达式语言只使用 ASCII 记号）。
	private static inline function isDigit(c:String):Bool {
		return c.length == 1 && c >= "0" && c <= "9";
	}
	private static inline function isLetter(c:String):Bool {
		return c.length == 1 && ((c >= "a" && c <= "z") || (c >= "A" && c <= "Z"));
	}
	private static inline function isLetterOrDigit(c:String):Bool {
		return isDigit(c) || isLetter(c);
	}
	private static inline function isWhiteSpace(c:String):Bool {
		return c == " " || c == "\t" || c == "\r" || c == "\n";
	}
}
