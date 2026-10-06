// Ported from: Assets/Scripts/Engine/Level/Modifiers/BooleanModifiers/BooleanOperator.cs
package pvzengine.modifiers;

enum abstract BooleanOperator(Int)
{
	var Set = 0;
	var SetNot = 1;
	var And = 2;
	var Or = 3;
	var Not = 4;
	var Xor = 5;
}
