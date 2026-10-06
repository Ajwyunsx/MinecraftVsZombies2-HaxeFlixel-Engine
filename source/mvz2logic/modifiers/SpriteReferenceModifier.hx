// Ported from: Assets/Scripts/Logic/Modifiers/SpriteReferenceModifier.cs
package mvz2logic.modifiers;

import mvz2logic.resources.SpriteReference;
import pvzengine.PropertyKey;
import pvzengine.modifiers.ModifierCalculator;
import pvzengine.modifiers.SetModifier;
import pvzengine.modifiers.SetModifierCalculator;
import pvzengine.modifiers.SetOperator;

class SpriteReferenceModifier extends SetModifier<SpriteReference>
{
	// PORT-NOTE: C# 有两个构造函数重载（第三个参数为 SpriteReference 或 PropertyKey<SpriteReference>），
	// Haxe 不支持重载，合并为第三参数为 Dynamic 的构造函数（传值直接转发给基类对应重载）。
	public function new(propertyName:PropertyKey<SpriteReference>, op:SetOperator, value:Dynamic, priority:Int = 0)
	{
		super(propertyName, op, value, priority);
	}
	public override function GetCalculator():ModifierCalculator
	{
		return calculator;
	}
	public static var calculator:ModifierCalculator = new SpriteReferenceCalculator();
}

class SpriteReferenceCalculator extends SetModifierCalculator<SpriteReference>
{
}
