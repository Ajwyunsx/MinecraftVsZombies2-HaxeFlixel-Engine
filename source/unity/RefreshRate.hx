package unity;

// Minimal UnityEngine.RefreshRate shim (Unity 2022.3 中的刷新率结构体)。
// PORT-NOTE: Haxe 无运算符重载/隐式转换，value 供 C# 中 `{2:0.##}` 之类的数值格式化使用。
class RefreshRate
{
	public var numerator:Int;
	public var denominator:Int;

	public function new(numerator:Int = 0, denominator:Int = 0)
	{
		this.numerator = numerator;
		this.denominator = denominator;
	}

	public var value(get, never):Float;
	private function get_value():Float
	{
		return denominator == 0 ? 0 : numerator / denominator;
	}

	public function CompareTo(other:RefreshRate):Int
	{
		return Reflect.compare(value, other.value);
	}

	public function toString():String
	{
		return Std.string(value);
	}
}
