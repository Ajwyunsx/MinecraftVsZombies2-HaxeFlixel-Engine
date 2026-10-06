package unity;

// Minimal UnityEngine.QualitySettings shim.
class QualitySettings {
	public static var names:Array<String> = ["Low", "Medium", "High", "Ultra"];
	public static var vSyncCount:Int = 1;

	public static function GetQualityLevel():Int {
		return currentLevel;
	}
	public static function SetQualityLevel(level:Int):Void {
		currentLevel = level;
	}

	private static var currentLevel:Int = 0;
}
