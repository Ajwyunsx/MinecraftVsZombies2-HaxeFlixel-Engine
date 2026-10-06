// Ported from: Assets/Scripts/Logic/Unlocks/LogicUnlockID.cs
package mvz2logic.unlocks;

class LogicUnlockNames
{
	public static inline var blueprintSlot1:String = "blueprint_slot.1";
	public static inline var blueprintSlot2:String = "blueprint_slot.2";
	public static inline var blueprintSlot3:String = "blueprint_slot.3";
	public static inline var blueprintSlot4:String = "blueprint_slot.4";

	public static inline var starshardSlot1:String = "starshard_slot.1";
	public static inline var starshardSlot2:String = "starshard_slot.2";

	public static inline var artifactSlot1:String = "artifact_slot.1";
	public static inline var artifactSlot2:String = "artifact_slot.2";
	public static function GetLevelClearUnlock(stageID:String):String
	{
		return 'level.${stageID}';
	}

	private function new() {}
}
