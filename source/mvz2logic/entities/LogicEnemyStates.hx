// Ported from: Assets/Scripts/Logic/Entities/LogicEnemyStates.cs
package mvz2logic.entities;

class LogicEnemyStates
{
	public static inline var IDLE:Int = 0;
	public static inline var WALK:Int = 1;
	public static inline var MELEE_ATTACK:Int = 2;
	public static inline var CAST:Int = 3;
	public static inline var DEATH:Int = 4;
	public static inline var RANGED_ATTACK:Int = 5;
	public static inline var LEAVE:Int = 6;

	private function new() {}
}
