// Ported from: Assets/Scripts/Engine/Tools/GenericHelper.cs
package tools;

/**
 * C# 通过 `value is T` 与 `typeof(T)` 做泛型类型判断/基础类型提升。
 * PORT-NOTE: Haxe 没有运行期泛型（无法以类型参数做 `Std.isOfType`），因此：
 *   * 直接类型匹配改为一次尽力而为的动态转换（失败时返回 default）；
 *   * C# 的数值提升表（byte/short/int/long → short/int/long/float/double）中，
 *     Haxe 里 byte/short/int/long 均映射为 Int、float/double 均映射为 Float，
 *     故仅剩「整型 → 浮点」这一种实际会发生的提升，动态转换已覆盖。
 * 该类在既有上层代码中暂无调用点。
 */
class GenericHelper
{
	public static function ToGeneric<T>(value:Dynamic):T
	{
		var result:{value:T} = {value: null};
		if (TryToGeneric(value, result))
			return result.value;
		return null;
	}
	public static function TryToGeneric<T>(value:Dynamic, result:{value:T}):Bool
	{
		if (value == null)
		{
			result.value = null;
			return true;
		}
		// PORT-NOTE: C# 的 `value is T` 无法在 Haxe 中表达（无运行期泛型），
		// 直接交给 TryConvertBaseType 做一次动态转换尝试。
		if (TryConvertBaseType(value, result))
			return true;
		result.value = null;
		return false;
	}
	private static function TryConvertBaseType<T>(value:Dynamic, result:{value:T}):Bool
	{
		// PORT-NOTE: 见文件头说明——Haxe 中整型统一为 Int、浮点统一为 Float，
		// 故只需处理整型到浮点的提升；其余不兼容类型一律转换失败。
		switch (Type.typeof(value))
		{
			case TInt, TFloat:
				try
				{
					result.value = cast value;
					return true;
				}
				catch (e:Dynamic)
				{
					result.value = null;
					return false;
				}
			default:
				result.value = null;
				return false;
		}
	}
}
