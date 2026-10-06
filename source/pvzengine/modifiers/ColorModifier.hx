// Ported from: Assets/Scripts/Engine/Level/Modifiers/BlendModifiers/ColorModifier.cs
package pvzengine.modifiers;

import pvzengine.modifiers.PropertyModifier.PropertyModifierT;
import pvzengine.PropertyKey;
import unity.Color;

class ColorModifier extends PropertyModifierT<Color>
{
	// PORT-NOTE: C# 有四个构造函数重载：
	//   (propertyName, valueConst, priority = 0)
	//   (propertyName, buffPropertyName, priority = 0)
	//   (propertyName, src, dest, valueConst, priority = 0)
	//   (propertyName, src, dest, buffPropertyName, priority = 0)
	// Haxe 不支持重载，合并为单一构造函数；第 3/4 个参数在运行期按是否给出区分。
	public function new(propertyName:PropertyKey<Color>, a:Dynamic, ?b:Dynamic, ?c:Dynamic, priority:Int = 0)
	{
		var src = BlendOperator.SrcAlpha;
		var dest = BlendOperator.OneMinusSrcAlpha;
		var value:Dynamic = a;
		if (c != null)
		{
			// (propertyName, src, dest, valueConst|buffPropertyName, priority)
			src = cast a;
			dest = cast b;
			value = c;
		}
		else if (b != null)
		{
			// (propertyName, valueConst|buffPropertyName, priority)
			priority = cast b;
		}
		super(propertyName, value, priority);
		SrcOperator = src;
		SrcAlphaOperator = src;
		DstOperator = dest;
		DstAlphaOperator = dest;
	}
	public var SrcOperator(default, null):BlendOperator;
	public var DstOperator(default, null):BlendOperator;
	public var SrcAlphaOperator:BlendOperator;
	public var DstAlphaOperator:BlendOperator;
	// PORT-NOTE: C# 的 Multiply/Override 各有「常量值」与「属性键」两个重载，Haxe 合并为第三参数为 Dynamic 的单个方法。
	public static function Multiply(propertyName:PropertyKey<Color>, value:Dynamic, priority:Int = 0):ColorModifier
	{
		return new ColorModifier(propertyName, BlendOperator.DstColor, BlendOperator.Zero, value, priority);
	}
	public static function Override(propertyName:PropertyKey<Color>, value:Dynamic, priority:Int = 0):ColorModifier
	{
		return new ColorModifier(propertyName, BlendOperator.One, BlendOperator.Zero, value, priority);
	}
	public override function GetCalculator():ModifierCalculator
	{
		return CalculatorMap.colorCalculator;
	}
}
