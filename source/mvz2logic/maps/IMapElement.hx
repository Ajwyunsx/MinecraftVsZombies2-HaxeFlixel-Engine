// Ported from: Assets/Scripts/Logic/Maps/IMapInterface.cs
package mvz2logic.maps;

import mvz2logic.talk.ITalkSystem;
import pvzengine.IPropertyKey;
import pvzengine.PropertyKey;

interface IMapElement
{
	function GetProperty<T>(name:PropertyKey<T>):Null<T>;
	function GetPropertyObject(name:IPropertyKey):Dynamic;
	function SetProperty<T>(name:PropertyKey<T>, value:Null<T>):Void;
	function SetPropertyObject(name:IPropertyKey, value:Dynamic):Void;
	public var Map(get, never):IMapInterface;
}
