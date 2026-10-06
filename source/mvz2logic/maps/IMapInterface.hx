// Ported from: Assets/Scripts/Logic/Maps/IMapInterface.cs
// PORT-NOTE: 同文件的 IMapElement 已拆为独立模块 mvz2logic/maps/IMapElement.hx。
package mvz2logic.maps;

import mvz2logic.talk.ITalkSystem;
import pvzengine.NamespaceID;

interface IMapInterface
{
	function SetRaycastBlockerActive(active:Bool):Void;
	function ChangeMap(mapID:NamespaceID):Void;
	function GetMapID():NamespaceID;
	function SetPreset(presetID:NamespaceID):Void;
	function GetTalkSystem():ITalkSystem;
}
