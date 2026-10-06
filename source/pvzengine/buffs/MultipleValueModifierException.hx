// Ported from: Assets/Scripts/Engine/Level/Buffs/BuffList.cs
// PORT-NOTE: C# 中 MultipleValueModifierException 与 BuffList 同处 BuffList.cs（命名空间 PVZEngine.Buffs），
//   而 Level/Modifiers/PropertyCalculator.cs 以命名空间路径引用它，故单独成模块，
//   使 `pvzengine.buffs.MultipleValueModifierException` 可用（BuffList.hx 不再重复定义该类名）。
// PORT-NOTE: C# 三个构造函数 (message) / () / (message, innerException) → Haxe 可选参数合并。
package pvzengine.buffs;

class MultipleValueModifierException extends haxe.Exception
{
	public function new(?message:String, ?previous:haxe.Exception)
	{
		super(message != null ? message : "", previous);
	}
}
