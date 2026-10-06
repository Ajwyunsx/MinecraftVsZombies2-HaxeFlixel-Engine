// Ported from: Assets/Scripts/Logic/Modding/IVanillaInterface.cs
package mvz2logic.modding;

import mvz2logic.games.IGlobalSaveData;
import pvzengine.NamespaceID;

interface IVanillaInterface
{
	// Stats
	function IsEnemyEncountered(saves:IGlobalSaveData, enemyID:NamespaceID):Bool;

	function DreamIsNightmare(saves:IGlobalSaveData):Bool;
	function SetDreamIsNightmare(saves:IGlobalSaveData, value:Bool):Void;
}
