// Ported from: Assets/Scripts/Engine/Level/Modifiers/Calculators/ColorCalculator.cs
package pvzengine.modifiers;

import pvzengine.modifiers.ModifierCalculator.TypedModifierCalculator;

import tools.EnumerableExt;
import unity.Color;

class ColorCalculator extends TypedModifierCalculator<Color, ColorModifier>
{
	public function new()
	{
		super();
	}
	public override function CalculateGeneric(value:Null<Color>, modifiers:Array<ModifierSourceItem>):Null<Color>
	{
		if (modifiers == null || modifiers.length == 0)
			return value;

		// C#: modifiers.OrderBy(m => m.modifier?.Priority ?? 0)
		var ordered = EnumerableExt.OrderBy(modifiers, function(item:ModifierSourceItem) return item.modifier == null ? 0 : item.modifier.Priority);
		for (item in ordered)
		{
			var buff = item.container;
			var modi = item.modifier;
			if (!Std.isOfType(modi, ColorModifier))
				continue;
			var modifier:ColorModifier = cast modi;
			var src = modifier.GetModifierValueGeneric(buff);
			if (!modifier.FitsConditionGeneric(src))
				continue;
			var dst = value;
			var srcOp = modifier.SrcOperator;
			var dstOp = modifier.DstOperator;
			var srcAOp = modifier.SrcAlphaOperator;
			var dstAOp = modifier.DstAlphaOperator;

			value = Blend(src, dst, srcOp, dstOp, srcAOp, dstAOp);
		}
		return value;
	}
	// PORT-NOTE: C# 有两个 Blend 重载（4 参数与 6 参数）；Haxe 合并为一个方法，
	// 后两个参数为可选（省略时按 4 参数重载的语义，用 srcOp/dstOp 作为 alpha 运算）。
	public static function Blend(src:Color, dst:Color, srcOp:BlendOperator, dstOp:BlendOperator, ?srcAOp:Null<BlendOperator>, ?dstAOp:Null<BlendOperator>):Color
	{
		var srcAlphaOp = srcAOp == null ? srcOp : srcAOp;
		var dstAlphaOp = dstAOp == null ? dstOp : dstAOp;
		var value = new Color(0, 0, 0, 1);
		// PORT-NOTE: C# 使用 UnityEngine.Color 的索引器 value[i]；Haxe shim 无索引器，改为逐分量赋值。
		var comps:Array<Float> = [];
		for (i in 0...3)
		{
			comps.push(GetComponent(src, i) * GetBlendedComponent(src, dst, srcOp, i) + GetComponent(dst, i) * GetBlendedComponent(src, dst, dstOp, i));
		}
		value.r = comps[0];
		value.g = comps[1];
		value.b = comps[2];
		value.a = src.a * GetBlendedComponent(src, dst, srcAlphaOp, 3) + dst.a * GetBlendedComponent(src, dst, dstAlphaOp, 3);
		return value;
	}
	public static function GetBlendedComponent(src:Color, dst:Color, op:BlendOperator, compIndex:Int):Float
	{
		switch (op)
		{
			case BlendOperator.One:
				return 1;
			case BlendOperator.Zero:
				return 0;
			case BlendOperator.SrcAlpha:
				return src.a;
			case BlendOperator.DstAlpha:
				return dst.a;
			case BlendOperator.OneMinusSrcAlpha:
				return 1 - src.a;
			case BlendOperator.OneMinusDstAlpha:
				return 1 - dst.a;
			case BlendOperator.SrcColor:
				return GetComponent(src, compIndex);
			case BlendOperator.DstColor:
				return GetComponent(dst, compIndex);
			case BlendOperator.OneMinusSrcColor:
				return 1 - GetComponent(src, compIndex);
			case BlendOperator.OneMinusDstColor:
				return 1 - GetComponent(dst, compIndex);
		}
		return 0;
	}
	// PORT-NOTE: 等价于 UnityEngine.Color 的索引器读取（0=r, 1=g, 2=b, 3=a）。
	static function GetComponent(color:Color, index:Int):Float
	{
		switch (index)
		{
			case 0:
				return color.r;
			case 1:
				return color.g;
			case 2:
				return color.b;
			case 3:
				return color.a;
		}
		return 0;
	}
}
