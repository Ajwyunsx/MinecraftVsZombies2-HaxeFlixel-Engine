// Ported from: Assets/Scripts/Engine/Level/Modifiers/CalculatorMap.cs
package pvzengine.modifiers;

import pvzengine.modifiers.IntegerModifierCalculator.IntCalculator;
import pvzengine.modifiers.NumberModifierCalculator.FloatCalculator;
import pvzengine.modifiers.NumberModifierCalculator.Vector3Calculator;
import pvzengine.modifiers.SetModifierCalculator.NamespaceIDArrayCalculator;
import pvzengine.modifiers.SetModifierCalculator.NamespaceIDCalculator;
import pvzengine.modifiers.SetModifierCalculator.StringCalculator;

class CalculatorMap
{
	// PORT-NOTE: C# 为 `public static readonly`；Haxe 无 readonly 字段，改用 static var。
	public static var booleanCalculator:ModifierCalculator = new BooleanCalculator();
	public static var stringCalculator:ModifierCalculator = new StringCalculator();
	public static var namespaceIDCalculator:ModifierCalculator = new NamespaceIDCalculator();
	public static var namespaceIDArrayCalculator:ModifierCalculator = new NamespaceIDArrayCalculator();

	public static var intCalculator:ModifierCalculator = new IntCalculator();
	public static var floatCalculator:ModifierCalculator = new FloatCalculator();
	public static var vector3Calculator:ModifierCalculator = new Vector3Calculator();

	public static var colorCalculator:ModifierCalculator = new ColorCalculator();
}
