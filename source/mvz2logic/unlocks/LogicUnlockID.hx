// Ported from: Assets/Scripts/Logic/Unlocks/LogicUnlockID.cs
package mvz2logic.unlocks;

import mvz2logic.Global;
import pvzengine.NamespaceID;

class LogicUnlockID
{
	private static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}
	public static function GetLevelClearUnlock(stageID:NamespaceID):NamespaceID
	{
		return new NamespaceID(stageID.SpaceName, LogicUnlockNames.GetLevelClearUnlock(stageID.Path));
	}
}
