// Ported from: Assets/Scripts/Logic/Inputs/PointerPhase.cs (enum PointerInteraction)
package mvz2logic.inputs;

enum abstract PointerInteraction(Int)
{
	var Hover = 0;
	var Enter = 1;
	var Stay = 2;
	var Exit = 3;

	var Down = 4;
	var Hold = 5;
	var Up = 6;
	var Click = 7;

	var BeginDrag = 8;
	var Drag = 9;
	var EndDrag = 10;
	var Drop = 11;

	var Streak = 12;
	var Release = 13;
	var Key = 100;
}
