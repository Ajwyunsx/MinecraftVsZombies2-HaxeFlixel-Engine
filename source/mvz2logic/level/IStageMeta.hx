// Ported from: Assets/Scripts/Logic/Level/IStageMeta.cs
package mvz2logic.level;

import mvz2logic.games.IGlobalSaveData;
import pvzengine.NamespaceID;

interface IStageTalkMeta
{
	var Type(get, never):String;
	var Value(get, never):NamespaceID;
	var StartSection(get, never):Int;

	function CanStartTalk(save:IGlobalSaveData):Bool;
	function ShouldRepeat(save:IGlobalSaveData):Bool;
}
