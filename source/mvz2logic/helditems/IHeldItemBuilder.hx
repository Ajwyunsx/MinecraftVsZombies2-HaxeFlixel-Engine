// Ported from: Assets/Scripts/Logic/HeldItems/HeldItemInfo.cs (interface IHeldItemBuilder)
package mvz2logic.helditems;

import pvzengine.IPropertyKey;
import pvzengine.NamespaceID;

interface IHeldItemBuilder extends IHeldItemPropertyContainer
{
	var Type(get, never):NamespaceID;
	var Priority(get, never):Int;
	function GetPropertyKeys():Array<IPropertyKey>;
	function GetPropertyObject(key:IPropertyKey):Dynamic;
}
