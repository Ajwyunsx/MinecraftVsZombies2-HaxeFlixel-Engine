// Ported from: Assets/Scripts/Engine/Tools/RNG/XORShift.cs
// PORT-NOTE: C# 文件名是 XORShift.cs，但其中唯一（且为 internal 的）类型名为 XORShift128。
// Haxe 要求“模块名 == 主类型名”，故本文件命名为 XORShift128.hx。
package tools;

/**
 * 原实现使用 C# 的 `uint`（32 位无符号）。Haxe 只有 32 位有符号 Int，
 * 因此凡是无符号语义会改变结果的地方（取模、无符号比较、零扩展、uint→float）都显式换算，
 * 保证与原实现一致（x/y/z/w 仍按 32 位位模式存放，异或/移位/加减乘的位模式与 uint 相同）。
 */
class XORShift128
{
	public var x:Int = 0;
	public var y:Int = 0;
	public var z:Int = 0;
	public var w:Int = 0;

	private static inline var MT19937:Int = 1812433253;

	public function new() {}

	// Initialize Xorshift using a signed integer seed, calculating the state values using the
	// initialization method from Mersenne Twister (MT19937)
	// https://en.wikipedia.org/wiki/Mersenne_Twister#Initialization
	public function InitSeed(seed:Int):Void
	{
		x = seed;
		y = MT19937 * x + 1;
		z = MT19937 * y + 1;
		w = MT19937 * z + 1;
	}

	// Explicitly set the state parameters
	public function InitState(x:Int, y:Int, z:Int, w:Int):Void
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	// XORShift, returns an unsigned 32-bit integer (kept as the raw 32-bit bit pattern in Int)
	// PORT-NOTE: C# 为 `w = w ^ (w >> 19) ^ t ^ (t >> 8)`，其中 >> 是 uint 逻辑右移，
	// Haxe 用 `>>>`（逻辑右移）保持同一语义。
	private function XORShift():Int
	{
		var t = x ^ (x << 11);
		x = y;
		y = z;
		z = w;
		w = w ^ (w >>> 19) ^ t ^ (t >>> 8);
		return w;
	}

	// ---------------------------------------------------------------- UInt32 / uint
	// UnityEngine.Random doesn't have any uint functions so these functions behave exactly
	// like int Random.Range

	// Alias of base Next/XORShift
	public function NextUInt():Int
	{
		return XORShift();
	}

	// Generate a random unsigned 32-bit integer value in the range 0 (inclusive) to max (exclusive)
	public function NextUIntMax(max:Int):Int
	{
		if (max == 0)
			return 0;
		return uintMod(XORShift(), max);
	}

	// Generate random unsigned 32-bit integer value in the range min (inclusive) to max (exclusive)
	public function NextUIntRange(min:Int, max:Int):Int
	{
		if (max - min == 0)
			return min;

		if (uintLess(max, min))
			return min - uintMod(XORShift(), max + min);
		else
			return min + uintMod(XORShift(), max - min);
	}

	// ------------------------------------------------------------------ Int32 / int

	// Generate a random signed 32-bit integer value in the range -2,147,483,648 (inclusive)
	// to 2,147,483,647 (inclusive)
	public function NextInt():Int
	{
		return XORShift();
	}

	public function NextIntMax(max:Int):Int
	{
		return intMod(NextInt(), max);
	}

	// Generate a random signed 32-bit integer value in the range min (inclusive) to max (exclusive)
	// If you only need to generate positive integers, use NextUIntRange instead
	public function NextIntRange(min:Int, max:Int):Int
	{
		// If max and min are the same, just return min since it will result in a DivideByZeroException
		if (max - min == 0)
			return min;

		// Do operations in Int64 to prevent overflow that might be caused by any of the following operations
		// I'm sure there's a faster/better way to do this and avoid casting, but we prefer equivalence to Unity over performance
		// PORT-NOTE: C# 用 long(Int64) 防溢出；Haxe 侧改用双精度（尾数 53 位，本处涉及的值都 < 2^53，结果精确）。
		var minLong:Float = min;
		var maxLong:Float = max;
		// C#: long r = XORShift();  → uint 零扩展为 long
		var r:Float = toUIntFloat(XORShift());

		// Flip the first operator if the max is lower than the min,
		if (max < min)
			return Std.int(minLong - (r % (maxLong - minLong)));
		else
			return Std.int(minLong + (r % (maxLong - minLong)));
	}

	// ---------------------------------------------------------------- Single / float

	// Generate a random floating point between 0.0 and 1.0 (inclusive?)
	public function NextFloat():Float
	{
		return 1.0 - NextFloatRange(0.0, 1.0);
	}

	// Generate a random floating point between min (inclusive) and max (exclusive)
	public function NextFloatRange(min:Float, max:Float):Float
	{
		// C#: (min - max) * ((float)(XORShift() << 9) / 0xFFFFFFFF) + max
		// PORT-NOTE: C# 在 float32 下完成乘除，此处用双精度（Haxe Float）计算，末位舍入可能略有差异。
		return (min - max) * (toUIntFloat(XORShift() << 9) / 4294967295.0) + max;
	}

	// ------------------------------------------------------------------ uint 辅助函数

	// C# (float)someUInt
	private static inline function toUIntFloat(v:Int):Float
	{
		return v >= 0 ? v * 1.0 : v * 1.0 + 4294967296.0;
	}
	private static function uintMod(a:Int, b:Int):Int
	{
		if (b == 0)
			return a; // TODO-PORT: C# 在此会抛 DivideByZeroException，Haxe 侧无对应异常，按不抛处理。
		return Std.int(toUIntFloat(a) % toUIntFloat(b));
	}
	// C# int % int
	private static function intMod(a:Int, b:Int):Int
	{
		if (b == 0)
			return a; // TODO-PORT: 同上。
		return Std.int(a % b);
	}
	// C# uint < uint
	private static inline function uintLess(a:Int, b:Int):Bool
	{
		return toUIntFloat(a) < toUIntFloat(b);
	}
}
