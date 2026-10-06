// Ported from: Assets/Scripts/Logic/Game/IGlobalDebug.cs
package mvz2logic.games;

import pvzengine.NamespaceID;

interface IGlobalDebug
{
	function CanUseDebugFeatures():Bool;
	function Print(message:String):Void;
	function GetCommandHistory():Array<String>;
	function ExecuteCommand(command:String, times:Int):Void;
	function ClearConsole():Void;
	function GetAllCommandsID():Array<NamespaceID>;
	function GetCommandNameByID(id:NamespaceID):String;
	function GetCommandIDByName(name:String):Null<NamespaceID>;
	function ExportLogFiles():Void;
}
