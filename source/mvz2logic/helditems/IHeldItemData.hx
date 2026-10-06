// Ported from: Assets/Scripts/Logic/HeldItems/HeldItemInfo.cs (interface IHeldItemData)
package mvz2logic.helditems;

import pvzengine.NamespaceID;

interface IHeldItemData extends IHeldItemPropertyContainer
{
	var Priority(get, never):Int;
	var Type(get, never):NamespaceID;
}
