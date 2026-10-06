// Ported from: Assets/Scripts/Logic/Level/LevelExitTarget.cs
package mvz2logic.level;

enum abstract LevelExitTarget(Int)
{
	var MapOrMainmenu = 0;
	var Minigame = 1;
	var Puzzle = 2;
}
