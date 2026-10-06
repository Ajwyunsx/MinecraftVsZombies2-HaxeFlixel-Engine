// Ported from: Assets/Scripts/Logic/Inputs/PointerPhase.cs (enum PointerPhase)
package mvz2logic.inputs;

enum abstract PointerPhase(Int)
{
	var None = 0;
	var Press = 1;
	var Hold = 2;
	var Release = 3;
}
