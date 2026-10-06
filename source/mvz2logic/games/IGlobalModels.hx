// Ported from: Assets/Scripts/Logic/Game/IGlobalModels.cs
package mvz2logic.games;

import pvzengine.NamespaceID;

interface IGlobalModels
{
	function ModelExists(id:NamespaceID):Bool;
}
