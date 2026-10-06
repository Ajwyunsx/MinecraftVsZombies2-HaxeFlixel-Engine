// Ported from: Assets/Scripts/Logic/Modding/IModLogic.cs
package mvz2logic.modding;

import mvz2logic.games.IGlobalGame;
import mvz2logic.saves.ModSaveData;
import pvzengine.base.Definition;
import pvzengine.callbacks.ITrigger;

interface IModLogic
{
	public var Namespace(get, never):String;
	function Init(game:IGlobalGame):Void;
	function LateInit(game:IGlobalGame):Void;
	function PostReloadMods(game:IGlobalGame):Void;
	function PostGameInit():Void;
	function GetTriggers():Array<ITrigger>;
	function GetDefinitions():Array<Definition>;
	function CreateSaveData():ModSaveData;
	function LoadSaveData(json:String):ModSaveData;
	function PostAllSaveDataLoaded():Void;
}
