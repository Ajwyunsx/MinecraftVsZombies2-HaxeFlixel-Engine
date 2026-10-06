// Ported from: Assets/Scripts/View/Widgets/Faders/FloatFader.cs
package mvz2.ui;

import unity.Mathf;

class FloatFader extends Fader<Float>
{
	// PORT-NOTE: 基类 Fader<T>.LerpValue 的签名为 Null<T>（T=Float 时为 Null<Float>），
	// 与 C# 的 float 对应；此处按基类签名声明，避免 “Float should be Null<Float>”。
	override function LerpValue(start:Null<Float>, end:Null<Float>, t:Float):Null<Float>
	{
		return Mathf.Lerp(start, end, t);
	}
}
