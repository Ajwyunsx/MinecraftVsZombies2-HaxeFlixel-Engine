// Ported from: Assets/Scripts/Engine/Level/Modifiers/IntegerModifiers/IntegerOperator.cs
package pvzengine.modifiers;

enum abstract IntegerOperator(Int)
{
	var Set = 0;
	var Add = 1;
	var AddMultiple = 2;
	var Multiply = 3;
	var BitAnd = 4;
	var BitOr = 5;
	var BitReverse = 6;
	var BitXor = 7;
	var BitLeftShift = 8;
	var BitRightShift = 9;
}
