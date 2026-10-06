// Ported from: Assets/Scripts/ExpressionEvaluator/Parser.cs

package expressionevaluator;

class Parser {
	private var _tk:Tokenizer;
	private var _cur:Token;

	public function new() {}

	public function Parse(text:String):Expr {
		_tk = new Tokenizer(text);
		_cur = _tk.Next();
		return ParseExpr();
	}

	private function Next():Void {
		if (_tk == null)
			throw "Parser is not parsing text!";
		_cur = _tk.Next();
	}

	private function ParseExpr():Expr {
		var left = ParseTerm();
		while (_cur.Type == TokenType.Plus || _cur.Type == TokenType.Minus) {
			var op = _cur.Type;
			Next();
			var right = ParseTerm();
			left = new BinaryExpr(left, right, op);
		}
		return left;
	}

	private function ParseTerm():Expr {
		var left = ParseFactor();
		while (_cur.Type == TokenType.Mul || _cur.Type == TokenType.Div) {
			var op = _cur.Type;
			Next();
			var right = ParseFactor();
			left = new BinaryExpr(left, right, op);
		}
		return left;
	}

	private function ParseFactor():Expr {
		if (_cur.Type == TokenType.Number) {
			var n = new NumberExpr(_cur.Number);
			Next();
			return n;
		}

		if (_cur.Type == TokenType.String) {
			var s = new StringExpr(_cur.Text);
			Next();
			return s;
		}

		if (_cur.Type == TokenType.Identifier) {
			var name = _cur.Text;
			Next();

			if (_cur.Type == TokenType.LParen) {
				Next();
				var args = new Array<Expr>();

				if (_cur.Type != TokenType.RParen) {
					while (true) {
						args.push(ParseExpr());
						if (_cur.Type == TokenType.Comma) {
							Next();
							continue;
						}
						break;
					}
				}

				if (_cur.Type != TokenType.RParen)
					throw "Missing )";

				Next();
				return new FuncExpr(name, args);
			}

			return new VarExpr(name);
		}

		if (_cur.Type == TokenType.LParen) {
			Next();
			var e = ParseExpr();
			if (_cur.Type != TokenType.RParen)
				throw "Missing )";
			Next();
			return e;
		}

		throw "Unexpected token";
	}
}
