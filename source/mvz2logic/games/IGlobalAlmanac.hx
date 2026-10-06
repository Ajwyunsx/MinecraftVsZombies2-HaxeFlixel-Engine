// Ported from: Assets/Scripts/Logic/Game/IGlobalAlmanac.cs
package mvz2logic.games;

import pvzengine.NamespaceID;

interface IGlobalAlmanac
{
	function IsContraptionInAlmanac(id:NamespaceID):Bool;
	function IsEnemyInAlmanac(id:NamespaceID):Bool;
}
