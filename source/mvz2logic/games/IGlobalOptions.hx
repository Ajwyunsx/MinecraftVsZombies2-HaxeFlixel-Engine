// Ported from: Assets/Scripts/Logic/Game/IGlobalOptions.cs
package mvz2logic.games;

import pvzengine.NamespaceID;
import tools.Ref;

interface IGlobalOptions
{
	function GetOptionBool(id:NamespaceID):Bool;
	function GetOptionInt(id:NamespaceID):Int;
	function GetOptionFloat(id:NamespaceID):Float;
	function GetOptionString(id:NamespaceID):String;
	function GetOptionID(id:NamespaceID):Null<NamespaceID>;

	// PORT-NOTE: C# 的 out 参数改为 tools.Ref<T>（工程统一的 ref 等价物）。
	function TryGetOptionBool(id:NamespaceID, value:Ref<Bool>):Bool;
	function TryGetOptionInt(id:NamespaceID, value:Ref<Int>):Bool;
	function TryGetOptionFloat(id:NamespaceID, value:Ref<Float>):Bool;
	function TryGetOptionString(id:NamespaceID, value:Ref<String>):Bool;
	function TryGetOptionID(id:NamespaceID, value:Ref<Null<NamespaceID>>):Bool;

	function SetOptionBool(id:NamespaceID, value:Bool):Void;
	function SetOptionInt(id:NamespaceID, value:Int):Void;
	function SetOptionFloat(id:NamespaceID, value:Float):Void;
	function SetOptionString(id:NamespaceID, value:String):Void;
	function SetOptionID(id:NamespaceID, value:Null<NamespaceID>):Void;

	function SaveOptions():Void;
}
